----------------------------------------------------------------------------------
-- Company: TELECOM Bretagne
-- Engineer: Antonin Martin--Schouler Nicolas Duminy
-- 
-- Create Date: 22.11.2014 16:51:00
-- Module Name: interface - rtl
-- Description: 
-- Connect the GPU to the frame buffer and the rest of the system
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

use work.globe_package.all;
use work.image_package.all;

entity interface is
  generic (
    DATA_WIDTH : integer;
    ADDR_WIDTH : integer
    );
  port (
    clk             : in  std_logic;
    rst             : in  std_logic;
    image_read      : in  std_logic;
    ram_read        : in  std_logic;
    ps_control      : in  std_logic;
    copy            : in  std_logic;
    letter_enable   : in  std_logic;
    rotation_enable : in  std_logic;
    rotation_speed  : in  std_logic_vector(2 downto 0);
    char_ps         : in  std_logic_vector(7 downto 0);
    char_color      : in  std_logic_vector(23 downto 0);
    char_posx       : in  std_logic_vector(7 downto 0);
    char_posy       : in  std_logic_vector(7 downto 0);
    wr0_ps          : in  std_logic;
    wr1_ps          : in  std_logic;
    d_out_ram       : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    d_in_ram        : out std_logic_vector(DATA_WIDTH-1 downto 0);
    addr            : out std_logic_vector(ADDR_WIDTH-1 downto 0);
    ram_select_rd   : out std_logic;
    ram_enable      : out std_logic;
    wr0             : out std_logic;
    wr1             : out std_logic
    );
end interface;

architecture rtl of interface is

  -- Component declaration
  component gpu is
    generic (
      DATA_WIDTH : integer;
      ADDR_WIDTH : integer
      );
    port (
      clk             : in  std_logic;
      rst             : in  std_logic;
      pixel_in        : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      image_read      : in  std_logic;
      ram_read        : in  std_logic;
      ps_control      : in  std_logic;
      copy            : in  std_logic;
      letter_enable   : in  std_logic;
      rotation_enable : in  std_logic;
      rotation_speed  : in  std_logic_vector(2 downto 0);
      char_ps         : in  std_logic_vector(7 downto 0);
      char_color      : in  std_logic_vector(23 downto 0);
      char_posx       : in  std_logic_vector(7 downto 0);
      char_posy       : in  std_logic_vector(7 downto 0);
      ram_enable      : out std_logic;
      ram_select      : out std_logic;
      ram_select_rd   : out std_logic;
      pixel_out       : out std_logic_vector(DATA_WIDTH-1 downto 0);
      write_en        : out std_logic;
      write_en_letter : out std_logic;
      read_en         : out std_logic;
      addr_offset     : out std_logic;
      addr_letter     : out std_logic_vector(ADDR_WIDTH-1 downto 0);
      addr_letter_en  : out std_logic
      );
  end component gpu;

  component read_image is
    generic (
      DATA_WIDTH : integer;
      ADDR_WIDTH : integer
      );
    port (
      clk       : in  std_logic;
      rst       : in  std_logic;
      read_en   : in  std_logic;
      d_out_ram : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      addr      : out std_logic_vector(ADDR_WIDTH-1 downto 0);
      pixel_out : out std_logic_vector(DATA_WIDTH-1 downto 0)
      );
  end component read_image;

  component write_image is
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
  end component write_image;

  -- Signal Declaration
  signal pixel_in        : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal pixel_out       : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal write_en        : std_logic;
  signal write_en_letter : std_logic;
  signal read_en         : std_logic;
  signal ram_select      : std_logic;
  signal addr_offset     : std_logic;
  signal addr_wr         : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal addr_rd         : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal addr_letter     : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal addr_letter_en  : std_logic;
  
begin
  -- Component mapping
  gpu_inst : gpu
    generic map (
      DATA_WIDTH => DATA_WIDTH,
      ADDR_WIDTH => ADDR_WIDTH
      )
    port map (
      clk             => clk,
      rst             => rst,
      image_read      => image_read,
      ram_read        => ram_read,
      pixel_in        => pixel_in,
      ps_control      => ps_control,
      copy            => copy,
      letter_enable   => letter_enable,
      rotation_enable => rotation_enable,
      rotation_speed  => rotation_speed,
      char_ps         => char_ps,
      char_color      => char_color,
      char_posx       => char_posx,
      char_posy       => char_posy,
      ram_enable      => ram_enable,
      ram_select      => ram_select,
      ram_select_rd   => ram_select_rd,
      pixel_out       => pixel_out,
      write_en        => write_en,
      write_en_letter => write_en_letter,
      read_en         => read_en,
      addr_offset     => addr_offset,
      addr_letter     => addr_letter,
      addr_letter_en  => addr_letter_en
      );

  read_image_inst : read_image
    generic map (
      DATA_WIDTH => DATA_WIDTH,
      ADDR_WIDTH => ADDR_WIDTH
      )
    port map (
      clk       => clk,
      rst       => rst,
      read_en   => read_en,
      d_out_ram => d_out_ram,
      addr      => addr_rd,
      pixel_out => pixel_in
      );

  write_image_inst : write_image
    generic map (
      DATA_WIDTH => DATA_WIDTH,
      ADDR_WIDTH => ADDR_WIDTH
      )
    port map (
      clk             => clk,
      rst             => rst,
      ram_select      => ram_select,
      addr_offset     => addr_offset,
      addr_letter     => addr_letter,
      addr_letter_en  => addr_letter_en,
      write_en        => write_en,
      write_en_letter => write_en_letter,
      wr0_ps          => wr0_ps,
      wr1_ps          => wr1_ps,
      pixel_in        => pixel_out,
      d_in_ram        => d_in_ram,
      addr            => addr_wr,
      wr0             => wr0,
      wr1             => wr1
      );

  -- Switch between the reading address from the read_image and the writing
  -- address from the write_image
  addr <= addr_rd when read_en = '1' else addr_wr;

end;
