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

  constant ADDR2_START : integer := (NB_COLUMN/2)*NB_LIGNE;
  
end;
