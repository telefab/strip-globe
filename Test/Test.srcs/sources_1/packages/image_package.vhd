-- This file contains the global definitions for the
--
-------------------------------------------------------------------------
--
--  Package          : image_package
--  Package body     : none
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

use work.globe_package.all;

package image_package is

	constant NB_COLUMN                     : integer := 100;
	constant NB_LIGNE                      : integer := 60;
	constant NB_PIXEL_BY_STRIP : integer   := 20;
	
	type pixel_type is array (2 downto 0) of std_logic_vector(7 downto 0); -- B, R, G
	type strip_type is array (NB_PIXEL_BY_STRIP - 1 downto 0) of pixel_type;
	type column_image_type is array (NB_COLUMN - 1 downto 0) of pixel_type;	
	type image_type is array (NB_LIGNE - 1 downto 0) of column_image_type;
		
		
end;