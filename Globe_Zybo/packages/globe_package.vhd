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
  
  constant CLK_SPEED       : integer := 125;             -- MHz
  constant CLK_PERIOD_FPGA : integer := 1000/CLK_SPEED;  -- ns
  --constant SPEED_LEN       : integer := 16;
  constant RPS             : integer := 15;

  -- constantes de simulation
  --constant COMPTEUR_RND      : integer := 3;
  --constant COMPTEUR100C_SIZE : integer := 3;
  ----constant TIME_S            : integer := 9;
  --constant MAX_RND_TIME : integer := (2**COMPTEUR_RND-1);

  --constantes de synthèse
  constant COMPTEUR_RND      : integer := 10;
  constant COMPTEUR100C_SIZE : integer := 7;
  --constant TIME_S            : integer := 27;
  constant MAX_RND_TIME      : integer := (2**COMPTEUR_RND-1);

  constant MAX_COUNT_RND : integer := (2**COMPTEUR_RND-1);
  constant R_SPEED       : integer := (CLK_SPEED * (10**6)) / (RPS * NB_COLUMN);

  -- constantes PID
  --constant KP : integer := 100;
  --constant KI : integer := 0;
  --constant KD : integer := 0;

end;
