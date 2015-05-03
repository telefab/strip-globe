set_property PACKAGE_PIN N18 [get_ports iic_0_scl_io]
set_property IOSTANDARD LVCMOS33 [get_ports iic_0_scl_io]
set_property PACKAGE_PIN N17 [get_ports iic_0_sda_io]
set_property IOSTANDARD LVCMOS33 [get_ports iic_0_sda_io]

#This constraint ensures the MMCM located in the clock region connected to the ZYBO's HDMI port
#is used for the axi_dispctrl core driving the HDMI port
set_property LOC MMCME2_ADV_X0Y0 [get_cells system_i/axi_dispctrl_0/inst/DONT_USE_BUFR_DIV5.Inst_mmcme2_drp/mmcm_adv_inst]

#False path constraints for crossing clock domains in the Audio and Display cores.
#Synchronization between the clock domains is handled properly in logic.
#TODO: The following constraints should be changed to identify the proper pins
#      of the cores by their hierarchical pin names. Currently the global clock names are
#      used. Ultimately, it would be nice to have the cores automatically generate them.
#adi_i2s constaints:
set_false_path -from [get_clocks clk_fpga_0] -to [get_clocks clk_fpga_2]
set_false_path -from [get_clocks clk_fpga_2] -to [get_clocks clk_fpga_0]

#axi_dispctrl constraints:
#Note these constraints require that REFCLK be driven by the axi_lite clock (clk_fpga_0)
set_false_path -from [get_clocks clk_fpga_0] -to [get_clocks axi_dispctrl_1_PXL_CLK_O]
set_false_path -from [get_clocks axi_dispctrl_1_PXL_CLK_O] -to [get_clocks clk_fpga_0]

create_generated_clock -name vga_pxlclk -source [get_pins {system_i/processing_system7_0/inst/PS7_i/FCLKCLK[0]}] -multiply_by 1 [get_pins system_i/axi_dispctrl_0/inst/DONT_USE_BUFR_DIV5.BUFG_inst/O]
set_false_path -from [get_clocks vga_pxlclk] -to [get_clocks clk_fpga_0]
set_false_path -from [get_clocks clk_fpga_0] -to [get_clocks vga_pxlclk]

set_property PACKAGE_PIN V13 [get_ports strip_clk_0]
set_property IOSTANDARD LVCMOS33 [get_ports strip_clk_0]

set_property PACKAGE_PIN J15 [get_ports strip_data_0]
set_property IOSTANDARD LVCMOS33 [get_ports strip_data_0]

set_property PACKAGE_PIN U17 [get_ports strip_clk_1]
set_property IOSTANDARD LVCMOS33 [get_ports strip_clk_1]

set_property PACKAGE_PIN W16 [get_ports strip_data_1]
set_property IOSTANDARD LVCMOS33 [get_ports strip_data_1]

set_property PACKAGE_PIN T17 [get_ports INFRA_SENSOR]
set_property IOSTANDARD LVCMOS33 [get_ports INFRA_SENSOR]

set_property PACKAGE_PIN R18 [get_ports {btns_tri_i[0]}]
set_property PACKAGE_PIN P16 [get_ports {btns_tri_i[1]}]
set_property PACKAGE_PIN V16 [get_ports {btns_tri_i[2]}]
set_property PACKAGE_PIN Y16 [get_ports {btns_tri_i[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {btns_tri_i[*]}]

set_property PACKAGE_PIN G15 [get_ports {sws_tri_i[0]}]
set_property PACKAGE_PIN P15 [get_ports {sws_tri_i[1]}]
set_property PACKAGE_PIN W13 [get_ports {sws_tri_i[2]}]
set_property PACKAGE_PIN T16 [get_ports {sws_tri_i[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sws_tri_i[*]}]


set_property PACKAGE_PIN Y17 [get_ports PWM_OUT]
set_property IOSTANDARD LVCMOS33 [get_ports PWM_OUT]
