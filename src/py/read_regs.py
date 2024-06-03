import yaml
from regs2vhdl import *

with open('../yaml/condor_regs.yaml', 'r') as file:
    regs_def = yaml.safe_load(file)
regs2vhdl(regs_def, '../vhdl/regs/regs_pkg.vhd')
