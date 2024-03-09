/*************************************************************************
axidmak.c
-------------------------------------------------------------------------------------------------
*************************************************************************/
#include <linux/dmaengine.h>
#include <linux/of_dma.h>
#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/cdev.h>
#include <linux/delay.h>
#include <linux/fs.h>
#include <linux/init.h>
#include <linux/io.h>
#include <linux/fsl_devices.h>
#include <linux/uaccess.h>
#include <linux/slab.h>
#include <linux/jiffies.h>
#include <linux/err.h>
#include <linux/sched/signal.h>
#include <linux/platform_device.h>
#include <linux/dma-mapping.h>
#include <linux/remoteproc.h>
#include <linux/interrupt.h>
#include <linux/of_irq.h>
#include <linux/of_platform.h>
#include <linux/slab.h>
#include <linux/cpu.h>
#include <linux/delay.h>
#include <linux/list.h>
#include <linux/genalloc.h>
#include <linux/pfn.h>
#include <linux/idr.h>
#include <linux/workqueue.h>

#include "kdriver.h"
#include "kdriver_of.h"

#pragma GCC diagnostic ignored "-Wdate-time"

//#define SPFI_READ_INTR_DELAY

#define MAX_DRIVERS  2
static int id_array[MAX_DRIVERS];
static int is_firts_time_init=0;
static int id_array_idx=0;

// driver handle 
typedef struct zynqdvr_pdata {
	char 						name[40];      // driver name
	dev_t 						cdevno;        // register driver number
	struct class 				*m_class;      // kernel driver class 
	struct cdev 				m_cdev;        // char device  
	struct device 				*sys_device;	/* sysfs device */
	struct platform_device 		*pdev;			// kernel platform decice
	int 						driver_id;      // driver id for multiple drivers
	
//  spfi
	spinlock_t 					spin_lock;

	
	int 						dev_triger;
	wait_queue_head_t			dev_queue;
	struct						work_struct work;
	struct						workqueue_struct *work_queue;
	
	int                         firts_time_loop_flag; 
	int 						irq_a;
	struct device_node 			*node;
}zynqdvr_pdata_t;






// mechnisem to create multiple driver 

/*
 initlized multiple driver allocated 
*/

static void zynqdvr_driver_initlized(void){
	if(is_firts_time_init ==0){
		int i;
		is_firts_time_init = 1;
		for(i=0;i<MAX_DRIVERS;i++){
			id_array[i] = i;
		}
	}
}

/*
	allocated driver id 0-N
*/
static int zynqdvr_alloc_id(void){
	int ret_id=0;
	if(id_array_idx >= MAX_DRIVERS ){
		printk("%s.%d ERROR index(%d)\n\r",__func__,__LINE__,id_array_idx);
		return -1;
	}	
	
	ret_id = id_array[id_array_idx];
	id_array_idx++;
	return ret_id;
}

/*
	free driver id 0-N
*/
static void zynqdvr_free_id(int id){
	if(id_array_idx <=0){
		printk("%s.%d ERROR index(%d)\n\r",__func__,__LINE__,id_array_idx);
		return ;
	}
	id_array_idx--;
	id_array[id_array_idx] = id;
	
}


static void DumpMem(unsigned char  *p , int size){
	int i;
	printk("[");
	for(i=0;i<size;i++){
		printk("0x%x,",p[i]);
	}
	printk("]\n\r");
}


