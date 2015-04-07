----------------------------------------------------------------------------------
-- Company: TELECOM Bretagne
-- Engineer: Antonin Martin--Schouler Nicolas Duminy
-- 
-- Create Date: 22.11.2014 16:51:00
-- Module Name: globe - rtl
-- Description: 
-- Top modul responsable of the communication between the different parts of
-- the system and the processor
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

use work.globe_package.all;
use work.image_package.all;
use work.display_package.all;

entity globe is
  generic (
    DATA_RAM_WIDTH : integer;
    ADDR_RAM_WIDTH : integer
    );
  port (
    clk            : in  std_logic;
    rst            : in  std_logic;
    infra_sensor   : in  std_logic;
    out_led0       : out std_logic;
    out_led1       : out std_logic;
    out_led2       : out std_logic;
    out_led3       : out std_logic;
    out_led4       : out std_logic;
    out_led5       : out std_logic;
    columnTimeUnit : out std_logic_vector(COMPTEUR_RND-1 downto 0);
    columnTimeD    : out std_logic_vector(COMPTEUR_RND-1 downto 0);
    -- PS ports
    d_in_ps        : in  std_logic_vector(DATA_RAM_WIDTH-1 downto 0);
    addr_ps        : in  std_logic_vector(ADDR_RAM_WIDTH-1 downto 0);
    ctrl           : in  std_logic_vector(7 downto 0);
    rotation_speed : in  std_logic_vector(2 downto 0);
    char_ps        : in  std_logic_vector(7 downto 0);
    char_color     : in  std_logic_vector(23 downto 0);
    char_posx      : in  std_logic_vector(7 downto 0);
    char_posy      : in  std_logic_vector(7 downto 0);
    d_out_ps       : out std_logic_vector(DATA_RAM_WIDTH-1 downto 0);
    ram_read_pl    : out std_logic
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
      clk            : in  std_logic;
      rst            : in  std_logic;
      infra_sensor   : in  std_logic;
      d_out_ram      : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      addr           : out std_logic_vector(ADDR_WIDTH-1 downto 0);
      out_led0       : out std_logic;
      out_led1       : out std_logic;
      out_led2       : out std_logic;
      out_led3       : out std_logic;
      out_led4       : out std_logic;
      out_led5       : out std_logic;
      image_read     : out std_logic;
      columnTimeUnit : out std_logic_vector(COMPTEUR_RND-1 downto 0);
      columnTimeD    : out std_logic_vector(COMPTEUR_RND-1 downto 0)
      );
  end component display_controller;

  -- Signal declaration
  signal d_in           : std_logic_vector(DATA_RAM_WIDTH-1 downto 0);
  signal d_in_pl        : std_logic_vector(DATA_RAM_WIDTH-1 downto 0);
  signal addr           : std_logic_vector(ADDR_RAM_WIDTH-1 downto 0);
  signal d_out          : std_logic_vector(DATA_RAM_WIDTH-1 downto 0);
  signal addr_2         : std_logic_vector(ADDR_RAM_WIDTH-1 downto 0);
  signal addr_pl        : std_logic_vector(ADDR_RAM_WIDTH-1 downto 0);
  signal d_out_frame0   : std_logic_vector(DATA_RAM_WIDTH-1 downto 0);
  signal d_out_frame1   : std_logic_vector(DATA_RAM_WIDTH-1 downto 0);
  signal d_out_2_frame0 : std_logic_vector(DATA_RAM_WIDTH-1 downto 0);
  signal d_out_2_frame1 : std_logic_vector(DATA_RAM_WIDTH-1 downto 0);
  signal d_out_2        : std_logic_vector(DATA_RAM_WIDTH-1 downto 0);
  signal ram_select_rd  : std_logic;
  signal ram_enable_pl  : std_logic;
  signal image_read     : std_logic;
  signal ram_read_r     : std_logic;
  signal wr0_pl         : std_logic;
  signal wr1_pl         : std_logic;
  signal wr0            : std_logic;
  signal wr1            : std_logic;

  --
  signal wr0_ps          : std_logic;
  signal wr1_ps          : std_logic;
  signal ram_enable_ps   : std_logic;
  signal ps_control      : std_logic;
  signal ram_read_ps     : std_logic;
  signal copy            : std_logic;
  signal letter_enable   : std_logic;
  signal rotation_enable : std_logic;

