----------------------------------------------------------------------------------
-- Create Date: 04.11.2014 18:45:48 
-- Module Name: send_to_strip - rtl
-- Description:
-- Recive the pixel from the send_pixel.
-- Generate the LED stripe control signals.
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

use work.globe_package.all;

entity send_to_strip is
  port (
    clk        : in  std_logic;
    rst        : in  std_logic;
    bit_out    : in  std_logic;
    out_enable : in  std_logic;
    out_led    : out std_logic;
    ready      : out std_logic
    );
end send_to_strip;

architecture rtl of send_to_strip is

  -- Constant declaration 
  constant T1H        : integer := 800/CLK_PERIOD_FPGA;  -- 800 ns
  constant T1L        : integer := 450/CLK_PERIOD_FPGA;  -- 450 ns
  constant T0H        : integer := 400/CLK_PERIOD_FPGA;  -- 400 ns
  constant T0L        : integer := 850/CLK_PERIOD_FPGA;  -- 850 ns
  constant TOTAL_TIME : integer := T1H + T0H;            -- 1250 ns

  -- Signal declaration
  type state is (init, idle, send_state);
  signal current_state : state;
  signal next_state    : state;

  signal code_out : std_logic;
  signal send     : std_logic;
  signal bit_sent : std_logic;
  signal count    : unsigned(7 downto 0);

begin
  
  state_machine_control : process(rst, clk)
  begin
    if rst = '1' then
      current_state <= init;
    elsif rising_edge(clk) then
      current_state <= next_state;
    end if;
  end process state_machine_control;

  state_machine : process(current_state, out_enable, bit_sent)
  begin
    case current_state is
      when init =>
        ready      <= '0';
        send       <= '0';
        next_state <= idle;
      when idle =>
        -- Waiting for the send_pixel to be ready
        ready <= '1';
        send  <= '0';
        if out_enable = '1' then        -- the send_pixel is ready
          ready      <= '0';
          next_state <= send_state;
        else
          next_state <= idle;
        end if;
      when send_state =>
        -- The bit receive from the send pixel is sent to the strip
        ready <= '0';
        send  <= '1';
        if bit_sent = '1' then  -- The bit has been sent the state machine goes
          -- back to the waiting state and signals that
          -- the send_to_strip is ready
          send       <= '0';
          next_state <= idle;
        else
          next_state <= send_state;
        end if;
      when others =>
        ready      <= '0';
        send       <= '0';
        next_state <= idle;
    end case;
  end process state_machine;

  -- Generate the code_out signal which describe the output bit (if it is a 1
  -- or a 0).
  create_code_out : process(clk, rst)
  begin
    if rst = '1' then
      code_out <= '0';
    elsif rising_edge(clk) then
      if out_enable = '1' then
        if bit_out = '0' then
          code_out <= '0';
        else
          code_out <= '1';
        end if;
      end if;
    end if;
  end process create_code_out;

  -- Generate the stripe control signals.
  -- The counter are used to generate the output signal with the right time of
  -- 1 and 0
  create_output : process(clk, rst)
  begin
    if rst = '1' then
      count    <= (others => '0');
      out_led  <= '0';
      bit_sent <= '0';
    elsif rising_edge(clk) then
      bit_sent <= '0';
      if send = '1' then
        count <= count + 1;
        if conv_integer(count) < T0H then            -- T0H & T1H
          out_led <= '1';
        elsif conv_integer(count) < T1H then
          if code_out = '0' then                     -- T0L
            out_led <= '0';
          else                                       -- T1H
            out_led <= '1';
          end if;
        elsif conv_integer(count) < TOTAL_TIME then  -- T0L & T1L
          out_led <= '0';
        else
          out_led  <= '0';
          count    <= (others => '0');
          bit_sent <= '1';
        end if;
      else
        out_led <= '0';
      end if;
    end if;
  end process create_output;
  
end rtl;
