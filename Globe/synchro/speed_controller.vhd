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

use work.synchro_package.all;


entity speed_controller is
port(clk, raz, sensor 	: in std_logic;
	  rnd,colCh				: out std_logic;
	  columnTimeUnit 		: out std_logic_vector(COMPTEUR_RND-1 downto 0);
	  columnTimeD 			: out std_logic_vector(COMPTEUR_RND-1 downto 0));
end speed_controller;


architecture Behavioral of speed_controller is

signal count100C 		: unsigned(COMPTEUR100C_SIZE-1 downto 0) := (others => '0');
signal countUnit 		: unsigned(COMPTEUR_RND-1 downto 0) := (others => '0');
signal countD			: unsigned(COMPTEUR_RND-1 downto 0) := (others => '0');
signal columnUnit		: unsigned(COMPTEUR_RND-1 downto 0) := (others => '0');
signal columnD			: unsigned(COMPTEUR_RND-1 downto 0) := (others => '0');
signal countForColU 	: unsigned(COMPTEUR_RND-1 downto 0) := (others => '0');
signal countForColD 	: unsigned(COMPTEUR_RND-1 downto 0) := (others => '0');
signal rndMade			: std_logic := '0';
signal fastEnough 	: std_logic := '0';
signal read2round 	: std_logic_vector(1 downto 0) := "00";

begin

	columnTimeUnit <= std_logic_vector(columnUnit);
	columnTimeD <= std_logic_vector(columnD);

	roundCounters : process(clk,raz)
	begin
		if raz = '1' then
			count100C <= (others => '0');
			countUnit <= (others => '0');
			countD <= (others => '0');
			columnUnit <= (others => '0');
			columnD <= (others => '0');
			rndMade <= '0';
			rnd <= '0';
			fastEnough <= '0';
			read2round <= "00";
		elsif rising_edge(clk) then
			if sensor = '1' and rndMade = '0' then
				if conv_integer(countD) < MAX_RND_TIME then
					case read2round is
						when "00" => read2round <= "01";
						when others => fastEnough <= '1';
					end case;
				end if;
				rnd <= '1';
				rndMade <= '1';
				columnUnit <= countUnit;
				columnD <= countD;
				count100C <= (others => '0');
				countUnit <= (others => '0');
				countD <= (others => '0');
			else
				rnd <= '0';
				if sensor = '0' then
					rndMade <= '0';
				end if;
				if conv_integer(count100C) > (COLUMNS-2) then
					count100C <= (others => '0');
					if conv_integer(countUnit) = MAX_COUNT_RND then
						if conv_integer(countD) < MAX_RND_TIME then
							countD <= countD + 1;
							countUnit <= (others => '0');
						else
							fastEnough <= '0';
						end if;
					else
						countUnit <= countUnit + 1;
					end if;
				else
					count100C <= count100C + 1;
				end if;
			end if;
		end if;
	end process;
	
	columnSynchro : process(clk,raz)
	begin
		if raz = '1' then
			countForColU <= (others => '0');
			countForColD <= (others => '0');
			colCh <= '0';
		elsif rising_edge(clk) then
			if sensor = '1' and rndMade = '0' then
				countForColU <= (others => '0');
				countForColD <= (others => '0');
				colCh <= '0';
			elsif fastEnough = '1' then
				if countForColD = columnD and countForColU = columnUnit then
					colCh <= '1';
					countForColU <= (others => '0');
					countForColD <= (others => '0');
				else
					colCh <= '0';
					if conv_integer(countForColU) = MAX_COUNT_RND then
						if conv_integer(countForColD) /= MAX_COUNT_RND then
							countForColD <= countForColD + 1;
							countForColU <= (others => '0');
						end if;
					else
						countForColU <= countForColU + 1;
					end if;
				end if;
			else
				colCh <= '0';
			end if;
		end if;
	end process;


end Behavioral;