static int driver_ioctl_switch(zynqdvr_pdata_t *local, unsigned int ioctlnr, void *parg){
	int ret=0;
	
	switch(ioctlnr){
		case ZYNQCMD_WAIT_TIMER :{
				int timeout_ms=0;
				int wait_ret=0;
				wait_timer_t *prx_msg=0;
				if(parg==0){
					printk("%s.%d fail NULL PTR\n\r",__func__,__LINE__);
					return -ENOMEM;
				}
				prx_msg = (wait_timer_t *)parg; 
				timeout_ms = prx_msg->wait_timeout_ms;
				wait_ret = wait_event_interruptible_timeout(local->dev_queue, local->dev_triger != 0,msecs_to_jiffies(timeout_ms));
				//printk("%s.%d ALERT RX wait_ret(%d)\n\r",__func__,__LINE__,wait_ret);
				local->dev_triger 	=0;
				if(wait_ret ==0){
					printk("%s.%d ERROR blocking: timeout.\n",__func__,__LINE__);
					ret = -ETIME;
				
				} else if (signal_pending(current)) {
					printk("%s.%d ERROR interrupt pending\n\r",__func__,__LINE__);
					ret = -ERESTARTSYS;
				} else{
					ret =0;
				}	
			}		
			break;	
		
		case ZYNQCMD_ALERT_CANCEL :{	// exit from alert wait
			  local->dev_triger =1;
			  wake_up_interruptible(&local->dev_queue);
			  ret =0;
		}	
		break;
		
		
		default :
		break;
	}		
	
	return ret;
	
}
// copy to/from user space and call to internal API switch 
static int usercopy(zynqdvr_pdata_t   *local, unsigned int cmd, unsigned long arg,int (*func)(zynqdvr_pdata_t  *local,unsigned int cmd, void *arg)){
	char	sbuf[128];
	void    *mbuf = NULL;
	void	*parg = NULL;
	int	err  = -EINVAL;

	/*  Copy arguments into temp kernel buffer  */
	
	switch (_IOC_DIR(cmd)) {
	case _IOC_NONE:
		parg = (void	*)arg;
		break;

	case _IOC_READ:
	case _IOC_WRITE:
	case (_IOC_WRITE | _IOC_READ):
		if (_IOC_SIZE(cmd) <= sizeof(sbuf)) {
			parg = (void*)sbuf;
		} else {
			/* too big to allocate from stack */
			mbuf = kmalloc(_IOC_SIZE(cmd),GFP_KERNEL);
			if (NULL == mbuf)
				return -ENOMEM;
			parg = mbuf;
		}

		err = -EFAULT;
		if (_IOC_DIR(cmd) & _IOC_WRITE){
			//printk(KERN_INFO "%s.%d argsize(%d)\n",__func__,__LINE__,_IOC_SIZE(cmd));
			if (copy_from_user(parg, (void __user *)arg, _IOC_SIZE(cmd))){
				printk(KERN_INFO "%s.%d copy from user fail ? \n",__func__,__LINE__);
				goto out;
			}
		}
		break;
	}
	
	/* call driver */
	err = func(local,cmd, parg);
	if (err == -ENOIOCTLCMD)
		err = -EINVAL;
	
	if (err < 0)
		goto out;

/*  Copy results into user buffer  */
	switch (_IOC_DIR(cmd))
	{
	case _IOC_READ:
	case (_IOC_WRITE | _IOC_READ):
		//printk(KERN_INFO "%s.%d argsize(%d)\n",__func__,__LINE__,_IOC_SIZE(cmd));
		if (copy_to_user((void __user *)arg, parg, _IOC_SIZE(cmd))){
			err = -EFAULT;
			
		}
		break;
	}


out:
	if(mbuf)
		kfree(mbuf);
	return err;
}


// call when application call ioctl 
static long char_ctrl_ioctl(struct file *file,unsigned int cmd, unsigned long arg)
{
	
	zynqdvr_pdata_t  *local = (zynqdvr_pdata_t  *)file->private_data ;
	int ret=0;
//	printk("%s.%d :local(0x%x) cmd(%d) name(%s)\n",__func__,__LINE__,local,cmd,local->name);
    
	ret = usercopy(local,cmd, arg,driver_ioctl_switch);
//	printk("%s.%d ret(%d)\n\r",__func__,__LINE__,ret);
	return ret;
}
// call when application call fd = open(device name)  
static int char_open(struct inode *inode, struct file *file)
{
	zynqdvr_pdata_t  *local  = container_of(inode->i_cdev, zynqdvr_pdata_t, m_cdev);
	file->private_data = local;
	if(local){
	//	printk("%s.%d [%s]\n\r",__func__,__LINE__,local->name);
		printk("%s.%d :local(0x%x) name(%s) \n",__func__,__LINE__,local,local->name);		
	}	

	return 0;
}

