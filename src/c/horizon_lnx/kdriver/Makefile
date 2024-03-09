export ARCH=arm
export CROSS_COMPILE=/home/develop/host/bin/arm-buildroot-linux-gnueabihf-
CC=$(CROSS_COMPILE)gcc
KERNELDIR=/home/develop/linux

PWD :=$(shell pwd)

ccflags-y      += -Wno-error=date-time 
ccflags-y      += -Isrc
##ccflags-y      += -I/home/vsync/develop/horizon_lnx/kdriver/src




all:
	mkdir -p build
	mkdir -p bin 
	cp Makefile build/Makefile
	cp -a src build/
	$(MAKE) -C $(KERNELDIR) M=$(PWD)/build modules
	mv build/*.ko bin/
	rm -r build/src
	rm build/Makefile 
	cp bin/*.ko /home/develop/rootfs/
	cp bin/*.ko /home/develop/target/

clean:
	cp Makefile build/Makefile
	cp -a src build/
	$(MAKE) -C $(KERNELDIR) M=$(PWD)/build clean
	rm build/Makefile 
	rm -r build
	rm -r bin


kdriver_drv-objs := src/kdriver.o src/kdriver_of.o
obj-m += kdriver_drv.o
