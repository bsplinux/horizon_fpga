import yaml
from regs2vhdl import *
from regs2h import *

yaml_file = '../yaml/condor_regs.yaml' 
with open(yaml_file, 'r') as file:
    regs_def = yaml.safe_load(file)
regs2vhdl(regs_def, '../vhdl/regs/regs_pkg.vhd', yaml_file)
regs2h(regs_def, '../vhdl/regs/regs_pkg.h', yaml_file)
