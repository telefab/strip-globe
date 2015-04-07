----------------------------------------------------------------------------------
-- Company: TELECOM Bretagne
-- Engineer: Antonin Martin--Schouler Nicolas Duminy
-- 
-- Create Date: 22.11.2014 16:51:00
-- Module Name: display_controller - rtl 
-- Description: 
-- Respnsable of the communication of the different modules of the display part
-- of the system
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

use work.globe_package.all;
use work.image_package.all;
use work.display_package.all;

entity display_controller is
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
end display_controller;

architecture rtl of display_controller is

  -- Component declaration
  component column_reader is
    generic (
      DATA_WIDTH        : integer;
      ADDR_WIDTH        : integer;
      NB_STRIP          : integer;
      NB_PIXEL_BY_STRIP : integer
      );
    port (
      clk          : in  std_logic;
      rst          : in  std_logic;
      ready        : in  std_logic;
      new_image    : in  std_logic;
      new_column   : in  std_logic;
      d_out_ram    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      addr         : out std_logic_vector(ADDR_WIDTH-1 downto 0);
      pixel_vector : out std_logic_vector(6*DATA_WIDTH-1 downto 0);
      new_pixel    : out std_logic;
      image_read   : out std_logic
      );
  end component column_reader;

  component send_pixel
    generic (
      DATA_WIDTH : integer
      );
    port (
      clk           : in  std_logic;
      rst           : in  std_logic;
      ready         : in  std_logic;
      new_pixel     : in  std_logic;
      pixel_in      : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      bit_out       : out std_logic;
      out_enable    : out std_logic;
      ready_to_send : out std_logic
      );
  end component send_pixel;

  component send_to_strip
    port (
      clk        : in  std_logic;
      rst        : in  std_logic;
      bit_out    : in  std_logic;
      out_enable : in  std_logic;
      out_led    : out std_logic;
      ready      : out std_logic
      );
  end component send_to_strip;

  component speed_controller
    port(
      clk            : in  std_logic;
      rst            : in  std_logic;
      infra_sensor   : in  std_logic;
      rnd            : out std_logic;
      next_column    : out std_logic;
      columnTimeUnit : out std_logic_vector(COMPTEUR_RND-1 downto 0);
      columnTimeD    : out std_logic_vector(COMPTEUR_RND-1 downto 0)
      );
  end component speed_controller;

  -- Signal declaration
  signal bit_out0 : std_logic;
  signal bit_out1 : std_logic;
  signal bit_out2 : std_logic;
  signal bit_out3 : std_logic;
  signal bit_out4 : std_logic;
  signal bit_out5 : std_logic;

  signal out_enable0 : std_logic;
  signal out_enable1 : std_logic;
  signal out_enable2 : std_logic;
  signal out_enable3 : std_logic;
  signal out_enable4 : std_logic;
  signal out_enable5 : std_logic;

  signal ready0 : std_logic;
  signal ready1 : std_logic;
  signal ready2 : std_logic;
  signal ready3 : std_logic;
  signal ready4 : std_logic;
  signal ready5 : std_logic;

  signal new_pixel    : std_logic;
  signal pixel_vector : std_logic_vector(6*DATA_WIDTH-1 downto 0);

  signal pixel0 : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal pixel1 : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal pixel2 : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal pixel3 : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal pixel4 : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal pixel5 : std_logic_vector(DATA_WIDTH-1 downto 0);

  signal ready_to_send  : std_logic;
  signal ready_to_send0 : std_logic;
  signal ready_to_send1 : std_logic;
  signal ready_to_send2 : std_logic;
  signal ready_to_send3 : std_logic;
  signal ready_to_send4 : std_logic;
  signal ready_to_send5 : std_logic;

  signal new_image   : std_logic;
  signal next_column : std_logic;
  
