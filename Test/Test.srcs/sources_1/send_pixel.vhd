----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 17.11.2014 17:25:01
-- Design Name: 
-- Module Name: send_pixel - Behavioral
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

entity send_pixel is
    port (
        clk         : in    std_logic;
        rst         : in    std_logic;
        ready       : in    std_logic;
        new_strip   : in    std_logic;
        strip       : in    strip_type;
        bit_out     : out   std_logic;
        out_enable  : out   std_logic
        );
end send_pixel;

architecture Behavioral of send_pixel is
    
    -- Signal declaration
    signal count_bit    : integer range 0 to 8;
    signal color        : integer range 0 to 2;
    signal pixel        : pixel_type;   -- B, R, G
    signal count_pixel  : integer range 0 to 19;
    signal end_pixel    : std_logic;
    signal out_enable_r : std_logic;
    signal stop         : std_logic;
    signal stop_r       : std_logic;
    
begin
   
    extract_pixel : process(clk,rst)
    begin
        if rst = '1' then
            count_pixel             <= 0;
            pixel                   <= (others => (others => '0'));
            stop                    <= '1';
            stop_r                  <= '1';
        elsif rising_edge(clk) then
            stop                    <= stop_r;      
            if new_strip = '1' then
                stop_r              <= '0';
                count_pixel         <= 0;
            end if;
            if stop_r = '0' then
                pixel               <= strip(count_pixel);
            end if;
            if end_pixel = '1' then
                if count_pixel < NB_PIXEL_BY_STRIP - 1 then
                    count_pixel     <= count_pixel + 1;
                else
                    stop_r            <= '1';
                end if;
            end if;
        end if;
    end process extract_pixel;
    
    send_pixel : process(clk, rst)
        begin
            if rst = '1' then
                bit_out                 <= '0';
                count_bit               <= 0;
                color                   <= 0;
                out_enable              <= '0';
                out_enable_r            <= '0';
                end_pixel               <= '0';
            elsif rising_edge(clk) then
                out_enable              <= '0';
                out_enable_r            <= '0';
                end_pixel               <= '0';
                if stop = '0' then
                    if ready = '1' then
                        if out_enable_r = '0' then
                            bit_out         <= pixel(color)(count_bit);
                            count_bit       <= count_bit + 1;
                            out_enable      <= '1';
                            out_enable_r    <= '1';
                        end if;
                    end if;
                    if count_bit = 8 then
                        count_bit           <= 0;
                        color               <= color + 1;
                        if color = 2 then
                            color           <= 0;
                            end_pixel       <= '1';
                        end if;
                    end if;
                else
                    bit_out <= '0';
                end if;
            end if;
        end process send_pixel;          
        
end Behavioral;