begin

  -- Control signals from the processor
  wr0_ps          <= ctrl(0);
  wr1_ps          <= ctrl(1);
  ram_enable_ps   <= ctrl(2);
  ps_control      <= ctrl(3);  -- Inform that the processor is taking control of
  -- the system
  ram_read_ps     <= ctrl(4);
  copy            <= ctrl(5);
  letter_enable   <= ctrl(6);
  rotation_enable <= ctrl(7);

  interface_inst : interface
    generic map (
      DATA_WIDTH => DATA_RAM_WIDTH,
      ADDR_WIDTH => ADDR_RAM_WIDTH
      )
    port map (
      clk             => clk,
      rst             => rst,
      image_read      => image_read,
      ram_read        => ram_read_r,
      ps_control      => ps_control,
      copy            => copy,
      letter_enable   => letter_enable,
      rotation_enable => rotation_enable,
      rotation_speed  => rotation_speed,
      char_ps         => char_ps,
      char_color      => char_color,
      char_posx       => char_posx,
      char_posy       => char_posy,
      wr0_ps          => wr0_ps,
      wr1_ps          => wr1_ps,
      ram_enable      => ram_enable_pl,
      d_out_ram       => d_out_2,
      d_in_ram        => d_in_pl,
      ram_select_rd   => ram_select_rd,
      addr            => addr_pl,
      wr0             => wr0_pl,
      wr1             => wr1_pl
      );

  -- Frame buffer control signals 
  wr0      <= wr0_ps         when ps_control = '1'    else wr0_pl;
  wr1      <= wr1_ps         when ps_control = '1'    else wr1_pl;
  d_in     <= d_in_ps        when ps_control = '1'    else d_in_pl;
  addr_2   <= addr_ps        when ps_control = '1'    else addr_pl;
  d_out_ps <= d_out_2_frame0 when ram_read_ps = '0'   else d_out_2_frame1;
  d_out_2  <= d_out_2_frame0 when ram_select_rd = '0' else d_out_2_frame1;

  frame_buffer0 : frame_buffer
    generic map (
      DATA_WIDTH => DATA_RAM_WIDTH,
      ADDR_WIDTH => ADDR_RAM_WIDTH
      )
    port map (
      clk     => clk,
      addr_1  => addr,
      d_out_1 => d_out_frame0,
      d_in    => d_in,
      wr      => wr0,
      addr_2  => addr_2,
      d_out_2 => d_out_2_frame0
      );

  frame_buffer1 : frame_buffer
    generic map (
      DATA_WIDTH => DATA_RAM_WIDTH,
      ADDR_WIDTH => ADDR_RAM_WIDTH
      )
    port map (
      clk     => clk,
      addr_1  => addr,
      d_out_1 => d_out_frame1,
      d_in    => d_in,
      wr      => wr1,
      addr_2  => addr_2,
      d_out_2 => d_out_2_frame1
      );

  process(clk, rst)
  begin
    if rst = '1' then
      ram_read_r <= '0';
    elsif rising_edge(clk) then
      if image_read = '1' then
        if ps_control = '1' then
          ram_read_r <= ram_enable_ps;
        else
          ram_read_r <= ram_enable_pl;
        end if;
      end if;
    end if;
  end process;

  -- Selection of the frame buffer read buy the display controller
  ram_read_pl <= ram_read_r;
  d_out       <= d_out_frame0 when ram_read_r = '0' else d_out_frame1;


  display_controller_inst : display_controller
    generic map (
      DATA_WIDTH => DATA_RAM_WIDTH,
      ADDR_WIDTH => ADDR_RAM_WIDTH
      )
    port map (
      clk            => clk,
      rst            => rst,
      infra_sensor   => infra_sensor,
      d_out_ram      => d_out,
      addr           => addr,
      out_led0       => out_led0,
      out_led1       => out_led1,
      out_led2       => out_led2,
      out_led3       => out_led3,
      out_led4       => out_led4,
      out_led5       => out_led5,
      image_read     => image_read,
      columnTimeUnit => columnTimeUnit,
      columnTimeD    => columnTimeD
      );

end rtl;
