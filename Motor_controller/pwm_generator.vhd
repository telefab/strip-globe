----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:00:18 11/19/2014 
-- Design Name: 
-- Module Name:    pwm_generator - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

use work.globe_package.all;



entity pwm_generator is	
generic( SPEED_LEN	: integer := 2;
			CLK_LEN		: integer := 10);
port(		clk, raz		: in std_logic;
			speed_in		: in std_logic_vector((SPEED_LEN-1) downto 0);
			pwm			: out std_logic);
end pwm_generator;

architecture Behavioral of pwm_generator is

constant T_CLK			: integer := 40000/(CLK_PERIOD_FPGA*(2**SPEED_LEN));

signal	clk_count	: unsigned((CLK_LEN-1) downto 0) 	:= (others => '0');
signal	pwm_count	: unsigned((SPEED_LEN-1) downto 0) 	:= (others => '0');
signal	speed_mem	: unsigned((SPEED_LEN-1) downto 0)	:= (others => '0');

begin
	process(clk,raz)
	begin
		if raz = '1' then
			speed_mem 	<= (others => '0');
			pwm_count 	<= (others => '0');
			clk_count 	<= (others => '0');
			pwm 			<= '0';
		elsif rising_edge(clk) then
			clk_count	<= clk_count + 1;
			speed_mem 	<= unsigned(speed_in);
			if conv_integer(clk_count) > T_CLK then
				clk_count <= (others => '0');
				pwm_count <= pwm_count + 1;
			end if;
			if pwm_count < speed_mem then
				pwm <= '1';
			else
				pwm <= '0';
			end if;
		end if;
	end process;

end Behavioral;

