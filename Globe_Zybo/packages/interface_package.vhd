-- This file contains the global definitions for the
--
-------------------------------------------------------------------------
--
--  Package          : interface_package
--  Package body     : none
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

use work.globe_package.all;
use work.image_package.all;

package interface_package is

  --constant image_out : image_type :=
  --  (pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0,
  --   pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_2,
  --   pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_2, pixel_2,
  --   pixel_2, pixel_2, pixel_2, pixel_2, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_2, pixel_2, pixel_2,
  --   pixel_2, pixel_2, pixel_2, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_2, pixel_2, pixel_2, pixel_2,
  --   pixel_2, pixel_2, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2,
  --   pixel_2, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2,
  --   pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2,
  --   pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_1,
  --   pixel_1, pixel_1, pixel_1, pixel_1, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_1, pixel_1,
  --   pixel_1, pixel_1, pixel_1, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_1, pixel_1, pixel_1,
  --   pixel_1, pixel_1, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_1, pixel_1, pixel_1, pixel_1,
  --   pixel_1, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1,
  --   pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1,
  --   pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_0,
  --   pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_0, pixel_0,
  --   pixel_0, pixel_0, pixel_0, pixel_0, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_0, pixel_0, pixel_0,
  --   pixel_0, pixel_0, pixel_0, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_0, pixel_0, pixel_0, pixel_0,
  --   pixel_0, pixel_0, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0,
  --   pixel_0, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0
  --   );

end;
