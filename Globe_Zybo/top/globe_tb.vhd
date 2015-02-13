----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 18.11.2014 11:05:11
-- Design Name: 
-- Module Name: globe_tb - Behavioral
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

entity globe_tb is
end globe_tb;

architecture Behavioral of globe_tb is

  component globe
    port(
      clk          : in  std_logic;
      rst          : in  std_logic;
      infra_sensor : in  std_logic;
      out_led0     : out std_logic;
      out_led1     : out std_logic;
      out_led2     : out std_logic;
      out_led3     : out std_logic;
      out_led4     : out std_logic;
      out_led5     : out std_logic
      );
  end component globe;

  -- Clock declaration
  constant CLK_PERIOD : time := 8 ns;

  -- Signal declaration
  -- Inputs
  signal clk          : std_logic := '0';
  signal rst          : std_logic := '1';
  signal infra_sensor : std_logic;

  -- Outputs
  signal out_led0 : std_logic;
  signal out_led1 : std_logic;
  signal out_led2 : std_logic;
  signal out_led3 : std_logic;
  signal out_led4 : std_logic;
  signal out_led5 : std_logic;

  -- Intern
  signal count_infra : integer;

begin

  globe_inst : globe
    port map (
      clk          => clk,
      rst          => rst,
      infra_sensor => infra_sensor,
      out_led0     => out_led0,
      out_led1     => out_led1,
      out_led2     => out_led2,
      out_led3     => out_led3,
      out_led4     => out_led4,
      out_led5     => out_led5
      );

  clk <= not clk after CLK_PERIOD/2;
  rst <= '0'     after 30 ns;

  process(clk, rst)
  begin
    if rst = '1' then
      count_infra  <= 0;
      infra_sensor <= '0';
    elsif rising_edge(clk) then
      if count_infra < 667000*5/8 then
        infra_sensor <= '0';
        count_infra  <= count_infra + 1;
      else
        infra_sensor <= '1';
        count_infra  <= 0;
      end if;
    end if;
  end process;
  
end Behavioral;
