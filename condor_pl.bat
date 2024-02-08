call C:\programs\Xilinx\Vivado\2023.2\settings64.bat
call vivado -mode batch -source ./src/tcl/flow.tcl -tclargs --params_file condor_pl.yaml
pause