// call when application call close(fd)  
static int char_close(struct inode *inode, struct file *file)
{
	zynqdvr_pdata_t  *local   = container_of(inode->i_cdev,zynqdvr_pdata_t, m_cdev);
	printk("%s.%d ********** \n\r",__func__,__LINE__);
	
	return 0;
}

// kernel stucture of open/close dispach api 
static const struct file_operations ctrl_fops = {
	.owner = THIS_MODULE,
	.open = char_open,
	.release = char_close,
	.unlocked_ioctl = char_ctrl_ioctl,
};

static inline void worker_callback(struct work_struct *w)
{
	zynqdvr_pdata_t *local = (zynqdvr_pdata_t *)container_of(w, zynqdvr_pdata_t,work);
	local->dev_triger =1;
	wake_up_interruptible(&local->dev_queue);
}

static int intr_count =0;
static irqreturn_t irq_handler(int irq, void *p_param){
	int ret;
	zynqdvr_pdata_t *local = (zynqdvr_pdata_t *)p_param;
	int data_length =0;

	printk("%s.%d ************** %d\n",__func__,__LINE__,intr_count);
	if(local->work_queue){
		queue_work(local->work_queue, &local->work);
	}	
	intr_count++;
	ret = IRQ_HANDLED;
	return ret;
}


static unsigned char inline count_bits_on(unsigned char byte) {
    byte = (byte & 0x55) + ((byte >> 1) & 0x55); // count bits in each pair
    byte = (byte & 0x33) + ((byte >> 2) & 0x33); // count bits in each nibble
    byte = (byte & 0x0F) + ((byte >> 4) & 0x0F); // count bits in each byte
    return byte;
}

static int rcount=0;


/*
	call when driver loaded and find in the device tree
	initlized and start the driver 
	alloc dma channels and pu them in list
*/

int install_intr(zynqdvr_pdata_t *local ,struct device_node *node,char *dev_tree){
	int irq_no;
	int ret;
	irq_no = of_parse_interrupt_number(node,dev_tree,0);
	printk("%s.%d  devm_request_irq IRQ(%d) %s\n",__func__,__LINE__,irq_no,dev_tree);				
	if(irq_no>0){
			char intr_unque[40];
			sprintf(intr_unque,"%s%d","irqn%d",irq_no);
			ret = devm_request_irq(&local->pdev->dev, irq_no, irq_handler,0,intr_unque, local);
			//printk("%s.%d ret(%d) devm_request_irq IRQ(%d)\n",__func__,__LINE__,ret,irq_no);			
			if(ret){
				printk("%s.%d devm_request_irq fail IRQ(%d)\n",__func__,__LINE__,irq_no);
			}
			else {
				printk("%s.%d devm_request_irq success IRQ(%d)\n",__func__,__LINE__,irq_no);
				//devm_free_irq(&pdev->dev, irq_no, local);	
			}
	}
	return ret;		
}


