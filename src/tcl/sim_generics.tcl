#puts "The following is a list of top level generics before adding generic:"
#puts [get_property generic [get_filesets sim_1]]
set generic_list [get_property generic [get_filesets sim_1]]
lappend generic_list SIM_INPUT_FILE_NAME=C:/work/Horizon/condor/src/vhdl/tb/condor_pl_sim_input.txt
lappend generic_list SIM_OUTPUT_FILE_NAME=C:/work/Horizon/condor/src/vhdl/tb/condor_pl_sim_output.txt

set_property generic $generic_list [get_filesets sim_1]
puts "The following is the final list of top level simulation generics:"
puts [get_property generic [get_filesets sim_1]]
