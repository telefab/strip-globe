set_property PACKAGE_PIN Y9 [get_ports clk]
set_property PACKAGE_PIN P16 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports out_led]
set_property IOSTANDARD LVCMOS18 [get_ports rst]
set_property PACKAGE_PIN W12 [get_ports out_led]

create_clock -period 10.000 -name clk -waveform {0.000 5.000} [get_ports clk]