static int zynqdvr_probe(struct platform_device *pdev)
{

	struct resource *res;
	int ret = 0;
	zynqdvr_pdata_t *local=0;
	struct device_node *node = pdev->dev.of_node;
	int driver_id=0;
	int irq_no=0;
	int i;
	
	zynqdvr_driver_initlized();
	
	driver_id = zynqdvr_alloc_id();
	printk("%s.%d drv_id(%d) stop compilantion date[%s][%s] \n\r",__func__,__LINE__,driver_id,__DATE__,__TIME__);
	local = (zynqdvr_pdata_t *)kzalloc(sizeof(zynqdvr_pdata_t), GFP_KERNEL);
	
	local->firts_time_loop_flag =1;
	// create device name
	sprintf(local->name,"%s%d",AXIIMP_NAME,driver_id);
    local->driver_id 	= driver_id;
	local->pdev			= pdev;
	local->cdevno		= register_chrdev(0, local->name, &ctrl_fops);
	local->node     	= node;
	// char device init 
	cdev_init(&local->m_cdev, &ctrl_fops);
	ret = cdev_add (&local->m_cdev, MKDEV(local->cdevno, 0), 1);
	if (ret <0){
	  printk(" failed to register a major number\n");
	  goto exit_error;
	}	
	spin_lock_init(&local->spin_lock);
	
	// Register the device class
	local->m_class	= class_create(THIS_MODULE, local->name);
	if (IS_ERR(local->m_class )){				 // Check for error and clean up if there is
		  unregister_chrdev(local->cdevno, local->name);
		  printk("Failed to register device class\n");
		  ret = -1;	 // Correct way to return an err on a pointer
		  goto exit_error;
	}
	   // Register the device driver
	   local->sys_device = device_create(local->m_class, NULL, MKDEV(local->cdevno, 0), NULL, local->name);
		if (IS_ERR(local->sys_device)){ 			  // Clean up if there is an error
		  class_destroy(local->m_class);			// Repeated code but the alternative is goto statements
		  unregister_chrdev(local->cdevno,local->name);
		  printk("Failed to create the device\n");
		  ret = -1;
		  goto exit_error;
		}

		
	local->dev_triger  	= 0;
	init_waitqueue_head(&local->dev_queue);
	local->work_queue 	= create_workqueue("spw_wq");
	INIT_WORK(&local->work, worker_callback);
	platform_set_drvdata(pdev, local);
#if 1	
	ret = install_intr(local,node,"xlnx,axi-gpio-2.0");
	ret = install_intr(local,node,"xlnx,axi-intr-1.0");
	
	
#endif	
	
	printk("%s load success %d\n",__func__,ret);
	return 0;

exit_error:
	printk("%s exit ERROR %d\n",__func__,ret);	
	return ret;

}


/*
	call when driver removed 
	free all dma channels and dma buffers
	
*/
static int zynqdvr_remove(struct platform_device *pdev)
{
	 zynqdvr_pdata_t *local = (zynqdvr_pdata_t *)platform_get_drvdata(pdev);
	 int i;
	if(local ==0 ){ 
		printk("%s.%d ERROR NULL\n", __func__,__LINE__);
		return 0;
	}	
	
	
	if(local->sys_device){    
	   local->sys_device =0;
       device_destroy(local->m_class, MKDEV(local->cdevno, 0));	  // remove the device
	   //class_unregister(local->m_class);						   // unregister the device class
	   class_destroy(local->m_class);							   // remove the device class
	   unregister_chrdev (local->cdevno, local->name);  
	  }
	zynqdvr_free_id(local->driver_id);
	
	if(local)
		kfree(local);
	platform_set_drvdata(pdev, 0);
	printk("%s unload success \n",__func__);

	return 0;
}

/* Match table for OF platform binding */
static const struct of_device_id zynqdvr_match[] = {
	{ .compatible = "xlnx,kita-1.0", },
	{ /* end of list */ },
};
MODULE_DEVICE_TABLE(of, zynqdvr_match);

static struct platform_driver zynqdvr_driver = {
	.driver = {
		.name = AXIIMP_NAME,
		.of_match_table = zynqdvr_match,
	},
	.probe  = zynqdvr_probe,
	.remove = zynqdvr_remove,	
};

module_platform_driver(zynqdvr_driver);


MODULE_AUTHOR("Itamar Levit <itamar.levit@gmail.com>");
MODULE_LICENSE("GPL v2");
MODULE_DESCRIPTION("ZynqMP PS2PS Communication driver");

	
	
	
