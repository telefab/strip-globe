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

	signal column_image    : column_image_type;
	
	constant pixel_0        : pixel_type := ("11111111","00000000","00000000");
	constant pixel_1        : pixel_type := ("11111111","11111111","11111111");
	constant pixel_2        : pixel_type := ("00000000","11111111","00000000");
	
	constant strip_0         : strip_type := (pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0);
	
	constant strip_1         : strip_type := (pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_2);
	constant strip_2         : strip_type := (pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_2, pixel_2);
	constant strip_3         : strip_type := (pixel_2, pixel_2, pixel_2, pixel_2, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_2, pixel_2, pixel_2);
	constant strip_4         : strip_type := (pixel_2, pixel_2, pixel_2, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_2, pixel_2, pixel_2, pixel_2);
	constant strip_5         : strip_type := (pixel_2, pixel_2, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2);
	constant strip_6         : strip_type := (pixel_2, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2);
	constant strip_7         : strip_type := (pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2);
	
	constant strip_8         : strip_type := (pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_1);
	constant strip_9         : strip_type := (pixel_1, pixel_1, pixel_1, pixel_1, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_1, pixel_1);
	constant strip_10        : strip_type := (pixel_1, pixel_1, pixel_1, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_1, pixel_1, pixel_1);
	constant strip_11        : strip_type := (pixel_1, pixel_1, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_1, pixel_1, pixel_1, pixel_1);
	constant strip_12        : strip_type := (pixel_1, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1);
	constant strip_13        : strip_type := (pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1);
	
	constant strip_14        : strip_type := (pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_0);
	constant strip_15        : strip_type := (pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_0, pixel_0);
	constant strip_16        : strip_type := (pixel_0, pixel_0, pixel_0, pixel_0, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_0, pixel_0, pixel_0);
	constant strip_17        : strip_type := (pixel_0, pixel_0, pixel_0, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_0, pixel_0, pixel_0, pixel_0);
	constant strip_18        : strip_type := (pixel_0, pixel_0, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0);
	constant strip_19        : strip_type := (pixel_0, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_2, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_1, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0, pixel_0);
		
--	signal strip_1         : strip_type;
--	signal strip_2         : strip_type;
--	signal strip_3         : strip_type;
--	signal strip_4         : strip_type;
--	signal strip_5         : strip_type;
		
end;