----------------------------------------------------------------------------------
-- Receives pixels to send to an APA102 strip.
-- All pixels for the length of the strip have to be sent continuously
-- with no break.
-- If pixel_valid is 0 and pixel_valid is 1 during one clock cycle, it means
-- that the whole strip has been sent.
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity apa102_strip_standalone is
  generic (
    -- Width of data for one pixel
    PIXEL_WIDTH   : integer := 24;
    -- Strip length in pixels
    STRIP_LENGTH  : integer := 30;
    -- Delay to change the strip colors (1s)
    CHANGE_DELAY  : integer := 1000*1000*1000/8;
    -- Number of color modes
    COLOR_MODES   : integer := 3
  ); 
  port (
    clk           : in  std_logic;
    rst           : in  std_logic;
    -- Output to the strip
    strip_clk     : out std_logic;
    strip_data    : out std_logic
  );
end apa102_strip_standalone;

architecture rtl of apa102_strip_standalone is

  -- Connection to the strip driver
  signal pixel_ready   : std_logic;
  signal pixel_in      : std_logic_vector(PIXEL_WIDTH-1 downto 0);
  signal pixel_valid   : std_logic;

  -- Current pixel counter
  signal pixel_ctr          : integer range 0 to STRIP_LENGTH-1;

  -- Current pixel counter
  signal delay_ctr          : integer range 0 to CHANGE_DELAY-1;

  -- Current mode counter
  signal mode_ctr           : integer range 0 to COLOR_MODES-1;
  
begin

    -- Instantiate the driver
   driver: entity work.apa102_strip GENERIC MAP (
    PIXEL_WIDTH => PIXEL_WIDTH
   )
   PORT MAP (
    clk         => clk         ,
    rst         => rst         ,
    pixel_ready => pixel_ready ,
    pixel_in    => pixel_in    ,
    pixel_valid => pixel_valid ,
    strip_clk   => strip_clk   ,
    strip_data  => strip_data
  );

  -- Sent pixel counter
  pixel_ctr_p : process(rst, clk) begin
    if rst='1' then
      pixel_ctr <= 0;
      pixel_valid <= '1';
      mode_ctr <= 0;
      pixel_in <= (others => '0');
    elsif rising_edge(clk) then
      if pixel_ready = '1' and pixel_valid = '1' then
        if pixel_ctr = STRIP_LENGTH-1 then
          pixel_ctr <= 0;
          pixel_valid <= '0';
          if mode_ctr = 0 then
            pixel_in <= x"0000FF";
          elsif mode_ctr = 1 then
            pixel_in <= x"00FF00";
          else 
            pixel_in <= x"FF0000";
          end if;
        else 
          pixel_ctr <= pixel_ctr + 1;
          pixel_in <= pixel_in(7 downto 0) & pixel_in(23 downto 8);
        end if;
      elsif delay_ctr = 0 then
        pixel_valid <= '1';
        if mode_ctr = COLOR_MODES-1 then
          mode_ctr <= 0;
        else
          mode_ctr <= mode_ctr + 1;
        end if;
      end if;
    end if;
  end process pixel_ctr_p;

  -- Delay counter
  delay_ctr_p : process(rst, clk) begin
    if rst='1' then
      delay_ctr <= 0;
    elsif rising_edge(clk) then
      if delay_ctr = CHANGE_DELAY-1 then
        delay_ctr <= 0;
      else 
        delay_ctr <= delay_ctr + 1;
      end if;
    end if;
  end process delay_ctr_p;
  
end rtl;
