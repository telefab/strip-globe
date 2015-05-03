----------------------------------------------------------------------------------
-- Receives pixels to send to an APA102 strip.
-- All pixels for the length of the strip have to be sent continuously
-- with no break.
-- If pixel_valid is 0 and pixel_valid is 1 during one clock cycle, it means
-- that the whole strip has been sent.
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- use work.globe_package.all;

entity apa102_strip_tb is
end apa102_strip_tb;

architecture rtl of apa102_strip_tb is

  -- Test module links
  signal clk           : std_logic := '0';
  signal rst           : std_logic := '1';
  signal pixel_ready   : std_logic;
  signal pixel_in      : std_logic_vector(23 downto 0);
  signal pixel_valid   : std_logic := '0';
  signal strip_clk     : std_logic;
  signal strip_data    : std_logic;

begin

  -- Instantiate the Unit Under Test (UUT)
   uut: entity work.apa102_strip GENERIC MAP (
    PIXEL_WIDTH => 24
   )
   PORT MAP (
    clk         => clk         ,
    rst         => rst         ,
    pixel_ready => pixel_ready ,
    pixel_in    => pixel_in    ,
    pixel_valid => pixel_valid ,
    strip_clk   => strip_clk   ,
    strip_data  => strip_data
  );

  -- Clock process definition
  process begin
    clk <= '1';
    wait for 4 ns;
    clk <= '0';
    wait for 4 ns;
  end process;
  process begin
    wait for 21 ns;
    rst <= '0';
    wait;
  end process;

  -- Data generation
  pixel_valid <= pixel_in(5);
  data_p : process(rst, clk) begin
    if rst='1' then
      pixel_in <= (others => '0');
    elsif rising_edge(clk) then
      if pixel_ready = '1' then
        pixel_in <= std_logic_vector(to_unsigned(to_integer(unsigned(pixel_in)) + 1, 24));
      end if;
    end if;
  end process data_p;

end rtl;