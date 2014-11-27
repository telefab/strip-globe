library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

use work.globe_package.all;
use work.image_package.all;
use work.display_package.all;

entity display_test is
    port( 
        clk                 : in   std_logic;
        rst                 : in   std_logic;
        out_led             : out  std_logic
        );
end display_test;

architecture Behavioral of display_test is

    -- Component declaration
    component column_reader is
        port (
            clk         : in    std_logic;
            rst         : in    std_logic;
            strip       : out   strip_type;
            new_strip   : out   std_logic
            );
    end component column_reader;
    
    component send_pixel
        port (
            clk         : in    std_logic;
            rst         : in    std_logic;
            ready       : in    std_logic;
            new_strip   : in    std_logic;
            strip       : in    strip_type;
            bit_out     : out   std_logic;
            out_enable  : out   std_logic
            );
    end component send_pixel;
    
    component send_to_stripe
        port ( 
            clk         : in    std_logic;
            rst         : in    std_logic;
            bit_out     : in    std_logic;
            out_enable  : in    std_logic;
            out_led     : out   std_logic;
            ready       : out   std_logic
            );
    end component send_to_stripe;
    
    -- Signal declaration
    signal bit_out      : std_logic;
    signal out_enable   : std_logic;
    signal ready        : std_logic;
    signal new_strip    : std_logic;
    signal strip        : strip_type;

begin

    -- Component mapping
    column_reader_inst : column_reader
        port map (
            clk         =>  clk,
            rst         =>  rst,
            strip       =>  strip,
            new_strip   =>  new_strip
            );
    
    send_pixel_inst : send_pixel
        port map (
            clk         =>  clk,
            rst         =>  rst,
            ready       =>  ready,
            new_strip   =>  new_strip,
            strip       =>  strip,
            bit_out     =>  bit_out,
            out_enable  =>  out_enable
            );
        
    send_to_stripe_inst : send_to_stripe
        port map (
            clk         =>  clk,
            rst         =>  rst,
            bit_out     =>  bit_out,
            out_enable  =>  out_enable,
            out_led     =>  out_led,
            ready       =>  ready
            );

end Behavioral;
