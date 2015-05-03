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
ExecStep $xv_path/bin/xelab -wto ef377d6dab5c41919a90f83efff4b4d7 -m64 --debug typical --relax -L xil_defaultlib -L secureip --snapshot apa102_strip_tb_behav xil_defaultlib.apa102_strip_tb -log elaborate.log
