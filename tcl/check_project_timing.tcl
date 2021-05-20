#-----------------------<EDIT  HERE>-----------------------
set project_folder build/pl/vivado
set xpr_name vivado
set top_name design_1_wrapper
set core_cnt 8 
#-----------------------</EDIT HERE>----------------------- 
#----------------------------------------------------------
set origin_dir [file dirname [file dirname [info script]]]
#----------------------------------------------------------
cd ${origin_dir}

open_project ./${project_folder}/${xpr_name}.xpr

open_run impl_1

set design_timing_pass [expr {[get_property SLACK [get_timing_paths -setup -hold]] >= 0}]

if {$design_timing_pass == 1} {
    puts "design timing passed"
    exit
} else {
    puts "design timing NOT passed"
    exit 1
}



