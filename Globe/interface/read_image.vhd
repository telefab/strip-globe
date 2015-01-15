----------------------------------------------------------------------------------
-- Company: TELECOM Bretagne
-- Engineer: Antonin Martin--Schouler Nicolas Duminy
-- 
-- Create Date: 22.11.2014 16:51:00
-- Module Name: read - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

use work.globe_package.all;
use work.image_package.all;
use work.interface_package.all;

entity read_image is
	generic (
		DATA_WIDTH  : integer;
		ADDR_WIDTH  : integer
		);
	port (
		clk			: in	std_logic;
		rst			: in	std_logic;
		d_out_ram	: in 	std_logic_vector(DATA_WIDTH-1 downto 0);
		addr		: out 	std_logic_vector(ADDR_WIDTH-1 downto 0);
		pixel_out	: out 	std_logic_vector(DATA_WIDTH-1 downto 0)
		);
end read_image;

architecture rtl of read_image is
begin
end;