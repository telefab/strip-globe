----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 19.11.2014 15:47:53
-- Design Name: 
-- Module Name: column_reader - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.all;

use work.globe_package.all;
use work.image_package.all;
use work.display_package.all;

entity column_reader is
    port (
        clk         : in    std_logic;
        rst         : in    std_logic;
        strip       : out   strip_type;
        new_strip   : out   std_logic
        );
end column_reader;

architecture Behavioral of column_reader is

    -- Constant declaration
--    constant WAIT_TIME  : integer := 667000/CLK_PERIOD_FPGA;  -- 667 us
    constant WAIT_TIME  : integer := 200000000/CLK_PERIOD_FPGA;  -- 200 ms
    
    -- Signal declaration
    signal count_wait   : integer;
    signal count_strip  : integer range 0 to 19;

begin

    send_strip : process(clk,rst)
    begin
        if rst = '1' then
            new_strip               <= '0';
            count_strip             <= 0;
            count_wait              <= 0;
            strip                   <= (others => (others => (others => '0')));
        elsif rising_edge(clk) then
            new_strip               <= '0';
            count_wait              <= count_wait + 1;
            if count_wait = WAIT_TIME then
                new_strip           <= '1';
                count_wait          <= 0;
                count_strip         <= count_strip + 1;
                case count_strip is
                    when 0 =>
                        strip       <= strip_0; 
                    when 1 =>
                        strip       <= strip_1;
                    when 2 =>
                        strip       <= strip_2;
                    when 3 =>
                        strip       <= strip_3;
                    when 4 =>
                        strip       <= strip_4;
                    when 5 =>
                        strip       <= strip_5; 
                    when 6 =>
                        strip       <= strip_6;
                    when 7 =>
                        strip       <= strip_7;
                    when 8 =>
                        strip       <= strip_8;
                    when 9 =>
                        strip       <= strip_9;
                    when 10 =>
                        strip       <= strip_10;
                    when 11 =>
                        strip       <= strip_11;
                    when 12 =>
                        strip       <= strip_12;
                    when 13 =>
                        strip       <= strip_13;
                    when 14 =>
                        strip       <= strip_14;
                    when 15 =>
                        strip       <= strip_15;
                    when 16 =>
                        strip       <= strip_16;
                    when 17 =>
                        strip       <= strip_17;
                    when 18 =>
                        strip       <= strip_18;          
                    when 19 =>
                        strip       <= strip_19;
                        count_strip <= 0;
                    when others => null;
                end case;
           end if;
        end if;
    end process send_strip;

end Behavioral;
