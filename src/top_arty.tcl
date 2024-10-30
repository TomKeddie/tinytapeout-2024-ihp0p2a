# Vivado

create_project -force -part xc7a35ticsg324-1l top_arty.xpr ./vivado/arty

add_files -fileset sources_1 {top_arty.v vga.v}
import_ip -srcset sources_1 {vivado/top_arty_ip/top_arty_ip.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xci}
update_compile_order -fileset sources_1

add_files -fileset constrs_1 {top_arty.xdc}

launch_runs synth_1
wait_on_run synth_1

launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1