begin

  -- Component mapping
  column_reader_inst : column_reader
    generic map (
      DATA_WIDTH        => DATA_WIDTH,
      ADDR_WIDTH        => ADDR_WIDTH,
      NB_STRIP          => 6,
      NB_PIXEL_BY_STRIP => NB_PIXEL_BY_STRIP
      )
    port map (
      clk          => clk,
      rst          => rst,
      ready        => ready_to_send,
      new_image    => new_image,
      new_column   => next_column,
      d_out_ram    => d_out_ram,
      addr         => addr,
      pixel_vector => pixel_vector,
      new_pixel    => new_pixel,
      image_read   => image_read
      );

  -- The output array of the column_reader is divided in 6 pixels for the 6 send_pixels
  pixel0 <= pixel_vector(DATA_WIDTH - 1 downto 0);
  pixel1 <= pixel_vector(2*DATA_WIDTH - 1 downto DATA_WIDTH);
  pixel2 <= pixel_vector(3*DATA_WIDTH - 1 downto 2*DATA_WIDTH);
  pixel3 <= pixel_vector(4*DATA_WIDTH - 1 downto 3*DATA_WIDTH);
  pixel4 <= pixel_vector(5*DATA_WIDTH - 1 downto 4*DATA_WIDTH);
  pixel5 <= pixel_vector(6*DATA_WIDTH - 1 downto 5*DATA_WIDTH);

  -- ready_tp_send is equal to '1' when all the send_pixel are ready
  ready_to_send <= ready_to_send0 and ready_to_send1 and ready_to_send2 and ready_to_send3 and ready_to_send4 and ready_to_send5;


  send_pixel0 : send_pixel
    generic map (
      DATA_WIDTH => DATA_WIDTH
      )
    port map (
      clk           => clk,
      rst           => rst,
      ready         => ready0,
      new_pixel     => new_pixel,
      pixel_in      => pixel0,
      bit_out       => bit_out0,
      out_enable    => out_enable0,
      ready_to_send => ready_to_send0
      );

  send_pixel1 : send_pixel
    generic map (
      DATA_WIDTH => DATA_WIDTH
      )
    port map (
      clk           => clk,
      rst           => rst,
      ready         => ready1,
      new_pixel     => new_pixel,
      pixel_in      => pixel1,
      bit_out       => bit_out1,
      out_enable    => out_enable1,
      ready_to_send => ready_to_send1
      );

  send_pixel2 : send_pixel
    generic map (
      DATA_WIDTH => DATA_WIDTH
      )
    port map (
      clk           => clk,
      rst           => rst,
      ready         => ready2,
      new_pixel     => new_pixel,
      pixel_in      => pixel2,
      bit_out       => bit_out2,
      out_enable    => out_enable2,
      ready_to_send => ready_to_send2
      );

  send_pixel3 : send_pixel
    generic map (
      DATA_WIDTH => DATA_WIDTH
      )
    port map (
      clk           => clk,
      rst           => rst,
      ready         => ready3,
      new_pixel     => new_pixel,
      pixel_in      => pixel3,
      bit_out       => bit_out3,
      out_enable    => out_enable3,
      ready_to_send => ready_to_send3
      );

  send_pixel4 : send_pixel
    generic map (
      DATA_WIDTH => DATA_WIDTH
      )
    port map (
      clk           => clk,
      rst           => rst,
      ready         => ready4,
      new_pixel     => new_pixel,
      pixel_in      => pixel4,
      bit_out       => bit_out4,
      out_enable    => out_enable4,
      ready_to_send => ready_to_send4
      );

  send_pixel5 : send_pixel
    generic map (
      DATA_WIDTH => DATA_WIDTH
      )
    port map (
      clk           => clk,
      rst           => rst,
      ready         => ready5,
      new_pixel     => new_pixel,
      pixel_in      => pixel5,
      bit_out       => bit_out5,
      out_enable    => out_enable5,
      ready_to_send => ready_to_send5
      );

  send_to_strip0 : send_to_strip
    port map (
      clk        => clk,
      rst        => rst,
      bit_out    => bit_out0,
      out_enable => out_enable0,
      out_led    => out_led0,
      ready      => ready0
      );

  send_to_strip1 : send_to_strip
    port map (
      clk        => clk,
      rst        => rst,
      bit_out    => bit_out1,
      out_enable => out_enable1,
      out_led    => out_led1,
      ready      => ready1
      );

  send_to_strip2 : send_to_strip
    port map (
      clk        => clk,
      rst        => rst,
      bit_out    => bit_out2,
      out_enable => out_enable2,
      out_led    => out_led2,
      ready      => ready2
      );

  send_to_strip3 : send_to_strip
    port map (
      clk        => clk,
      rst        => rst,
      bit_out    => bit_out3,
      out_enable => out_enable3,
      out_led    => out_led3,
      ready      => ready3
      );

  send_to_strip4 : send_to_strip
    port map (
      clk        => clk,
      rst        => rst,
      bit_out    => bit_out4,
      out_enable => out_enable4,
      out_led    => out_led4,
      ready      => ready4
      );

  send_to_strip5 : send_to_strip
    port map (
      clk        => clk,
      rst        => rst,
      bit_out    => bit_out5,
      out_enable => out_enable5,
      out_led    => out_led5,
      ready      => ready5
      );

  speed_controller_inst : speed_controller
    port map(
      clk            => clk,
      rst            => rst,
      infra_sensor   => infra_sensor,
      rnd            => new_image,
      next_column    => next_column,
      columnTimeUnit => columnTimeUnit,
      columnTimeD    => columnTimeD
      );

end;
