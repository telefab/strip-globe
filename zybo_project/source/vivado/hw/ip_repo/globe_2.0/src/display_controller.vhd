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
    strip_data_0   : out std_logic;
    strip_clk_0    : out std_logic;
    strip_data_1   : out std_logic;
    strip_clk_1    : out std_logic;
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
      pixel_vector : out std_logic_vector(NB_STRIP*DATA_WIDTH-1 downto 0);
      new_pixel    : out std_logic;
      image_read   : out std_logic
      );
  end component column_reader;

  component speed_controller
    port(
      clk            : in  std_logic;
      rst            : in  std_logic;
      round_sensor   : in  std_logic;
      next_round     : out std_logic;
      next_column    : out std_logic
      );
  end component speed_controller;
  
    component apa102_strip
  generic (
    -- Width of data for one pixel
    PIXEL_WIDTH : integer
  ); 
  port (
    clk           : in  std_logic;
    rst           : in  std_logic;
    -- A pixel is taken into account when pixel_ready and pixel_valid are 1 during one clock cycle
    pixel_ready   : out  std_logic;
    pixel_in      : in std_logic_vector(PIXEL_WIDTH-1 downto 0);
    pixel_valid   : in  std_logic;
    -- Output to the strip
    strip_clk     : out std_logic;
    strip_data    : out std_logic
  );
  end component;
    constant NB_STRIP : integer := 2;

  -- Signal declaration
  signal new_pixel    : std_logic;
  signal pixel_vector : std_logic_vector(NB_STRIP*DATA_WIDTH-1 downto 0);

  signal pixel0 : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal pixel1 : std_logic_vector(DATA_WIDTH-1 downto 0);

  signal ready_to_send  : std_logic;
  signal ready_to_send0 : std_logic;
  signal ready_to_send1 : std_logic;

  signal new_image   : std_logic;
  signal next_column : std_logic;
  
begin

  -- Component mapping
  column_reader_inst : column_reader
    generic map (
      DATA_WIDTH        => DATA_WIDTH,
      ADDR_WIDTH        => ADDR_WIDTH,
      NB_STRIP          => NB_STRIP,
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

  -- ready_tp_send is equal to '1' when all the send_pixel are ready
  ready_to_send <= ready_to_send0 and ready_to_send1;

        strip0: apa102_strip
        generic map(
              -- Width of data for one pixel
              PIXEL_WIDTH => DATA_WIDTH
            ) 
            port map(
              clk           => clk,
              rst           => rst,
              -- A pixel is taken into account when pixel_ready and pixel_valid are 1 during one clock cycle
              pixel_ready   => ready_to_send0,
              pixel_in      => pixel0, --X"00FF00",
              pixel_valid   => new_pixel,
              -- Output to the strip
              strip_clk     => strip_clk_0,
              strip_data    => strip_data_0
           );
    
        strip1: apa102_strip  
          generic map(
            -- Width of data for one pixel
            PIXEL_WIDTH => DATA_WIDTH
          ) 
          port map(
            clk           => clk,
            rst           => rst,
            -- A pixel is taken into account when pixel_ready and pixel_valid are 1 during one clock cycle
            pixel_ready   => ready_to_send1,
            pixel_in      => X"000000", --pixel1, --X"FF0000",
            pixel_valid   => new_pixel,
            -- Output to the strip
            strip_clk     => strip_clk_1,
            strip_data    => strip_data_1
            );

  speed_controller_inst : speed_controller
    port map(
      clk            => clk,
      rst            => rst,
      round_sensor   => infra_sensor,
      next_round     => new_image,
      next_column    => next_column
      );

end;
