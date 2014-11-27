----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 18.11.2014 11:05:11
-- Design Name: 
-- Module Name: display_test_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

use work.globe_package.all;
use work.image_package.all;
use work.display_package.all;

entity display_test_tb is
end display_test_tb;

architecture Behavioral of display_test_tb is

    component display_test
        port( 
            clk     : in   std_logic;
            rst     : in   std_logic;
            out_led : out  std_logic
            );
    end component display_test;

    -- Clock declaration
    constant CLK_PERIOD : time := 10 ns;
    
    -- Signal declaration
    -- Inputs
    signal clk          : std_logic := '0';
    signal rst          : std_logic := '1';
    
    -- Outputs
    signal out_led      : std_logic;

begin

    display_test_inst : display_test
        port map ( 
            clk     => clk,
            rst     => rst,
            out_led => out_led
            );
            
    clk <= not clk after CLK_PERIOD/2;
    rst <= '0' after 30 ns;            

end Behavioral;
