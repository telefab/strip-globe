----------------------------------------------------------------------------------
-- Company: TELECOM Bretagne
-- Engineer: Antonin Martin--Schouler Nicolas Duminy
-- 
-- Create Date: 22.11.2014 16:51:00
-- Module Name: write_image - rtl
-- Description: 
-- This module is responsable of writting the pixels in the frame buffer. It is
-- controled by the GPU.
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

use work.globe_package.all;
use work.image_package.all;

entity write_image is
  generic (
    DATA_WIDTH : integer;
    ADDR_WIDTH : integer
    );
  port (
    clk             : in  std_logic;
    rst             : in  std_logic;
    write_en        : in  std_logic;
    write_en_letter : in  std_logic;
    ram_select      : in  std_logic;
    addr_offset     : in  std_logic;
    addr_letter     : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
    addr_letter_en  : in  std_logic;
    wr0_ps          : in  std_logic;
    wr1_ps          : in  std_logic;
    pixel_in        : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    d_in_ram        : out std_logic_vector(DATA_WIDTH-1 downto 0);
    addr            : out std_logic_vector(ADDR_WIDTH-1 downto 0);
    wr0             : out std_logic;
    wr1             : out std_logic
    );
end write_image;

architecture rtl of write_image is

  signal addr_r     : integer range 0 to SIZE_IMAGE;
  signal addr_r1    : integer range 0 to SIZE_IMAGE;
  signal addr_r2    : integer range 0 to SIZE_IMAGE;
  signal wr_en      : std_logic;
  signal write_en_r : std_logic;
  
begin

  -- The writting enable used depends on if it is a letter that will be written
  -- or not
  write_en_r <= write_en when addr_letter_en = '0' else
                write_en_letter;
  
  write_in_ram : process(clk, rst)
  begin
    if rst = '1' then
      addr_r1  <= 0;
      d_in_ram <= (others => '0');
      wr_en    <= '0';
      wr1      <= '0';
      wr0      <= '0';
    elsif rising_edge(clk) then
      -- If write_en_r = '1' a pixel will be written in the frame buffer
      if write_en_r = '1' then
        -- pixel_in is the pixel written in the frame buffer
        d_in_ram <= pixel_in;
        if addr_letter_en = '0' then
          -- The selection of the frame buffer is done by the GPU or the
          -- processor if the pixel correspond to a letter
          if ram_select = '0' then
            -- Select by the GPU
            wr0 <= '1';
          else
            wr1 <= '1';
          end if;
        else
          -- Select by the processor
          wr0 <= wr0_ps;
          wr1 <= wr1_ps;
        end if;
        wr_en <= '1';
      else
        d_in_ram <= (others => '0');
        wr_en    <= '0';
        wr0      <= '0';
        wr1      <= '0';
      end if;
      -- The address is updated after the writting
      if wr_en = '1' then
        if addr_r1 < SIZE_IMAGE - 1 then
          addr_r1 <= addr_r1 + 1;
        else
          addr_r1 <= 0;
          wr0     <= '0';
          wr1     <= '0';
        end if;
      end if;
    end if;
  end process write_in_ram;

  addr_r2 <= addr_r1 + 48 when addr_r1 < SIZE_IMAGE - 48 else
             addr_r1 - (SIZE_IMAGE - 48);

  -- For a rotation the writting has to start at the second column           
  addr_r <= addr_r1 when addr_offset = '0' else
             addr_r2;

  -- If it is a letter the address will be given by the processor through the GPU
  addr <= std_logic_vector(to_unsigned(addr_r, ADDR_WIDTH)) when addr_letter_en = '0' else
          addr_letter;
end;
