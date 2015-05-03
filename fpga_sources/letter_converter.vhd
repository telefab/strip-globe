----------------------------------------------------------------------------------
-- Company: Télécom Bretagne
-- Engineer: Nicolas DUMINY
--
-- Create Date:    15:00:18 11/19/2014
-- Design Name:
-- Module Name:    pwm_generator - rtl
-- Project Name: Globe of persistence of vision
-- Target Devices:
-- Tool versions:
-- Description:
--
-- Dependencies:
--
-- Revision: 
-- Final Revision - Project deliverable
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use ieee.std_logic_unsigned.all;



entity letter_converter is
  port(
    clk, raz          : in  std_logic;
    char_ps           : in  std_logic_vector(7 downto 0);
    posX, posY        : in  std_logic_vector(7 downto 0);
    outX, outY        : out std_logic_vector(7 downto 0);
    din_rts, dout_cts : in  std_logic;
    din_cts, dout_rts : out std_logic
    );
end letter_converter;

architecture rtl of letter_converter is

  type state is (reset, init, listen, ready_to_talk, talk);
  type letter is array (4 downto 0) of std_logic_vector(0 to 3);

  constant xmax          : integer := 100;
  constant ymax          : integer := 48;
  constant letter_width  : integer := 4;
  constant letter_height : integer := 5;

  constant A : letter := (
    "0110",
    "1001",
    "1111",
    "1001",
    "1001");
  constant B : letter := (
    "1110",
    "1001",
    "1111",
    "1001",
    "1110");
  constant C : letter := (
    "0111",
    "1000",
    "1000",
    "1000",
    "0111");

  signal inLetter      : letter := (others => (others => '0')); -- mask corresponding to the caracter read
  signal currentLetter : letter := (others => (others => '0')); 
  signal nextLetter    : letter := (others => (others => '0'));

  signal current_state : state;
  signal next_state    : state;

  signal line : unsigned(3 downto 0) := (others => '0');
  signal col  : unsigned(3 downto 0) := (others => '0');

  signal next_line : unsigned(3 downto 0) := (others => '0');
  signal next_col  : unsigned(3 downto 0) := (others => '0');

  signal addX : unsigned(7 downto 0) := (others => '0');
  signal addY : unsigned(7 downto 0) := (others => '0');

  signal writing : std_logic := '0';
  signal dummy   : std_logic := '0';

  signal line2Read : std_logic_vector(3 downto 0) := (others => '0');

begin

  process(clk, raz)
  begin
    if raz = '1' then
      current_state <= reset;
      col           <= (others => '0');
      line          <= (others => '0');
      currentLetter <= (others => (others => '0'));
    elsif rising_edge(clk) then
      current_state <= next_state;
      col           <= next_col;
      line          <= next_line;
      currentLetter <= nextLetter;
    end if;
  end process;


  process(current_state, col, line, din_rts, dout_cts, inLetter, currentLetter)
  begin
    case current_state is
      when reset =>
        din_cts    <= '0';
        writing    <= '0';
        nextLetter <= (others => (others => '0'));
        next_col   <= col;
        next_line  <= line;
        next_state <= init;
      when init => -- ready to read a caracter
        din_cts    <= '1';
        writing    <= '0';
        nextLetter <= inLetter;
        next_col   <= col;
        next_line  <= line;
        next_state <= listen;
      when listen => -- waiting for a caracter to be read
        nextLetter <= inLetter;
        next_col   <= col;
        next_line  <= line;
        writing    <= '0';
        din_cts    <= '1';
        if din_rts = '1' then
          next_state <= ready_to_talk;
        else
          next_state <= listen;
        end if;
      when ready_to_talk => -- transition state before talking
        nextLetter           <= currentLetter;
        next_col(3 downto 1) <= col(3 downto 1);
        next_col(0)          <= '0';
        next_line            <= line;
        writing              <= '1';
        din_cts              <= '0';
        if dout_cts = '1' then
          next_state           <= talk;
        else
          next_state <= ready_to_talk;
        end if;
      --when talk =>
      --  nextLetter <= currentLetter;
      --  next_col   <= col;
      --  next_line  <= line;
      --  din_cts    <= '0';
      --  writing    <= '1';
      --  if dout_cts = '1' then
      --    next_state <= next_pixel;
      --  else
      --    next_state <= talk;
      --  end if;
      --when next_pixel =>
      --  nextLetter <= currentLetter;
      --  din_cts    <= '0';
      --  writing    <= '1';
      --  if to_integer(col) < letter_width-1 then         
      --    next_col   <= col + 1;
      --    next_line  <= line;
      --    next_state <= talk;
      --  elsif to_integer(line) < letter_height-1 then
      --    next_col   <= (others => '0');
      --    next_line  <= line + 1;
      --    next_state <= talk;
      --  else          
      --    next_col   <= (others => '0');
      --    next_line  <= (others => '0');
      --    next_state <= init;
      --  end if;
    when talk =>
      if dout_cts = '1' then -- receiver ready to receive
        if to_integer(col) < letter_width-1 then
          nextLetter <= currentLetter;
          next_col   <= col + 1;
          next_line  <= line;
          din_cts    <= '0';
          writing    <= '1';
          next_state <= talk;
        elsif to_integer(line) < letter_height-1 then -- end of line
          nextLetter <= currentLetter;
          next_col   <= (others => '0');
          next_line  <= line + 1;
          din_cts    <= '0';
          writing    <= '1';
          next_state <= talk;
        else -- end of mask
          nextLetter <= currentLetter;
          next_col   <= (others => '0');
          next_line  <= (others => '0');
          din_cts    <= '0';
          writing    <= '1';
          next_state <= init;
        end if;
      else -- receiver not ready
        nextLetter <= currentLetter;
        next_col   <= col;
        next_line  <= line;
        din_cts    <= '0';
        writing    <= '1';
        next_state <= talk;
      end if;
    end case;
  end process;

  process(char_ps) -- this process translate the 8 bits of the letter in the corresponding mask
  begin
    case to_integer(unsigned(char_ps)) is
      when 65     => inLetter <= A;
      when 66     => inLetter <= B;
      when 67     => inLetter <= C;
      when others => inLetter <= (others => (others => '0'));
    end case;
  end process;

  process(line, currentLetter) -- this process updates line2read
  begin
    case line is
      when "0000" =>
        line2read <= currentLetter(0);
      when "0001" =>
        line2read <= currentLetter(1);
      when "0010" =>
        line2read <= currentLetter(2);
      when "0011" =>
        line2read <= currentLetter(3);
      when "0100" =>
        line2read <= currentLetter(4);
      when others =>
        line2read <= (others => '0');
    end case;
  end process;

  process(col, line2read) -- this process updates dummy which say if the given pixel belongs to the letter or not
  begin
    case col is
      when "0000" =>
        dummy <= line2read(0);
      when "0001" =>
        dummy <= line2read(1);
      when "0010" =>
        dummy <= line2read(2);
      when "0011" =>
        dummy <= line2read(3);
      when others =>
        dummy <= '0';
    end case;
  end process;

  dout_rts <= dummy and writing; -- if the pixel belongs to the mask and the letter_converter is in the writing state, say the following block we send a pixel to write
  addY     <= unsigned(posY) + col; -- compute the column where to write the pixel
  addX     <= unsigned(posX) + line; -- compute the line where to write the pixel
  outY     <= std_logic_vector(addY mod ymax); -- to not exceed the number of columns
  outX     <= std_logic_vector(addX mod xmax); -- to not exceed the number of lines

end rtl;

