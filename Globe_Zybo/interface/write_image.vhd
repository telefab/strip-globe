----------------------------------------------------------------------------------
-- Company: TELECOM Bretagne
-- Engineer: Antonin Martin--Schouler Nicolas Duminy
-- 
-- Create Date: 22.11.2014 16:51:00
-- Module Name: write_image - Behavioral
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
use work.interface_package.all;

entity write_image is
  generic (
    DATA_WIDTH : integer;
    ADDR_WIDTH : integer
    );
  port (
    clk        : in  std_logic;
    rst        : in  std_logic;
    write_en   : in  std_logic;
    ram_select : in  std_logic;
    pixel_in   : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    d_in_ram   : out std_logic_vector(DATA_WIDTH-1 downto 0);
    addr       : out std_logic_vector(ADDR_WIDTH-1 downto 0);
    wr0        : out std_logic;
    wr1        : out std_logic
    );
end write_image;

architecture rtl of write_image is

  signal addr_r : integer;
  signal wr_en  : std_logic;
  
begin

  write_in_ram : process(clk, rst)
  begin
    if rst = '1' then
      addr_r   <= 0;
      d_in_ram <= (others => '0');
    elsif rising_edge(clk) then
      if write_en = '1' then
        d_in_ram <= pixel_in;
        if ram_select = '0' then
          wr0 <= '1';
        else
          wr1 <= '1';
        end if;
        wr_en <= '1';
      else
        d_in_ram <= (others => '0');
      end if;
      if wr_en = '1' then
        if addr_r < SIZE_IMAGE - 1 then
          addr_r <= addr_r + 1;
        else
          addr_r <= 0;
          wr0    <= '0';
          wr1    <= '0';
          wr_en  <= '0';
        end if;
      end if;
    end if;
  end process write_in_ram;

  addr <= std_logic_vector(to_unsigned(addr_r, ADDR_WIDTH));
end;
