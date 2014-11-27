----------------------------------------------------------------------------------
-- Create Date: 04.11.2014 18:45:48 
-- Module Name: send_ruban - Behavioral
-- Project Name: 
-- Target Devices: Zynq 7010
-- Description: 
-- Generate the stripe control signals.
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.all;

use work.globe_package.all;

entity send_to_stripe is
    port ( 
        clk         : in    std_logic;
        rst         : in    std_logic;
        bit_out     : in    std_logic;
        out_enable  : in    std_logic;
        out_led     : out   std_logic;
        ready       : out   std_logic
        );
end send_to_stripe;

architecture Behavioral of send_to_stripe is

    -- Constant declaration 
    constant T1H        : integer   := 800/CLK_PERIOD_FPGA;  -- 800 ns
    constant T1L        : integer   := 450/CLK_PERIOD_FPGA;  -- 450 ns
    constant T0H        : integer   := 400/CLK_PERIOD_FPGA;  -- 400 ns
    constant T0L        : integer   := 850/CLK_PERIOD_FPGA;  -- 850 ns
    constant TOTAL_TIME : integer   := T1H + T0H;            -- 1250 ns

    -- Signal declaration
    signal code_out         : std_logic;
    signal next_bit_ready   : std_logic;
    signal send             : std_logic;
    signal start_sending    : std_logic;
    signal count            : unsigned(10 downto 0);

begin

    -- Generate the code_out signal which describe the coding of the output bit.
    create_code_out : process(clk, rst)
    begin
        if rst = '1' then
            code_out            <= '0';
            ready               <= '0';
            next_bit_ready      <= '0';
        elsif rising_edge(clk) then
            ready               <= '0';
            if next_bit_ready = '0' then
                if send = '0' then
                    ready           <= '1';
                end if;
            end if;
            
            if out_enable = '1' then
                ready           <= '0';
                if bit_out = '0' then
                    code_out    <= '0';
                else
                    code_out    <= '1';
                end if;
                next_bit_ready  <= '1';
            end if;

            if start_sending = '1' then
                next_bit_ready  <= '0';
            end if;
        end if;
    end process create_code_out;

    -- Generate the stripe control signals.
    create_output : process(clk, rst)
    begin
        if rst = '1' then
            count                   <= (others => '0');
            out_led                 <= '0';
            send                    <= '0';
            start_sending           <= '0';
        elsif rising_edge(clk) then
            if send = '1' then
                start_sending       <= '0';
                count               <= count + 1;
                if conv_integer(count) < T0H then               -- T0H & T1H
                    out_led         <= '1';
                elsif conv_integer(count) < T1H then
                    if code_out = '0' then                      -- T0L
                        out_led     <= '0';
                    else                                        -- T1H
                        out_led     <= '1';
                    end if;
                elsif conv_integer(count) < TOTAL_TIME then    -- T0L & T1L
                    out_led         <= '0';
                else
                    out_led         <= '0';
                    count           <= (others => '0');
                    send            <= '0';
                end if;
            else                
                if next_bit_ready = '1' then
                    send            <= '1';
                    start_sending   <= '1';
                end if;
            end if;
        end if;
    end process create_output;
         
end Behavioral;
