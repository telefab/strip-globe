----------------------------------------------------------------------------------
-- Company: TELECOM Bretagne
-- Engineer: Antonin Martin--Schouler Nicolas Duminy
-- 
-- Create Date: 22.11.2014 16:51:00
-- Module Name: globe - Behavioral
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
use work.display_package.all;

entity globe is
  generic (
    DATA_RAM_WIDTH : integer := 24;
    ADDR_RAM_WIDTH : integer := 13
    );
  port (
    clk          : in  std_logic;
    rst          : in  std_logic;
--    infra_sensor : in  std_logic;
    out_led0     : out std_logic;
    out_led1     : out std_logic;
    out_led2     : out std_logic;
    out_led3     : out std_logic;
    out_led4     : out std_logic;
    out_led5     : out std_logic
    );
end globe;

architecture rtl of globe is

  -- Component declaration
  component interface is
    generic (
      DATA_WIDTH : integer;
      ADDR_WIDTH : integer
      );
    port (
      clk        : in  std_logic;
      rst        : in  std_logic;
      ram_enable : in  std_logic;
      d_out_ram  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      d_in_ram   : out std_logic_vector(DATA_WIDTH-1 downto 0);
      addr       : out std_logic_vector(ADDR_WIDTH-1 downto 0);
      wr0        : out std_logic;
      wr1        : out std_logic
      );
  end component interface;

  component frame_buffer is
    generic (
      DATA_WIDTH : integer;
      ADDR_WIDTH : integer
      );
    port (
      clk     : in  std_logic;
      -- Port 1
      addr_1  : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
      d_out_1 : out std_logic_vector(DATA_WIDTH-1 downto 0);
      -- Port 2
      d_in    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      wr      : in  std_logic;
      addr_2  : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
      d_out_2 : out std_logic_vector(DATA_WIDTH-1 downto 0)
      );
  end component frame_buffer;

  component display_controller is
    generic (
      DATA_WIDTH : integer;
      ADDR_WIDTH : integer
      );
    port (
      clk          : in  std_logic;
      rst          : in  std_logic;
      infra_sensor : in  std_logic;
      d_out_ram    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      addr         : out std_logic_vector(ADDR_WIDTH-1 downto 0);
      ram_enable   : out std_logic;
      out_led0     : out std_logic;
      out_led1     : out std_logic;
      out_led2     : out std_logic;
      out_led3     : out std_logic;
      out_led4     : out std_logic;
      out_led5     : out std_logic
      );
  end component display_controller;

  -- Signal declaration
  signal d_in         : std_logic_vector(DATA_RAM_WIDTH-1 downto 0);
  signal addr         : std_logic_vector(ADDR_RAM_WIDTH-1 downto 0);
  signal d_out        : std_logic_vector(DATA_RAM_WIDTH-1 downto 0);
  signal addr_frame0  : std_logic_vector(ADDR_RAM_WIDTH-1 downto 0);
  signal addr_frame1  : std_logic_vector(ADDR_RAM_WIDTH-1 downto 0);
  signal addr_2       : std_logic_vector(ADDR_RAM_WIDTH-1 downto 0);
  signal d_out_frame0 : std_logic_vector(DATA_RAM_WIDTH-1 downto 0);
  signal d_out_frame1 : std_logic_vector(DATA_RAM_WIDTH-1 downto 0);
  signal d_out_2      : std_logic_vector(DATA_RAM_WIDTH-1 downto 0);
  signal ram_enable   : std_logic;
  signal wr0          : std_logic;
  signal wr1          : std_logic;
  
  signal count_infra  : integer;
  signal infra_sensor : std_logic;

begin

  interface_inst : interface
    generic map (
      DATA_WIDTH => DATA_RAM_WIDTH,
      ADDR_WIDTH => ADDR_RAM_WIDTH
      )
    port map (
      clk        => clk,
      rst        => rst,
      ram_enable => ram_enable,
      d_out_ram  => d_out_2,
      d_in_ram   => d_in,
      addr       => addr_2,
      wr0        => wr0,
      wr1        => wr1
      );

  frame_buffer0 : frame_buffer
    generic map (
      DATA_WIDTH => DATA_RAM_WIDTH,
      ADDR_WIDTH => ADDR_RAM_WIDTH
      )
    port map (
      clk     => clk,
      addr_1  => addr_frame0,
      d_out_1 => d_out_frame0,
      d_in    => d_in,
      wr      => wr0,
      addr_2  => addr_2,
      d_out_2 => d_out_2
      );

  frame_buffer1 : frame_buffer
    generic map (
      DATA_WIDTH => DATA_RAM_WIDTH,
      ADDR_WIDTH => ADDR_RAM_WIDTH
      )
    port map (
      clk     => clk,
      addr_1  => addr_frame1,
      d_out_1 => d_out_frame1,
      d_in    => d_in,
      wr      => wr1,
      addr_2  => addr_2,
      d_out_2 => d_out_2
      );

  addr  <= addr_frame0 when ram_enable = '0' else addr_frame1;
  d_out <= d_out_frame0 when ram_enable = '0' else d_out_frame1;

  display_controller_inst : display_controller
    generic map (
      DATA_WIDTH => DATA_RAM_WIDTH,
      ADDR_WIDTH => ADDR_RAM_WIDTH
      )
    port map (
      clk          => clk,
      rst          => rst,
      infra_sensor => infra_sensor,
      d_out_ram    => d_out,
      addr         => addr,
      ram_enable   => ram_enable,
      out_led0     => out_led0,
      out_led1     => out_led1,
      out_led2     => out_led2,
      out_led3     => out_led3,
      out_led4     => out_led4,
      out_led5     => out_led5
      );
      
  process(clk, rst)
  begin
    if rst = '1' then
      count_infra  <= 0;
      infra_sensor <= '0';
    elsif rising_edge(clk) then
      if count_infra < WAIT_TIME then
        infra_sensor <= '0';
        count_infra  <= count_infra + 1;
      else
        infra_sensor <= '1';
        count_infra  <= 0;
      end if;
    end if;
  end process;

end rtl;
