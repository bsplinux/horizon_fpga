#puts "The following is a list of top level generics before adding synthesis time generic:"
#puts [get_property generic [current_fileset]]
set generic_list [get_property generic [current_fileset]]
set dateTime_32bit [clock format [clock seconds] -format %y%m%d%H]
#set dateTime_32bit [[clock seconds]]
lappend generic_list SYNTHESIS_TIME=32'h$dateTime_32bit
set_property generic $generic_list [current_fileset]
puts "The following is the final list of top level generics:"
puts [get_property generic [current_fileset]]
#the following line (if run) we override any old generic set elseware, so use above lines instead
#set_property generic SYNTHESIS_TIME=32'h$dateTime_32bit [current_fileset]

