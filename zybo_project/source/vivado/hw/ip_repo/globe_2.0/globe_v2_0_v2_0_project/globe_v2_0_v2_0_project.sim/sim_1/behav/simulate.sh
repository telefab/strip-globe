#!/bin/sh -f
xv_path="/opt/Xilinx/Vivado/2014.4"
ExecStep()
{
"$@"
RETVAL=$?
if [ $RETVAL -ne 0 ]
then
exit $RETVAL
fi
}
ExecStep $xv_path/bin/xsim apa102_strip_tb_behav -key {Behavioral:sim_1:Functional:apa102_strip_tb} -tclbatch apa102_strip_tb.tcl -log simulate.log
