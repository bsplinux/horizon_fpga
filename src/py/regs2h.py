#todo:
# allow bit fields to overlap and then use only one set of bitfields in union (it works in vhdl it doesnt in h)

from pathlib import Path
import re
from datetime import datetime

def regs2h(regs_def, h_file_name, yaml_file_name):
    h_f = open(h_file_name, 'w')
    header_file_name = Path(h_file_name).stem
    
    # VHDL file header
    current_time = datetime.now().strftime("%d-%m-%Y %H:%M")
    h_f.write("/*\n")
    h_f.write('----------------------------------------------------------------------------------------\n')
    h_f.write('-- Registers H file created from yaml definition of registers at     ' + current_time + ' --\n')
    h_f.write('--   python function: regs2h.py                                                       --\n')
    h_f.write('--   yaml file name: ' +  yaml_file_name.ljust(33) + '                                --\n')
    h_f.write('----------------------------------------------------------------------------------------\n')
    h_f.write("*/\n\n")
    # H file 
    h_f.write("#ifndef __" + header_file_name.upper() + "_H__\n")
    h_f.write("\n")

    h_f.write("#include <stdint.h>\n")
    h_f.write("#pragma pack(push,1)\n\n")

    for reg_index in range(len(regs_def['regs'])):
        reg = next(iter(regs_def['regs'][reg_index]))
        h_f.write("typedef struct\n{\n")
        if 'fields' in regs_def['regs'][reg_index][reg].keys():
            index = 0
            for field, val in regs_def['regs'][reg_index][reg]['fields'].items():
                if isinstance(val,str):
                    i = re.findall(r'\d+', val)
                    gap = int(i[1]) - index
                    if gap > 0:
                        h_f.write("    uint32_t pad" + str(index).ljust(20) + ': ' + str(gap) + ';\n')
                    leng = int(i[0]) - int(i[1]) + 1
                    h_f.write("    uint32_t " + field.ljust(23) + ': ' + str(leng) + ';\n')
                    index = int(i[0]) + 1
                else:
                    if val == index:
                        h_f.write("    uint32_t " + field.ljust(23) + ': 1;\n')
                        index = index + 1
                    else:
                        gap = val - index
                        h_f.write("    uint32_t pad" + str(index).ljust(20) + ': ' + str(gap) + ';\n')
                        h_f.write("    uint32_t " + field.ljust(23) + ': 1;\n')
                        index = val + 1
        h_f.write("}fields_" + reg + "_t;\n\n")
        h_f.write("typedef union\n{\n")
        h_f.write("    uint32_t raw;\n")
        h_f.write("    fields_" + reg +"_t fields;\n")
        h_f.write("}" + reg + "_t;\n\n")


    # build address space:
    #      fist find regs size and address spece size
    num_regs = len(regs_def['regs'])
    h_f.write("#define NUM_REGS_PACKED " + str(num_regs) + "\n")
    addr_space = 0
    for reg_index in range(len(regs_def['regs'])):
        reg = next(iter(regs_def['regs'][reg_index]))
        if 'i' in regs_def['regs'][reg_index][reg]:
            if reg['i'] == 'auto':
                addr_space = addr_space + 1
            else:
                addr_space = reg['i'] + 1
        else: 
            addr_space = addr_space + 1
    h_f.write("#define NUM_REGS " + str(addr_space) + "\n\n")

    #     write address space
    h_f.write("typedef struct\n{\n")
    i = -1
    for reg_index in range(len(regs_def['regs'])):
        reg = next(iter(regs_def['regs'][reg_index]))
        if 'i' in regs_def['regs'][reg_index]:
            if regs_def['regs'][reg_index]['i'] == 'auto':
                i = i + 1
            else:
                pad = regs_def['regs'][reg_index]['i'] - i - 1
                if pad > 0:
                    h_f.write(str("    uint32_t").ljust(29) + str("pad" + str(i+1) + "[" + str(pad) + "]" ).ljust(20) + ";\n")
                i = regs_def['regs'][reg_index]['i']
        else: 
            i = i + 1
        #h_f.write("      " + str(i).rjust(3) + " => " + reg.ljust(20) + ",\n")
        h_f.write("    " + str(reg + "_t ").ljust(25) + reg.ljust(20) + ";\n")
    h_f.write("}registers_t;\n")
    h_f.write("#pragma pack(pop)\n\n")
   
    h_f.write("// example to use in c file:\n")
    h_f.write("// registers_t* const registers = (registers_t *)FPGA_BASE_ADDRESS;\n")

    h_f.write("\n\n// for simple use of registers as offsets in the address space use these defined constants:\n\n")
    i = -1
    for reg_index in range(len(regs_def['regs'])):
        reg = next(iter(regs_def['regs'][reg_index]))
        if 'i' in regs_def['regs'][reg_index]:
            if regs_def['regs'][reg_index]['i'] == 'auto':
                i = i + 1
            else:
                i = regs_def['regs'][reg_index]['i']
        else: 
            i = i + 1
        h_f.write("#define " + (reg + "_i ").ljust(20) + str(i).rjust(3) + "\n")

    h_f.write("\n#endif //__" + header_file_name.upper() + "_H__\n")
    h_f.close()