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
    addr_1  : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
    d_out_1 : out std_logic_vector(DATA_WIDTH-1 downto 0);
    -- Port 2
    d_in    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    wr      : in  std_logic := '0';
    addr_2  : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
    d_out_2 : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );

end entity;

architecture rtl of frame_buffer is

  -- Build a 2-D array type for the RAM
  subtype word_t is std_logic_vector(DATA_WIDTH-1 downto 0);
  type memory_t is array(2**ADDR_WIDTH-1 downto 0) of word_t;

  -- Declare the RAM signal.
  signal ram    : memory_t;
  signal read_1 : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal read_2 : std_logic_vector(ADDR_WIDTH-1 downto 0);

begin

  process(clk)
  begin
    if rising_edge(clk) then
	   -- Write
      if(wr = '1') then
        ram(conv_integer(addr_2)) <= d_in;
      end if;
      -- Read
		-- Port 1
      read_1 <= addr_1;
		-- Port 2
		read_2 <= addr_2;
    end if;   
  end process;
  
  d_out_1 <= ram(conv_integer(read_1));
  d_out_2 <= ram(conv_integer(read_2));
  
end rtl;
