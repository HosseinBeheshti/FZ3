#-----------------------<EDIT  HERE>-----------------------
set project_folder build/pl/vivado
set xpr_name vivado
set top_name design_1_wrapper
set core_cnt 8 
set platform_export_path build/pl
#-----------------------</EDIT HERE>----------------------- 
#----------------------------------------------------------
set origin_dir [file dirname [file dirname [info script]]]
#----------------------------------------------------------
cd ${origin_dir}

open_project ./${project_folder}/${xpr_name}.xpr

update_compile_order -fileset sources_1

reset_project

launch_runs synth_1 -jobs $core_cnt
wait_on_run synth_1

launch_runs impl_1 -to_step write_bitstream -jobs $core_cnt
wait_on_run impl_1
#----------------------------------------------------------
#----------------------------------------------------------
set_property pfm_name {} [get_files -all ./${project_folder}/vivado.srcs/sources_1/bd/design_1/design_1.bd]
write_hw_platform -fixed -include_bit -force -file ./${platform_export_path}/design_1_wrapper.xsa
exit


