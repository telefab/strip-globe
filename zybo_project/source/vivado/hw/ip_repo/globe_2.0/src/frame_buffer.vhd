------------------------------------------------------
-- Dual-port synchronous RAM
------------------------------------------------------
-- Data width and number of addresses are parameters
-- When writing, you can only read the previous value
-- at the written address.
-- To read:
--      * Put an address in ADDR
--      * data will be in DOUT at next clock cycle
-- To write:
--      * Put an address in ADDR
--      * Put data in DIN
--      * Put 1 in WE
--      * data will be saved at next clock cycle
------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity frame_buffer is
  generic (
    DATA_WIDTH : integer;
    ADDR_WIDTH : integer
    );
  port (
    clk     : in  std_logic;
    -- Port 1
    we      : in std_logic;
    addr    : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
    d_in    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    d_out   : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );

end entity;

architecture rtl of frame_buffer is

  -- Build a 2-D array type for the RAM
  type memory_t is array(2**ADDR_WIDTH-1 downto 0) of std_logic_vector(DATA_WIDTH-1 downto 0);

  -- Declare the RAM signal.
  signal ram    : memory_t;
  signal read_a : std_logic_vector(ADDR_WIDTH-1 downto 0);

begin

  process(clk)
  begin
    if rising_edge(clk) then
      -- Write
      if(we = '1') then
        ram(conv_integer(addr)) <= d_in;
      end if;
      -- Read
      read_a <= addr;
    end if;
  end process;

  d_out <= ram(conv_integer(read_a));
  
end rtl;
