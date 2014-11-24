--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:26:40 11/19/2014
-- Design Name:   
-- Module Name:   E:/Programmation/Projet S5/Motor_controller/pwm_generator_tb.vhd
-- Project Name:  Motor_controller
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: pwm_generator
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
use work.globe_package.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY pwm_generator_tb IS
END pwm_generator_tb;
 
ARCHITECTURE behavior OF pwm_generator_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT pwm_generator
    PORT(
         clk : IN  std_logic;
         raz : IN  std_logic;
         speed_in : IN  std_logic_vector(1 downto 0);
         pwm : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal raz : std_logic := '0';
   signal speed_in : std_logic_vector(1 downto 0) := (others => '0');

 	--Outputs
   signal pwm : std_logic;

   -- Clock period definitions
   constant clk_period : time := CLK_PERIOD_FPGA * (1 ns);
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: pwm_generator PORT MAP (
          clk => clk,
          raz => raz,
          speed_in => speed_in,
          pwm => pwm
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
      wait for 100 ns;	
		raz <= '1';
      wait for clk_period*10;
		-- insert stimulus here 
		raz <= '0';
		speed_in <= "01";
		wait for 120000 ns;
		speed_in <= "10";
      wait;
   end process;

END;
