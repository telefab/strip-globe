----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 19.11.2014 15:47:53
-- Design Name: 
-- Module Name: synchronisation - rtl
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

use work.globe_package.all;
use work.image_package.all;
use work.display_package.all;

entity synchronisation is
  port (
    clk          : in  std_logic;
    rst          : in  std_logic;
    infra_sensor : in  std_logic;
    new_image    : out std_logic
    );
end synchronisation;

architecture rtl of synchronisation is

  -- Signal declaration
  signal count_time : integer;
  signal count      : integer;
  signal wait_time  : integer;
  
begin

  --process(clk, rst)
  --begin
  --  if rst = '1' then
  --    column_counter <= (others => '0');
  --    count          <= (others => '0');
  --    wait_time      <= (others => '0');
  --    new_column     <= '0';
  --  elsif rising_edge(clk) then
  --    new_column <= '0';
  --    if infra_sensor = '1' then
  --      count          <= (others => '0');
  --      column_counter <= (others => '0');
  --      wait_time      <= new_wait_time;
  --    else
  --      if conv_integer(count) < conv_integer(wait_time) then
  --        count <= count + 1;
  --      else
  --        count          <= (others => '0');
  --        column_counter <= column_counter + 1;
  --        if conv_integer(column_counter) < NB_COLUMN
  --          new_column     <= '1';
  --        end if;
  --      end if;
  --    end if;
  --  end if;
  --end process;

  --added_count  <= unsigned(WAIT_TIME_COLUMN, 18) - count;
  --new_wait_time <= wait_time - added_count/unsigned(NB_COLUMN, 7);

  process(clk, rst)
  begin
    if rst = '1' then
      new_image <= '0';
    elsif rising_edge(clk) then
      if infra_sensor = '1' then
        new_image <= '1';
      else
        new_image <= '0';
      end if;
    end if;
  end process;
  
end rtl;
