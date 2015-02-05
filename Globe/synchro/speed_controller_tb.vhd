--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   18:00:51 02/04/2015
-- Design Name:   
-- Module Name:   E:/Programmation/Projet S5/Synchro/speed_controller_tb.vhd
-- Project Name:  Synchro
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: speed_controller
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

use work.synchro_package.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY speed_controller_tb IS
END speed_controller_tb;
 
ARCHITECTURE behavior OF speed_controller_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT speed_controller
    PORT(
         clk : IN  std_logic;
         raz : IN  std_logic;
         sensor : IN  std_logic;
         rnd : OUT  std_logic;
         colCh : OUT  std_logic;
			columnTimeUnit : out std_logic_vector(COMPTEUR_RND-1 downto 0);
			columnTimeD : out std_logic_vector(COMPTEUR_RND-1 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal raz : std_logic := '0';
   signal sensor : std_logic := '0';

 	--Outputs
   signal rnd : std_logic;
   signal colCh : std_logic;
	signal columnTimeUnit : std_logic_vector(COMPTEUR_RND-1 downto 0);
	signal columnTimeD	 : std_logic_vector(COMPTEUR_RND-1 downto 0);
	
   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: speed_controller PORT MAP (
          clk => clk,
          raz => raz,
          sensor => sensor,
          rnd => rnd,
          colCh => colCh,
			 columnTimeUnit => columnTimeUnit,
			 columnTimeD => columnTimeD
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		raz <= '1';
      wait for 100 ns;
		raz <= '0';
      wait for clk_period*53;
		sensor <= '1';
		wait for clk_period*2;
		sensor <= '0';
		wait for clk_period*51;
		sensor <= '1';
		wait for clk_period*3;
		sensor <= '0';
		wait for clk_period*51;
		sensor <= '1';
		wait for clk_period*3;
		sensor <= '0';
		wait for clk_period*35;
		sensor <= '1';
		wait for clk_period;
		sensor <= '0';
		wait for clk_period*35;
		sensor <= '1';
		wait for clk_period;
		sensor <= '0';
		wait for clk_period*150;
		wait for clk_period*53;
		sensor <= '1';
		wait for clk_period*2;
		sensor <= '0';
		wait for clk_period*51;
		sensor <= '1';
		wait for clk_period*3;
		sensor <= '0';
      wait;
   end process;

END;
