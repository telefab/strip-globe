----------------------------------------------------------------------------------
-- Company: TELECOM Bretagne
-- Engineer: Antonin Martin--Schouler Nicolas Duminy
-- 
-- Create Date: 22.11.2014 16:51:00
-- Module Name: gpu - Behavioral
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

entity gpu is
  generic (
    DATA_WIDTH : integer;
    ADDR_WIDTH : integer
    );
  port (
    clk        : in  std_logic;
    rst        : in  std_logic;
    ram_enable : in  std_logic;
    ram_select : out std_logic;
    pixel_out  : out std_logic_vector(DATA_WIDTH-1 downto 0);
    write_en   : out std_logic
    );
end gpu;

architecture rtl of gpu is

  --Constant Declaration
  constant PIXEL_B : std_logic_vector(DATA_WIDTH-1 downto 0) := "111111110000000000000000";
  constant PIXEL_G : std_logic_vector(DATA_WIDTH-1 downto 0) := "000000001111111100000000";
  constant PIXEL_R : std_logic_vector(DATA_WIDTH-1 downto 0) := "000000000000000011111111";
  constant PIXEL_W : std_logic_vector(DATA_WIDTH-1 downto 0) := "111111111111111111111111";

  -- Signal Declaration
  signal count_pixel    : integer range 0 to 48;
  signal column_counter : integer range 0 to 100;
  signal image_select   : std_logic;
  signal ram_select_r   : std_logic;
  signal switch_pixel   : std_logic;
  
begin

  process (rst, clk)
  begin
    if rst = '1' then
      pixel_out      <= (others => '0');
      count_pixel    <= 0;
      column_counter <= 0;
      ram_select_r   <= '0';
    elsif rising_edge(clk) then
      if ram_enable = ram_select_r then
        if column_counter < NB_COLUMN then
          write_en <= '1';
          if count_pixel < NB_LIGNE then
            if image_select = '0' then
              if switch_pixel = '0' then
                pixel_out <= PIXEL_B;
              else
                pixel_out <= PIXEL_R;
              end if;
            else
              if switch_pixel = '0' then
                pixel_out <= PIXEL_G;
              else
                pixel_out <= PIXEL_W;
              end if;
            end if;
            switch_pixel <= not switch_pixel;
          else
            count_pixel    <= 0;
            column_counter <= column_counter + 1;
          end if;
        else
          write_en       <= '0';
          column_counter <= 0;
          image_select   <= not image_select;
          ram_select_r   <= not ram_select_r;
        end if;
      end if;
    end if;
  end process;

  ram_select <= ram_select_r;
  
--process (rst, clk)
--begin
--  if rst = '1' then
--    pixel_out      <= (others => '0');
--    count_pixel    <= 0;
--    column_counter <= 0;
--  elsif rising_edge(clk) then
--    write_en <= '1';
--    if column_counter < NB_COLUMN then
--      if count_pixel < NB_PIXEL_BY_STRIP then
--        count_pixel <= count_pixel + 1;
--        if column_counter < 33 then
--          pixel_out <= PIXEL_B;
--        elsif column_counter < 66 then
--          pixel_out <= PIXEL_G;
--        else
--          pixel_out <= PIXEL_R;
--        end if;
--      elsif count_pixel < 2*NB_PIXEL_BY_STRIP then
--        count_pixel <= count_pixel + 1;
--        if column_counter < 33 then
--          pixel_out <= PIXEL_G;
--        elsif column_counter < 66 then
--          pixel_out <= PIXEL_R;
--        else
--          pixel_out <= PIXEL_B;
--        end if;
--      elsif count_pixel < 3*NB_PIXEL_BY_STRIP-1 then
--        count_pixel <= count_pixel + 1;
--        if column_counter < 33 then
--          pixel_out <= PIXEL_R;
--        elsif column_counter < 66 then
--          pixel_out <= PIXEL_B;
--        else
--          pixel_out <= PIXEL_G;
--        end if;
--      else
--        column_counter <= column_counter + 1;
--        count_pixel    <= 0;
--      end if;
--    else
--      column_counter <= 0;
--    end if;
--  end if;
--end process;

end;
