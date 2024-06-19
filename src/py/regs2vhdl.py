from pathlib import Path
import re
from datetime import datetime

# todo list:
# 1. unpack registers block
# done: 2. allow reset value of registr to come from reg definision (implemented already) or from register list allowing same type of register to have different initialization (overriding init from reg definition)
# done: 3. set registers version in script if that register exists - actually nothing to do as we can use "define: &registers_version 0x00010003" and then "init: *registers_version"
# done: 4. add timestam of creation of pkg in a comment
# done: 5. work out an option to set specific registers init from vhdl and not yaml 
# done: 6. don't require the i: in the register list defaluting to auto
# done: 7. add alingment to help visibility (added using str.r/ljust(20/30) but not using str.r/ljust(20/30)[:20/30] to preserve name even if it is longer than expected)
# 8. allow more than 2 access (fpga,cpu) - implement this only on first use case

def regs2vhdl(regs_def, vhdl_file_name, yaml_file_name):
    vhdl_f = open(vhdl_file_name, 'w')
    package_name = Path(vhdl_file_name).stem
    
    # VHDL file header
    current_time = datetime.now().strftime("%d-%m-%Y %H:%M")
    vhdl_f.write('------------------------------------------------------------------------------------------\n')
    vhdl_f.write('-- Registers VHDL package created from yaml definition of registers at ' + current_time + ' --\n')
    vhdl_f.write('--   python function: regs2vhdl.py                                                      --\n')
    vhdl_f.write('--   yaml file name: ' +  yaml_file_name.ljust(33) + '                                  --\n')
    vhdl_f.write('------------------------------------------------------------------------------------------\n\n')
    # VHDL context close:
    vhdl_f.write("library ieee;\n")
    vhdl_f.write("use ieee.std_logic_1164.all;\n")
    vhdl_f.write("\n")
    # VHDL package
    vhdl_f.write('package ' + package_name + ' is\n\n')
    vhdl_f.write("  constant REG_WIDTH : integer := 32;\n")
    vhdl_f.write("  subtype full_reg_range is integer range REG_WIDTH - 1 downto 0;\n\n")

    # first make a list of registers
    vhdl_f.write("  type regs_names_t is (\n")
    for reg in regs_def['regs']:
        reg_name = next(iter(reg))
        vhdl_f.write("      " + reg_name.ljust(20) + ",\n")
    vhdl_f.write("      NO_REG\n  );\n")
    
    # build address space:
    #      fist find regs size and address spece size
    num_regs = len(regs_def['regs']) + 1
    vhdl_f.write("  constant NUM_REGS:  natural := " + str(num_regs) + ";\n")
    addr_space = 0
    for reg_index in range(len(regs_def['regs'])):
        reg = next(iter(regs_def['regs'][reg_index]))
        if 'i' in regs_def['regs'][reg_index]:
            if regs_def['regs'][reg_index]['i'] == 'auto':
                addr_space = addr_space + 1
            else:
                addr_space = regs_def['regs'][reg_index]['i'] + 1
        else: 
            addr_space = addr_space + 1
    vhdl_f.write("  constant REGS_SPACE_SIZE : natural := " + str(addr_space) + ";\n\n")
    vhdl_f.write("  type regs_a_t is array(REGS_SPACE_SIZE - 1 downto 0) of regs_names_t;\n")
    #     write address space
    vhdl_f.write("  constant regs_a: regs_a_t := (\n")
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
        vhdl_f.write("      " + str(i).rjust(3) + " => " + reg.ljust(20) + ",\n")
    vhdl_f.write("      others => NO_REG\n  );\n\n")
    
    # adding some array types
    vhdl_f.write("  type reg_array_t is array (regs_names_t) of std_logic_vector(full_reg_range);\n")
    vhdl_f.write("  type reg_arrays_t is array (natural range <>) of reg_array_t;\n")
    vhdl_f.write("  type reg_slv_array_t is array (regs_names_t) of std_logic;\n")
    vhdl_f.write("  type reg_slv_arrays_t is array (natural range <>) of reg_slv_array_t;\n\n")
    
    # bit fields
    vhdl_f.write("  ----------------------------------------------------------------------------------\n")  
    vhdl_f.write("  -- bit fields in registers (using named ranges for vectors and constants for bits)\n")
    vhdl_f.write("  ----------------------------------------------------------------------------------\n")  

    for reg_index in range(len(regs_def['regs'])):
        reg = next(iter(regs_def['regs'][reg_index]))
        if 'fields' in regs_def['regs'][reg_index][reg].keys():
            vhdl_f.write("  -- fields for " + reg + '\n')
            for field, val in regs_def['regs'][reg_index][reg]['fields'].items():
                reg_field = reg + '_' + field
                if isinstance(val,str):
                    i = re.findall(r'\d+', val)
                    vhdl_f.write("  subtype  " + reg_field.ljust(30) + ' is integer range ' + i[0].rjust(2) + ' downto ' + i[1].rjust(2) + ';\n')
                else:
                    vhdl_f.write("  constant " + reg_field.ljust(30) + ' : integer := ' + str(val).rjust(2) + ';\n')

    # registers reset value
    vhdl_f.write("\n  ----------------------------------------------------------------------------------\n")  
    vhdl_f.write("  -- Register Reset value (defalut is 0)                                            \n")
    vhdl_f.write("  ----------------------------------------------------------------------------------\n")  

    vhdl_f.write("  constant REGISTERS_INIT : reg_array_t := (\n")
    for reg_index in range(len(regs_def['regs'])):
        reg = next(iter(regs_def['regs'][reg_index]))
        init_val = 0
        # searching for init value in reg definition
        if 'init' in regs_def['regs'][reg_index][reg].keys():
            if regs_def['regs'][reg_index][reg]['init'] != 0:
                init_val = regs_def['regs'][reg_index][reg]['init']
        # searching for init value in register list
        if 'init' in regs_def['regs'][reg_index]:
            init_val = regs_def['regs'][reg_index]['init']
        if init_val != 0:
            hex_init = "%0.8X" % init_val
            vhdl_f.write("    " + reg.ljust(20) + " => X\"" + hex_init + '\",\n')
    vhdl_f.write("    others               => X\"00000000\"\n  );\n\n")

    # registers that can be read
    vhdl_f.write("  ----------------------------------------------------------------------------------\n")  
    vhdl_f.write("  -- Readable registers, in this mechanizm, for now, all registers are readable     \n")
    vhdl_f.write("  ----------------------------------------------------------------------------------\n")  

    vhdl_f.write("  constant READABLE_REGISTERS : reg_slv_array_t := (\n")
    vhdl_f.write("    NO_REG => '0',\n")
    vhdl_f.write("    others => '1'\n  );\n\n")

    # writeable bits in registers
    vhdl_f.write("  ----------------------------------------------------------------------------------\n")  
    vhdl_f.write("  -- writeable bits                                                                 \n")
    vhdl_f.write("  ----------------------------------------------------------------------------------\n")  

    vhdl_f.write("  constant WRITEABLE_REGS : reg_array_t := (\n")
    for reg_index in range(len(regs_def['regs'])):
        reg = next(iter(regs_def['regs'][reg_index]))
        if 'used_bits' in regs_def['regs'][reg_index][reg].keys():
            used_bits = regs_def['regs'][reg_index][reg]['used_bits']
            all_ranges = re.findall(r'\d+:\d+', used_bits)
            used = 0
            for range_i in all_ranges:
                this_range = re.findall(r'\d+', range_i)
                for x in range(int(this_range[1]), int(this_range[0])+1):
                    used |= (1<<(x))
            all_bits = re.findall(r'\d+', used_bits)
            for bit in all_bits:
                used |= (1<<int(bit))
                hex_writable = "%0.8X" % used
            vhdl_f.write("    " + reg.ljust(20) + " => X\"" + hex_writable + '\",\n')
    vhdl_f.write("    others               => X\"00000000\"\n  );\n\n")

   # registers writeable by FPGA
    vhdl_f.write("  ----------------------------------------------------------------------------------\n")  
    vhdl_f.write("  -- Registers writeable by FPGA internaly (as a list not by address)               \n")
    vhdl_f.write("  ----------------------------------------------------------------------------------\n")  

    vhdl_f.write("  constant INTERNALY_WRITEABLE_REGS : reg_slv_array_t := (\n")
    for reg_index in range(len(regs_def['regs'])):
        reg = next(iter(regs_def['regs'][reg_index]))
        if 'fpga_access' in regs_def['regs'][reg_index][reg].keys():
            accss = regs_def['regs'][reg_index][reg]['fpga_access']
            if str(accss).lower() == 'true':
                vhdl_f.write("    " + reg.ljust(20) + " => '1',\n")
    vhdl_f.write("    others               => '0'\n  );\n\n")

    # registers writeable by CPU
    vhdl_f.write("  ----------------------------------------------------------------------------------\n")  
    vhdl_f.write("  -- Registers writeable by CPU                                                     \n")
    vhdl_f.write("  ----------------------------------------------------------------------------------\n")  

    vhdl_f.write("  constant CPU_WRITEABLE_REGS : reg_slv_array_t := (\n")
    for reg_index in range(len(regs_def['regs'])):
        reg = next(iter(regs_def['regs'][reg_index]))
        if 'cpu_access' in regs_def['regs'][reg_index][reg].keys():
            accss = regs_def['regs'][reg_index][reg]['cpu_access']
            if str(accss).lower() == 'true':
                vhdl_f.write("    " + reg.ljust(20) + " => '1',\n")
    vhdl_f.write("    others               => '0'\n  );\n\n")

    vhdl_f.write("  --------------------------------------------------------------------------------------------------------\n")    
    vhdl_f.write("  -- Functions\n")
    vhdl_f.write("  --------------------------------------------------------------------------------------------------------\n")
    vhdl_f.write("  function \"and\" (left, right: reg_slv_array_t) return reg_slv_array_t;\n")
    vhdl_f.write("  function \"or\" (left, right: reg_slv_array_t) return reg_slv_array_t;\n")
    vhdl_f.write("  function \"and\" (left, right: reg_slv_arrays_t) return reg_slv_arrays_t;\n")
    vhdl_f.write("  function \"or\" (left, right: reg_slv_arrays_t) return reg_slv_arrays_t;\n")
    vhdl_f.write("\nend;\n\n")
    vhdl_f.write("package body regs_pkg is\n")
    vhdl_f.write("       function \"and\" (left, right: reg_slv_array_t) return reg_slv_array_t is\n")
    vhdl_f.write("           variable o : reg_slv_array_t;\n")
    vhdl_f.write("       begin\n")
    vhdl_f.write("           for i in reg_slv_array_t'range loop\n")
    vhdl_f.write("               o(i) := left(i) and right(i);\n")
    vhdl_f.write("           end loop;\n")
    vhdl_f.write("           return o;\n")
    vhdl_f.write("       end;\n")
    vhdl_f.write("       \n")
    vhdl_f.write("       function \"or\" (left, right: reg_slv_array_t) return reg_slv_array_t is\n")
    vhdl_f.write("           variable o : reg_slv_array_t;\n")
    vhdl_f.write("       begin\n")
    vhdl_f.write("           for i in reg_slv_array_t'range loop\n")
    vhdl_f.write("               o(i) := left(i) or right(i);\n")
    vhdl_f.write("           end loop;\n")
    vhdl_f.write("           return o;\n")
    vhdl_f.write("       end;\n")
    vhdl_f.write("       \n")
    vhdl_f.write("       function \"and\" (left, right: reg_slv_arrays_t) return reg_slv_arrays_t is\n")
    vhdl_f.write("           variable o : reg_slv_arrays_t(right'range);\n")
    vhdl_f.write("       begin\n")
    vhdl_f.write("           for i in right'range loop\n")
    vhdl_f.write("               o(i) := left(i) and right(i);\n")
    vhdl_f.write("           end loop;\n")
    vhdl_f.write("           return o;\n")
    vhdl_f.write("       end;\n")
    vhdl_f.write("       \n")
    vhdl_f.write("       function \"or\" (left, right: reg_slv_arrays_t) return reg_slv_arrays_t is\n")
    vhdl_f.write("           variable o : reg_slv_arrays_t(right'range);\n")
    vhdl_f.write("       begin\n")
    vhdl_f.write("           for i in right'range loop\n")
    vhdl_f.write("               o(i) := left(i) or right(i);\n")
    vhdl_f.write("           end loop;\n")
    vhdl_f.write("           return o;\n")
    vhdl_f.write("       end;\n")

    vhdl_f.write("end;\n")
    vhdl_f.close()