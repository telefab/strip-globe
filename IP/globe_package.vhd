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

use work.image_package.all;

package globe_package is
  
  constant CLK_SPEED       : integer := 100;             -- MHz
  constant CLK_PERIOD_FPGA : integer := 1000/CLK_SPEED;  -- ns
  constant RPS             : integer := 15;

  --constantes de synthèse
  constant COMPTEUR_RND      : integer := 10;
  constant COMPTEUR100C_SIZE : integer := 7;
  constant MAX_RND_TIME      : integer := 890;

  constant MAX_COUNT_RND : integer := (2**COMPTEUR_RND-1);
  constant R_SPEED       : integer := (CLK_SPEED * (10**6)) / (RPS * NB_COLUMN);
  
  type char_type is
    record
      ch         : std_logic_vector(7 downto 0);
      color      : std_logic_vector(23 downto 0);
      posx       : std_logic_vector(7 downto 0);
      posy       : std_logic_vector(7 downto 0);
    end record;

end;
