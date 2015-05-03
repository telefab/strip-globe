----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:00:18 11/19/2014 
-- Design Name: 
-- Module Name:    pwm_generator - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

use work.globe_package.all;
use work.image_package.all;


entity speed_controller is
  port(
    clk            : in  std_logic;
    rst            : in  std_logic;
    infra_sensor   : in  std_logic;
    rnd            : out std_logic;
    next_column    : out std_logic;
    columnTimeUnit : out std_logic_vector(COMPTEUR_RND-1 downto 0);
    columnTimeD    : out std_logic_vector(COMPTEUR_RND-1 downto 0)
    );
end speed_controller;


architecture rtl of speed_controller is

  type timer is array (7 downto 0) of unsigned(2*COMPTEUR_RND downto 0);
  signal lastRndTime                        : timer;
  signal nextRndTime                        : timer;
  signal meanRndTime                        : unsigned(2*COMPTEUR_RND downto 0)   := (others => '0');
  signal minRndTime                         : unsigned(2*COMPTEUR_RND downto 0)   := (others => '0');
  signal maxRndTime                         : unsigned(2*COMPTEUR_RND downto 0)   := (others => '0');
  signal sumRndTime, cor5, cor6             : unsigned(2*COMPTEUR_RND+2 downto 0) := (others => '0');
  signal add1, add2, add3, add4             : unsigned(2*COMPTEUR_RND downto 0)   := (others => '0');
  signal add5, add6, cor1, cor2, cor3, cor4 : unsigned(2*COMPTEUR_RND+1 downto 0) := (others => '0');
  signal deltaRndTime                       : unsigned(2*COMPTEUR_RND-3 downto 0) := (others => '0');
  signal deltaMinTime                       : unsigned(2*COMPTEUR_RND-1 downto 0) := (others => '0');

  signal count100C    : unsigned(COMPTEUR100C_SIZE-1 downto 0) := (others => '0'); -- count to 100 cycles
  signal countUnit    : unsigned(COMPTEUR_RND-1 downto 0)      := (others => '0'); -- count the number of times the count100c has counted to 100
  signal countD       : unsigned(COMPTEUR_RND-1 downto 0)      := (others => '0'); -- count the number of times the countUnit has counted to its maximum
  signal columnUnit   : unsigned(COMPTEUR_RND-1 downto 0)      := (others => '0'); -- value of the countUnit counter at the end of the last round
  signal columnD      : unsigned(COMPTEUR_RND-1 downto 0)      := (others => '0'); -- value of the countD counter at the end of the last round
  signal countForColU : unsigned(COMPTEUR_RND-1 downto 0)      := (others => '0'); -- count to columnUnit after countForColD reached columnD
  signal countForColD : unsigned(COMPTEUR_RND-1 downto 0)      := (others => '0'); -- count to columnD
  signal rndFiltered  : std_logic                              := '0';
  signal rndMade      : std_logic                              := '0';
  signal fastEnough   : std_logic                              := '0';
  signal read2round   : unsigned(3 downto 0)                   := "0000";
  signal missXRnd     : unsigned(3 downto 0)                   := "0000";

