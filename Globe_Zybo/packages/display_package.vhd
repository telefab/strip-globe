-- This file contains the global definitions for the
--
-------------------------------------------------------------------------
--
--  Package          : display_package
--  Package body     : none
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

use work.globe_package.all;
use work.image_package.all;

package display_package is
  
  constant WAIT_TIME        : integer := 667000*NB_COLUMN/CLK_PERIOD_FPGA;
  constant WAIT_TIME_COLUMN : integer := 667000/CLK_PERIOD_FPGA;  -- 667 us

  constant ADDR2_START : integer := 50*NB_LIGNE;
  
end;
