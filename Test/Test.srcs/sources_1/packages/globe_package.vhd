-- This file contains the global definitions for the
--
-------------------------------------------------------------------------
--
--  Package          : neo_pixel_package
--  Package body     : none
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

package globe_package is
	
	constant CLK_SPEED         : integer    := 100;              -- MHz
	constant CLK_PERIOD_FPGA   : integer    := 1000/CLK_SPEED;   -- ns	

end;