----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 17.11.2014 17:25:01
-- Design Name: 
-- Module Name: send_pixel - rtl 
-- Description: 
-- Receive a pixel from the comumn_reader
-- Send the pixel bit by bit to the send_to_strip
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

use work.globe_package.all;
use work.image_package.all;
use work.display_package.all;

entity send_pixel is
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
end send_pixel;

architecture rtl of send_pixel is

  -- Signal declaration
  type state is (init, idle, ready_state, send_state);
  signal current_state : state;
  signal next_state    : state;

  signal count_bit  : integer range 0 to 7;
  signal color      : integer range 0 to 2;
  signal pixel      : pixel_type;       -- B, R, G
  signal send       : std_logic;
  signal pixel_sent : std_logic;
  
begin
  
  state_machine_control : process(rst, clk)
  begin
    if rst = '1' then
      current_state <= init;
    elsif rising_edge(clk) then
      current_state <= next_state;
    end if;
  end process state_machine_control;

  state_machine : process(current_state, new_pixel, ready, pixel_sent)
  begin
    case current_state is
      when init =>
        out_enable    <= '0';
        ready_to_send <= '0';
        send          <= '0';
        next_state    <= idle;
      when idle =>
        -- Inform the column_reader that the send_pixel is ready to receive a
        -- new pixel
        out_enable    <= '0';
        ready_to_send <= '1';
        send          <= '0';
        if new_pixel = '1' then  -- A new pixel has beeb sent by the column_reader
          ready_to_send <= '0';
          next_state    <= ready_state;
        else
          next_state <= idle;
        end if;
      when ready_state =>
        -- Waiting for the send_to_strip to be ready
        out_enable    <= '0';
        ready_to_send <= '0';
        send          <= '0';
        if ready = '1' then             -- The send_to_strip is ready
          send       <= '1';
          next_state <= send_state;
        else
          next_state <= ready_state;
        end if;
      when send_state =>
        -- Inform the send_to_strip that a new bit as been sent
        out_enable    <= '1';
        ready_to_send <= '0';
        send          <= '0';
        -- If all the pixel has been sent the state machine goes back to
        -- waiting for a new one
        -- else the state machine goes back to waiting for the send_to_strip to
        -- be ready
        if pixel_sent = '1' then
          send       <= '0';
          next_state <= idle;
        else
          next_state <= ready_state;
        end if;
      when others =>
        out_enable    <= '0';
        ready_to_send <= '0';
        send          <= '0';
        next_state    <= idle;
    end case;
  end process state_machine;

  send_pixel : process(clk, rst)
  begin
    if rst = '1' then
      bit_out    <= '0';
      count_bit  <= 0;
      color      <= 0;
      pixel_sent <= '0';
      pixel      <= (others => (others => '0'));
    elsif rising_edge(clk) then
      pixel_sent <= '0';
      if new_pixel = '1' then
        -- Loading the new pixel in a register
        pixel <= std_logic_vector_to_pixel(pixel_in);
      end if;
      if send = '1' then  -- Each time send = '1' a new bit is sent to the send_to_strip
        bit_out <= pixel(color)(count_bit);
        if count_bit < 7 then
          count_bit <= count_bit + 1;
        else
          count_bit <= 0;
          if color < 2 then
            color <= color + 1;
          else
            color      <= 0;
            pixel_sent <= '1';
          end if;
        end if;
      else
        bit_out <= '0';
      end if;
    end if;
  end process send_pixel;
  
end rtl;
