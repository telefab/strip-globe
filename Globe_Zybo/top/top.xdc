#Clock signal
set_property PACKAGE_PIN L16 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 4} [get_ports clk]

##RST signal
set_property PACKAGE_PIN Y16 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

##Output signal
set_property PACKAGE_PIN V12 [get_ports out_led0]
set_property IOSTANDARD LVCMOS33 [get_ports out_led0]

set_property PACKAGE_PIN W16 [get_ports out_led1]
set_property IOSTANDARD LVCMOS33 [get_ports out_led1]

set_property PACKAGE_PIN J15 [get_ports out_led2]
set_property IOSTANDARD LVCMOS33 [get_ports out_led2]

set_property PACKAGE_PIN H15 [get_ports out_led3]
set_property IOSTANDARD LVCMOS33 [get_ports out_led3]

set_property PACKAGE_PIN V13 [get_ports out_led4]
set_property IOSTANDARD LVCMOS33 [get_ports out_led4]

set_property PACKAGE_PIN U17 [get_ports out_led5]
set_property IOSTANDARD LVCMOS33 [get_ports out_led5]