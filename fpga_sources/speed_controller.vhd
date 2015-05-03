----------------------------------------------------------------------------------
-- Control the speed of the display depending on the sensor.
-- This version is simple: new image when the sensor is read, column delays 
-- computed from the last round. The globe is considered idle and deactivated
-- if it turns slower than MAX_CYCLES per round.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;

use work.image_package.all;

entity speed_controller is
  port(
    clk            : in  std_logic;
    rst            : in  std_logic;
    round_sensor   : in  std_logic;
    next_round     : out std_logic;
    next_column    : out std_logic
  );
end speed_controller;

architecture rtl of speed_controller is

  -- Indicate if the globe is idle
  signal idle : std_logic;
  -- Delayed round sensor value
  signal round_sensor_reg : std_logic;
  -- Delayed round sensor value
  signal round_sensor_reg2 : std_logic;
  -- New round detected by the sensor
  signal round_detected   : std_logic;
  -- Computed that a new column should end
  signal column_finished   : std_logic;
  -- Used as a divider by the number of columns
  signal column_ctr       : integer range 0 to NB_COLUMN-1;
  -- Time counter for the columns (unit: clock cycles)
  signal col_time_ctr     : integer range 0 to MAX_CYCLES_COL-1;
  -- Time counter for the round (unit: number of columns)
  signal round_time_ctr   : integer range 0 to MAX_CYCLES_COL-1;
  -- Time taken by the last round (unit: number of columns)
  signal last_round_time  : integer range 0 to MAX_CYCLES_COL-1;

begin

  -- A new round is detected when the sensor falls to 0
  round_detected <= '1' when (round_sensor_reg2 = '1' and round_sensor_reg = '0') else '0';
  process(clk) begin
    if rising_edge(clk) then
      round_sensor_reg2 <= round_sensor_reg;
      round_sensor_reg <= round_sensor;
    end if;
  end process;

  -- Idle state management
  process(clk, rst) begin
    if rst = '1' then
      idle <= '1';
    elsif rising_edge(clk) then
      if round_detected = '1' and last_round_time > 0 then
        -- New round: not idle
        idle <= '0';
      elsif round_time_ctr = MAX_CYCLES_COL-1 then
        -- Very slow: idle
        idle <= '1';
      end if;
    end if;
  end process;

  -- Count constantly the number of columns
  process(clk, rst) begin
    if rst = '1' then
      column_ctr <= 0;
    elsif rising_edge(clk) then
      if column_ctr < NB_COLUMN-1 then
        column_ctr <= column_ctr + 1;
      else
        column_ctr <= 0;
      end if;
    end if;
  end process;

  -- Count the time to measure one round
  process(clk, rst) begin
    if rst = '1' then
      round_time_ctr <= 0;
    elsif rising_edge(clk) then
      if round_detected = '1' then
        round_time_ctr <= 0;
      elsif column_ctr = NB_COLUMN-1 then
        if round_time_ctr < MAX_CYCLES_COL-1 then
          round_time_ctr <= round_time_ctr + 1;
        end if;
      end if;
    end if;
  end process;
  
  -- Save the round time
  process(clk, rst) begin
   if rst = '1' then
     last_round_time <= 0;
   elsif rising_edge(clk) then
    if round_detected = '1' then
      last_round_time <= round_time_ctr;
      end if;
    end if;
  end process;

  -- Count the time to measure one column
  column_finished <= '1' when (col_time_ctr = last_round_time) else '0';
  process(clk, rst) begin
    if rst = '1' then
      col_time_ctr <= 0;
    elsif rising_edge(clk) then
      if column_finished = '1' then
        col_time_ctr <= 0;
      else
        col_time_ctr <= col_time_ctr + 1;
      end if;
    end if;
  end process;

  -- Output
  next_round <= '1' when (round_detected = '1' and idle = '0') else '0';
  next_column <= '1' when (column_finished = '1' and idle = '0') else '0';

end rtl;
