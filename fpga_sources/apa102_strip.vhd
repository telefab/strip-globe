----------------------------------------------------------------------------------
-- Receives pixels to send to an APA102 strip.
-- All pixels for the length of the strip have to be sent continuously
-- with no break.
-- If pixel_valid is 0 and pixel_ready is 1 during one clock cycle, it means
-- that the whole strip has been sent.
-- Strip data is changed at the strip clock falling edge to limit the effects
-- of delays on the wires.
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

use work.image_package.all;

entity apa102_strip is
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
end apa102_strip;

architecture rtl of apa102_strip is

  -- Number of clock cycles to send one bit of data (minimum 2)
  constant BIT_DURATION   : integer := 60;
  constant COMPNT_BITS    : integer := 8;
  constant PIXEL_COMPNTS  : integer := 4;

  -- Correspondance of component indexes
  constant start_c        : integer := 0;
  constant blue_c         : integer := 1; 
  constant green_c        : integer := 2;  
  constant red_c          : integer := 3;  

  -- Clock duration counter
  signal clk_ctr          : integer range 0 to BIT_DURATION-1;

  -- Signal indicating that one bit of data is sent to the strip
  signal strip_clk_int      : std_logic;
  signal strip_send_rythm   : std_logic;

  -- Decoded pixel
  signal pixel            : pixel_type; -- B, R, G
  signal pixel_ready_int  : std_logic;

  -- Pixel components counter
  signal compnt_ctr       : integer range 0 to PIXEL_COMPNTS-1;
  signal compnt_ctr_en    : std_logic;
  signal compnt_ctr_done  : std_logic;

  -- Bits counter for one component
  signal bit_ctr          : integer range 0 to COMPNT_BITS-1;
  signal bit_ctr_en       : std_logic;
  signal bit_ctr_done     : std_logic;

  -- Data sending control
  signal send_data        : std_logic;
  signal send_start       : std_logic;

  -- FSM
  type state_type is (idle_s, send_s, start_strip_s, end_strip_s);
  signal state, state_nxt : state_type;
  
begin

  -- Read new pixels
  pixel_ready <= pixel_ready_int;
  pixel_p : process(clk) begin
    if rising_edge(clk) then
      if (pixel_valid = '1' and pixel_ready_int = '1') then
        pixel <= std_logic_vector_to_pixel(pixel_in);
      end if;
    end if;
  end process pixel_p;

  -- Strip clock counter
  strip_send_rythm <= '1' when clk_ctr = BIT_DURATION-1 else '0';
  clk_ctr_p : process(rst, clk) begin
    if rst='1' then
      clk_ctr <= 0;
    elsif rising_edge(clk) then
      if (clk_ctr = BIT_DURATION-1) then
        clk_ctr <= 0;
      else 
        clk_ctr <= clk_ctr + 1;
      end if;
    end if;
  end process clk_ctr_p;

  -- Strip clock generation
  strip_clk <= strip_clk_int;
  clk_gen_p : process(clk) begin
    if rising_edge(clk) then
      if clk_ctr = BIT_DURATION/2-1 then
        strip_clk_int <= '1';
	  elsif clk_ctr = BIT_DURATION-1 then
        strip_clk_int <= '0';
      end if;
    end if;
  end process clk_gen_p;

  -- Components counter
  compnt_ctr_done <= '1' when compnt_ctr = PIXEL_COMPNTS-1 else '0';
  compnt_ctr_p : process(rst, clk) begin
    if rst='1' then
      compnt_ctr <= 0;
    elsif rising_edge(clk) then
      if compnt_ctr_en = '1' then
        if compnt_ctr_done = '1' then
          compnt_ctr <= 0;
        else 
          compnt_ctr <= compnt_ctr + 1;
        end if;
      end if;
    end if;
  end process compnt_ctr_p;

  -- Bits counter
  bit_ctr_done <= '1' when bit_ctr = COMPNT_BITS-1 else '0';
  bit_ctr_p : process(rst, clk) begin
    if rst='1' then
      bit_ctr <= 0;
    elsif rising_edge(clk) then
      if bit_ctr_en = '1' then
        if bit_ctr_done = '1' then
          bit_ctr <= 0;
        else 
          bit_ctr <= bit_ctr + 1;
        end if;
      end if;
    end if;
  end process bit_ctr_p;

  -- Send data to the strip
  send_p : process(rst, clk) begin
    if rst = '1' then
      strip_data <= '1';
    elsif rising_edge(clk) then
      if strip_send_rythm = '1' then
        if send_start = '1' then
          strip_data <= '0';
        elsif send_data = '1' then
          case compnt_ctr is
            when start_c =>
              strip_data <= '1';
            when blue_c =>
              strip_data <= pixel(0)(bit_ctr);
            when green_c =>
              strip_data <= pixel(2)(bit_ctr);
            when red_c =>
              strip_data <= pixel(1)(bit_ctr);
          end case;
        else 
          strip_data <= '1';
        end if;
      end if;
    end if;
  end process send_p;
  
  -- FSM
  fsm_ctrl : process(rst, clk) begin
    if rst = '1' then
      state <= idle_s;
    elsif rising_edge(clk) then
      state <= state_nxt;
    end if;
  end process fsm_ctrl;

  fsm : process(state, strip_send_rythm, compnt_ctr_done, bit_ctr_done, pixel_valid) begin
    state_nxt <= state;
    pixel_ready_int <= '0';
    compnt_ctr_en <= '0';
    bit_ctr_en <= '0';
    send_data <= '0';
    send_start <= '0';
    case state is
      when idle_s =>
        -- Waiting for new pixels for a new strip refresh
        pixel_ready_int <= '1';
        if pixel_valid = '1' then
          state_nxt <= start_strip_s;
        end if;
      when start_strip_s =>
        -- First frame indicating that new pixels will be sent
        send_start <= '1';
		  if strip_send_rythm = '1' then
          bit_ctr_en <= '1';
          compnt_ctr_en <= bit_ctr_done;
          if compnt_ctr_done = '1' and bit_ctr_done = '1' then
            state_nxt <= send_s;
          end if;
        end if;
      when send_s =>
        -- Send one pixel of a strip
        send_data <= '1';
		  if strip_send_rythm = '1' then
          bit_ctr_en <= '1';
          compnt_ctr_en <= bit_ctr_done;
          if compnt_ctr_done = '1' and bit_ctr_done = '1' then
            -- Go to next pixel
            pixel_ready_int <= '1';
            if pixel_valid = '0' then
              state_nxt <= end_strip_s;
            end if;
          end if;
        end if;
      when end_strip_s =>
        -- Send one frame of ones to make sure data has been sent to the end of a strip
		  if strip_send_rythm = '1' then
          bit_ctr_en <= '1';
          compnt_ctr_en <= bit_ctr_done;
          if compnt_ctr_done = '1' and bit_ctr_done = '1' then
            state_nxt <= idle_s;
          end if;
        end if;
    end case;
  end process fsm;
  
end rtl;
