----------------------------------------------------------------------------------
-- Company: TELECOM Bretagne
-- Engineer: Antonin Martin--Schouler Nicolas Duminy
-- 
-- Create Date: 22.11.2014 16:51:00
-- Module Name: interface - Behavioral
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

entity interface is
	generic (
		DATA_WIDTH  : integer;
		ADDR_WIDTH  : integer
		);
	port (
		clk			: in	std_logic;
		rst			: in	std_logic;
		d_out_ram	: in 	std_logic_vector(DATA_WIDTH-1 downto 0);
		d_in_ram	: out 	std_logic_vector(DATA_WIDTH-1 downto 0);
		addr		: out 	std_logic_vector(ADDR_WIDTH-1 downto 0);
		wr			: out	std_logic
		);
end interface;

architecture rtl of interface is

	-- Component declaration
--	component read_image is
--		generic (
--			DATA_WIDTH  : integer;
--			ADDR_WIDTH  : integer
--			);
--		port (
--			clk			: in	std_logic;
--			rst			: in	std_logic;
--			d_out_ram	: in 	std_logic_vector(DATA_WIDTH-1 downto 0);
--			addr		: out 	std_logic_vector(ADDR_WIDTH-1 downto 0);
--			pixel_out	: out 	std_logic_vector(DATA_WIDTH-1 downto 0)
--			);
--	end component read_image;
	
	component write_image is
		generic (
			DATA_WIDTH  : integer;
			ADDR_WIDTH  : integer
			);
		port (
			clk			: in	std_logic;
			rst			: in	std_logic;
			pixel_in	: in 	std_logic_vector(DATA_WIDTH-1 downto 0);
			d_in_ram	: out 	std_logic_vector(DATA_WIDTH-1 downto 0);
			addr		: out 	std_logic_vector(ADDR_WIDTH-1 downto 0);
			wr			: out	std_logic
			);
	end component write_image;
	
	-- Signal Declaration
	signal pixel_in 	: std_logic_vector(DATA_WIDTH-1 downto 0);
--	signal pixel_out 	: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal count_pixel	: integer;
--	signal addr_out		: std_logic_vector(ADDR_WIDTH-1 downto 0);
	
begin
	-- Component mapping
--	read_image_inst : read_image
--		generic map (
--			DATA_WIDTH  => DATA_WIDTH,
--			ADDR_WIDTH  => ADDR_WIDTH
--			)
--		port map (
--			clk			=>	clk,
--			rst			=>	rst,
--			d_out_ram	=>	d_out_ram,
--			addr		=>	addr_out,
--			pixel_out	=>	pixel_out
--			);
			
	write_image_inst : write_image
		generic map (
			DATA_WIDTH  => DATA_WIDTH,
			ADDR_WIDTH  => ADDR_WIDTH
			)
		port map (
			clk			=>	clk,
			rst			=>	rst,
			pixel_in	=>	pixel_in,
			d_in_ram	=>	d_in_ram,
			addr		=>	addr,
			wr          =>  wr
			);

	process (clk, rst)
	begin
		if rst = '1' then
			pixel_in 	<= (others => '0');
--			pixel_out	<= (others => '0');
			count_pixel	<= 0;
		elsif rising_edge(clk) then 
			pixel_in <= pixel_to_std_logic_vector(image_out(count_pixel));
			if count_pixel < SIZE_IMAGE - 1 then
				count_pixel <= count_pixel + 1;
			else
				count_pixel	<= 0;
			end if;
		end if;
	end process;
end;