----------------------------------------------------------------------------------
-- Company: TELECOM Bretagne
-- Engineer: Antonin Martin--Schouler Nicolas Duminy
-- 
-- Create Date: 22.11.2014 16:51:00
-- Module Name: read_image - rtl
-- Description: 
-- Read the pixels in the frame buffer
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

use work.globe_package.all;
use work.image_package.all;

entity read_image is
  generic (
    DATA_WIDTH : integer;
    ADDR_WIDTH : integer
    );
  port (
    clk        : in  std_logic;
    rst        : in  std_logic;
    read_en    : in  std_logic;
    d_out_ram  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    addr       : out std_logic_vector(ADDR_WIDTH-1 downto 0);
    pixel_out  : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end read_image;

architecture rtl of read_image is

  signal addr_r : integer;
  
begin

  read_in_ram : process(clk, rst)
  begin
    if rst = '1' then
      addr_r    <= 0;
    elsif rising_edge(clk) then
      if read_en = '1' then
        -- If read_en = '1' a pixel is read in the frame buffer and the address
        -- is updated
        if addr_r < SIZE_IMAGE - 1 then
          addr_r <= addr_r + 1;
        else
          addr_r <= 0;
        end if;
      end if;
    end if;
  end process read_in_ram;

  pixel_out <= d_out_ram;
  addr      <= std_logic_vector(to_unsigned(addr_r, ADDR_WIDTH));
end;