begin

  columnTimeUnit <= std_logic_vector(columnUnit);
  columnTimeD    <= std_logic_vector(columnD);

  process(clk, rst) -- this process computes the limits of round time for filtering the sensor signal
  begin
    if rst = '1' then
      nextRndTime <= (others => (others => '0'));
      add1         <= (others => '0');
      add2         <= (others => '0');
      add3         <= (others => '0');
      add4         <= (others => '0');
      add5         <= (others => '0');
      add6         <= (others => '0');
      cor1         <= (others => '0');
      cor2         <= (others => '0');
      cor3         <= (others => '0');
      cor4         <= (others => '0');
      cor5         <= (others => '0');
      cor6         <= (others => '0');
      sumRndTime   <= (others => '0');
      meanRndTime  <= (others => '0');
      deltaRndTime <= (others => '0');
      deltaMinTime <= (others => '0');
      minRndTime   <= (others => '0');
      maxRndTime   <= (others => '0');
    elsif rising_edge(clk) then
	  -- save the 8 last values of round time
      nextRndTime(7)                                        <= lastRndTime(6);
      nextRndTime(6)                                        <= lastRndTime(5);
      nextRndTime(5)                                        <= lastRndTime(4);
      nextRndTime(4)                                        <= lastRndTime(3);
      nextRndTime(3)                                        <= lastRndTime(2);
      nextRndTime(2)                                        <= lastRndTime(1);
      nextRndTime(1)                                        <= lastRndTime(0);
      nextRndTime(0) (COMPTEUR_RND-1 downto 0)              <= countUnit;
      nextRndTime(0) (2*COMPTEUR_RND-1 downto COMPTEUR_RND) <= countD;
      nextRndTime(0) (2*COMPTEUR_RND)                       <= '0';

	  -- first additions to compute the mean round time
      add1 <= lastRndTime(7) + lastRndTime(6);
      add2 <= lastRndTime(5) + lastRndTime(4);
      add3 <= lastRndTime(3) + lastRndTime(2);
      add4 <= lastRndTime(1) + lastRndTime(0);

	  -- add one bit for not decreasing accuration
      cor1(2*COMPTEUR_RND downto 0) <= add1;
      cor2(2*COMPTEUR_RND downto 0) <= add2;
      cor3(2*COMPTEUR_RND downto 0) <= add3;
      cor4(2*COMPTEUR_RND downto 0) <= add4;
      cor1(2*COMPTEUR_RND+1)        <= '0';
      cor2(2*COMPTEUR_RND+1)        <= '0';
      cor3(2*COMPTEUR_RND+1)        <= '0';
      cor4(2*COMPTEUR_RND+1)        <= '0';

	  -- Second addition to compute the mean round time
      add5 <= cor1 + cor2;
      add6 <= cor3 + cor4;
    
	  -- add one bit for not decreasing accuracy
      cor5(2*COMPTEUR_RND+1 downto 0) <= add5;
      cor6(2*COMPTEUR_RND+1 downto 0) <= add6;
      cor5(2*COMPTEUR_RND+2)          <= '0';
      cor6(2*COMPTEUR_RND+2)          <= '0';
    
	  -- Last addition to compute the mean round time
      sumRndTime                             <= cor5 + cor6;
	  -- Calculate the mean round time
      meanRndTime(2*COMPTEUR_RND-1 downto 0) <= sumRndTime(2*COMPTEUR_RND+2 downto 3);
	  -- Add 1 bit for not decreasing accuracy on the min and max round time
      meanRndTime(2*COMPTEUR_RND)            <= '0';
	  
      deltaRndTime                           <= meanRndTime(2*COMPTEUR_RND downto 3);
      deltaMinTime                           <= meanRndTime(2*COMPTEUR_RND downto 1);
      minRndTime                             <= meanRndTime - deltaMinTime; -- Minimum round time for the current round, equal to half mean round time
      maxRndTime                             <= meanRndTime + deltaRndTime; -- Maximum round time for the current round, equal to 9/8 * mean round time
    end if;
  end process;
    
  rnd <= rndFiltered;

  roundCounters : process(clk, rst)
  begin
    if rst = '1' then
      lastRndTime <= (others => (others => '0'));
      count100C   <= (others => '0');
      countUnit   <= (others => '0');
      countD      <= (others => '0');
      columnUnit  <= (others => '0');
      columnD     <= (others => '0');
      rndMade     <= '0';
      rndFiltered <= '0';
      fastEnough  <= '0';
      read2round  <= "0000";
      missXRnd    <= "0000";
    elsif rising_edge(clk) then
      if infra_sensor = '1' and rndMade = '0' then
        missXRnd <= "0000"; -- reset the number of round missed
        if conv_integer(countD) < MAX_RND_TIME then -- used to not display images until the globe has reached a certain speed
          case read2round is -- waiting to have 8 values of round time for being able to compute the max and min round time
            when "0000" => read2round <= "0001";
            when "0001" => read2round <= "0010";
            when "0010" => read2round <= "0011";
            when "0011" => read2round <= "0100";
            when "0100" => read2round <= "0101";
            when "0101" => read2round <= "0110";
            when "0110" => read2round <= "0111";
            when "0111" => read2round <= "1000";
            when others =>
              if nextRndTime(0) > minRndTime then -- to eliminate false round signals
                fastEnough  <= '1';
                rndFiltered <= '1';
              end if;
          end case;
        end if;
        lastRndTime <= nextRndTime;
        rndMade     <= '1'; -- to not count twice a round signal
        if nextRndTime(0) > minRndTime then  -- ignore parasites on the infrared barrier
          columnUnit <= countUnit;
          columnD    <= countD;
          count100C  <= (others => '0');
          countUnit  <= (others => '0');
          countD     <= (others => '0');
        else
          rndFiltered <= '0';
          if conv_integer(count100C) > (NB_COLUMN-2) then
            count100C <= (others => '0');
            if conv_integer(countUnit) = MAX_COUNT_RND then
              if conv_integer(countD) < MAX_RND_TIME then
                countD    <= countD + 1;
                countUnit <= (others => '0');
              else
                fastEnough <= '0';
                read2round <= "0000";
              end if;
            else
              countUnit <= countUnit + 1;
            end if;
          else
            count100C <= count100C + 1;
          end if;
        end if;
      else
        if conv_integer(count100C) > (NB_COLUMN-2) then 
          count100C <= (others => '0');
          --if conv_integer(countUnit) = MAX_COUNT_RND then
          --  if conv_integer(countD) < MAX_RND_TIME then
          --    countD    <= countD + 1;
          --    countUnit <= (others => '0');
          --  else
          --    fastEnough <= '0';
          --  end if;
          --else
          --  countUnit <= countUnit + 1;
          --end if;
          if nextRndTime(0) > maxRndTime and conv_integer(read2round) = 8 then  -- missed a round
            if conv_integer(missXRnd) = 8 then -- if 8 rounds missed, reset the speed_controller
              read2Round <= "0000";
              fastEnough <= '0';
            end if;
            rndFiltered <= '1';
            missXRnd    <= missXRnd + 1;
            lastRndTime <= nextRndTime;
            rndMade     <= '1';
            columnUnit  <= meanRndTime(COMPTEUR_RND-1 downto 0);
            columnD     <= meanRndTime(2*COMPTEUR_RND-1 downto COMPTEUR_RND);
            count100C   <= (others => '0');
            countUnit   <= (others => '0');
            countD      <= (others => '0');
          else
            rndFiltered <= '0';
            if infra_sensor = '0' then
              rndMade <= '0';
            end if;
            if conv_integer(countUnit) = MAX_COUNT_RND then
              if conv_integer(countD) < MAX_RND_TIME then
                countD    <= countD + 1;
                countUnit <= (others => '0');
              else
                fastEnough <= '0';
                read2round <= "0000";
              end if;
            else
              countUnit <= countUnit + 1;
            end if;
          end if;
        else
          rndFiltered <= '0';
          if infra_sensor = '0' then
            rndMade <= '0';
          end if;
          count100C <= count100C + 1;
        end if;
      end if;
    end if;
  end process;

  columnSynchro : process(clk, rst) -- this process manages two counters which count to the last round time values and generate the next_column signal
  begin
    if rst = '1' then
      countForColU <= (others => '0');
      countForColD <= (others => '0');
      next_column  <= '0';
    elsif rising_edge(clk) then
      if rndFiltered = '1' then
        countForColU <= (others => '0');
        countForColD <= (others => '0');
        next_column  <= '0';
      elsif fastEnough = '1' then
        if countForColD = columnD and countForColU = columnUnit then
          next_column  <= '1';
          countForColU <= (others => '0');
          countForColD <= (others => '0');
        else
          next_column <= '0';
          if conv_integer(countForColU) = MAX_COUNT_RND then
            if conv_integer(countForColD) /= MAX_COUNT_RND then
              countForColD <= countForColD + 1;
              countForColU <= (others => '0');
            end if;
          else
            countForColU <= countForColU + 1;
          end if;
        end if;
      else
        next_column <= '0';
      end if;
    end if;
  end process;


end rtl;
