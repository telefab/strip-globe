set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property IOSTANDARD LVCMOS18 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports out_led0]
set_property IOSTANDARD LVCMOS33 [get_ports out_led1]
set_property IOSTANDARD LVCMOS33 [get_ports out_led2]
set_property IOSTANDARD LVCMOS33 [get_ports out_led3]
set_property IOSTANDARD LVCMOS33 [get_ports out_led4]
set_property IOSTANDARD LVCMOS33 [get_ports out_led5]

set_property PACKAGE_PIN Y9   [get_ports clk]
set_property PACKAGE_PIN P16  [get_ports rst]
set_property PACKAGE_PIN Y11  [get_ports out_led0]
set_property PACKAGE_PIN AA11 [get_ports out_led1]
set_property PACKAGE_PIN Y10  [get_ports out_led2]
set_property PACKAGE_PIN AA9  [get_ports out_led3]
set_property PACKAGE_PIN AB11 [get_ports out_led4]
set_property PACKAGE_PIN AB10 [get_ports out_led5]

create_clock -period 10.000 -name clk -waveform {0.000 5.000} [get_ports clk]


