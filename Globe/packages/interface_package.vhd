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

    constant pixel_0        : pixel_type := ("11111111","00000000","00000000");
	constant pixel_1        : pixel_type := ("11111111","11111111","11111111");
	constant pixel_2        : pixel_type := ("00000000","11111111","00000000");

	constant image_out : image_type :=
		(pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0,
		 pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_2,
		 pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_2, pixel_2,
		 pixel_2, pixel_2, pixel_2, pixel_2, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_2, pixel_2, pixel_2,
		 pixel_2, pixel_2, pixel_2, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_2, pixel_2, pixel_2, pixel_2,
		 pixel_2, pixel_2, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2,
		 pixel_2, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2,
		 pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2,
		 pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_1,
		 pixel_1, pixel_1, pixel_1, pixel_1, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_1, pixel_1,
		 pixel_1, pixel_1, pixel_1, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_1, pixel_1, pixel_1,
		 pixel_1, pixel_1, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_1, pixel_1, pixel_1, pixel_1,
		 pixel_1, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1,
		 pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1,
		 pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_0,
		 pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_0, pixel_0,
		 pixel_0, pixel_0, pixel_0, pixel_0, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_0, pixel_0, pixel_0,
		 pixel_0, pixel_0, pixel_0, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_0, pixel_0, pixel_0, pixel_0,
		 pixel_0, pixel_0, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0,
		 pixel_0, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0
		 );

end;