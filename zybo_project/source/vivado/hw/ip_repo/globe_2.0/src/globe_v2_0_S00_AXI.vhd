library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.image_package.all;
use work.globe_package.all;

entity globe_v2_0_S00_AXI is
  generic (
    -- Width of S_AXI data bus
    C_S_AXI_DATA_WIDTH : integer := 32;
    -- Width of S_AXI address bus
    C_S_AXI_ADDR_WIDTH : integer := 16
    );
  port (
    -- Users to add ports here

    INFRA_SENSOR : in  std_logic;
    strip_data_0   : out std_logic;
    strip_clk_0    : out std_logic;
    strip_data_1   : out std_logic;
    strip_clk_1    : out std_logic;
    PWM_OUT      : out std_logic;

    -- User ports ends
    -- Do not modify the ports beyond this line

    -- Global Clock Signal
    S_AXI_ACLK    : in  std_logic;
    -- Global Reset Signal. This Signal is Active LOW
    S_AXI_ARESETN : in  std_logic;
    -- Write address (issued by master, acceped by Slave)
    S_AXI_AWADDR  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    -- Write channel Protection type. This signal indicates the
    -- privilege and security level of the transaction, and whether
    -- the transaction is a data access or an instruction access.
    S_AXI_AWPROT  : in  std_logic_vector(2 downto 0);
    -- Write address valid. This signal indicates that the master signaling
    -- valid write address and control information.
    S_AXI_AWVALID : in  std_logic;
    -- Write address ready. This signal indicates that the slave is ready
    -- to accept an address and associated control signals.
    S_AXI_AWREADY : out std_logic;
    -- Write data (issued by master, acceped by Slave) 
    S_AXI_WDATA   : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    -- Write strobes. This signal indicates which byte lanes hold
    -- valid data. There is one write strobe bit for each eight
    -- bits of the write data bus.    
    S_AXI_WSTRB   : in  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
    -- Write valid. This signal indicates that valid write
    -- data and strobes are available.
    S_AXI_WVALID  : in  std_logic;
    -- Write ready. This signal indicates that the slave
    -- can accept the write data.
    S_AXI_WREADY  : out std_logic;
    -- Write response. This signal indicates the status
    -- of the write transaction.
    S_AXI_BRESP   : out std_logic_vector(1 downto 0);
    -- Write response valid. This signal indicates that the channel
    -- is signaling a valid write response.
    S_AXI_BVALID  : out std_logic;
    -- Response ready. This signal indicates that the master
    -- can accept a write response.
    S_AXI_BREADY  : in  std_logic;
    -- Read address (issued by master, acceped by Slave)
    S_AXI_ARADDR  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    -- Protection type. This signal indicates the privilege
    -- and security level of the transaction, and whether the
    -- transaction is a data access or an instruction access.
    S_AXI_ARPROT  : in  std_logic_vector(2 downto 0);
    -- Read address valid. This signal indicates that the channel
    -- is signaling valid read address and control information.
    S_AXI_ARVALID : in  std_logic;
    -- Read address ready. This signal indicates that the slave is
    -- ready to accept an address and associated control signals.
    S_AXI_ARREADY : out std_logic;
    -- Read data (issued by slave)
    S_AXI_RDATA   : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    -- Read response. This signal indicates the status of the
    -- read transfer.
    S_AXI_RRESP   : out std_logic_vector(1 downto 0);
    -- Read valid. This signal indicates that the channel is
    -- signaling the required read data.
    S_AXI_RVALID  : out std_logic;
    -- Read ready. This signal indicates that the master can
    -- accept the read data and response information.
    S_AXI_RREADY  : in  std_logic
    );
end globe_v2_0_S00_AXI;

architecture arch_imp of globe_v2_0_S00_AXI is

  -- AXI4LITE signals
  signal axi_awaddr  : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
  signal axi_awready : std_logic;
  signal axi_wready  : std_logic;
  signal axi_bresp   : std_logic_vector(1 downto 0);
  signal axi_bvalid  : std_logic;
  signal axi_araddr  : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
  signal axi_arready : std_logic;
  signal axi_rdata   : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
  signal axi_rresp   : std_logic_vector(1 downto 0);
  signal axi_rvalid  : std_logic;

  -- Example-specific design signals
  -- local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
  -- ADDR_LSB is used for addressing 32/64 bit registers/memories
  -- ADDR_LSB = 2 for 32 bits (n downto 2)
  -- ADDR_LSB = 3 for 64 bits (n downto 3)
  constant ADDR_LSB          : integer := (C_S_AXI_DATA_WIDTH/32)+ 1;
  constant OPT_MEM_ADDR_BITS : integer := 13;
  ------------------------------------------------
  ---- Signals for user logic register space example
  --------------------------------------------------
  ---- Number of Slave Registers 4
  signal slv_reg0            : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
  signal slv_reg1            : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
  signal slv_reg_rden        : std_logic;
  signal slv_reg_wren        : std_logic;
  signal reg_data_out        : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);

  -- User constants
  constant DATA_WIDTH : integer := 24;
  constant ADDR_WIDTH : integer := 13;
  constant SPEED_LEN  : integer := 8;

  -- User signals
  -- Globe's signal declaration
  signal d_in_ps        : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal d_out_ps       : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal wr_ps          : std_logic;
  signal addr_ps        : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal columnTimeUnit : std_logic_vector(COMPTEUR_RND-1 downto 0);
  signal columnTimeD    : std_logic_vector(COMPTEUR_RND-1 downto 0);
  signal rotation_speed : std_logic_vector(2 downto 0);
  signal ch             : std_logic_vector(7 downto 0);
  signal char_color     : std_logic_vector(23 downto 0);
  signal char_posx      : std_logic_vector(7 downto 0);
  signal char_posy      : std_logic_vector(7 downto 0);
  signal ram_read_pl    : std_logic;
  signal ram_read_ps    : std_logic;
  signal speed_in       : std_logic_vector(SPEED_LEN-1 downto 0);
  signal ctrl           : std_logic_vector(7 downto 0);

  -- Globe decaration
  component globe
    generic (
      DATA_RAM_WIDTH : integer;
      ADDR_RAM_WIDTH : integer
      );
    port (
      clk            : in  std_logic;
      rst            : in  std_logic;
      infra_sensor   : in  std_logic;
      strip_data_0   : out std_logic;
      strip_clk_0    : out std_logic;
      strip_data_1   : out std_logic;
      strip_clk_1    : out std_logic;
      columnTimeUnit : out std_logic_vector(COMPTEUR_RND-1 downto 0);
      columnTimeD    : out std_logic_vector(COMPTEUR_RND-1 downto 0);
      -- PS ports
      d_in_ps        : in  std_logic_vector(DATA_RAM_WIDTH-1 downto 0);
      addr_ps        : in  std_logic_vector(ADDR_RAM_WIDTH-1 downto 0);
      wr_ps          : in  std_logic;
      ctrl           : in  std_logic_vector(7 downto 0);
      rotation_speed : in  std_logic_vector(2 downto 0);
      char_ps        : in  std_logic_vector(7 downto 0);
      char_color     : in  std_logic_vector(23 downto 0);
      char_posx      : in  std_logic_vector(7 downto 0);
      char_posy      : in  std_logic_vector(7 downto 0);
      d_out_ps       : out std_logic_vector(DATA_RAM_WIDTH-1 downto 0);
      ram_read_pl    : out std_logic
      );
  end component globe;

  -- PWM generator declaration
  component pwm_generator
    generic(
      SPEED_LEN : integer;
      CLK_LEN   : integer
      );
    port(
      clk, raz : in  std_logic;
      speed_in : in  std_logic_vector((SPEED_LEN-1) downto 0);
      pwm      : out std_logic
      );
  end component pwm_generator;

begin
  -- I/O Connections assignments

  S_AXI_AWREADY <= axi_awready;
  S_AXI_WREADY  <= axi_wready;
  S_AXI_BRESP   <= axi_bresp;
  S_AXI_BVALID  <= axi_bvalid;
  S_AXI_ARREADY <= axi_arready;
  S_AXI_RDATA   <= axi_rdata;
  S_AXI_RRESP   <= axi_rresp;
  S_AXI_RVALID  <= axi_rvalid;
  -- Implement axi_awready generation
  -- axi_awready is asserted for one S_AXI_ACLK clock cycle when both
  -- S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
  -- de-asserted when reset is low.

  process (S_AXI_ACLK)
  begin
    if rising_edge(S_AXI_ACLK) then
      if S_AXI_ARESETN = '0' then
        axi_awready <= '0';
      else
        if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1') then
          -- slave is ready to accept write address when
          -- there is a valid write address and write data
          -- on the write address and data bus. This design 
          -- expects no outstanding transactions. 
          axi_awready <= '1';
        else
          axi_awready <= '0';
        end if;
      end if;
    end if;
  end process;

  -- Implement axi_awaddr latching
  -- This process is used to latch the address when both 
  -- S_AXI_AWVALID and S_AXI_WVALID are valid. 

  process (S_AXI_ACLK)
  begin
    if rising_edge(S_AXI_ACLK) then
      if S_AXI_ARESETN = '0' then
        axi_awaddr <= (others => '0');
      else
        if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1') then
          -- Write Address latching
          axi_awaddr <= S_AXI_AWADDR;
        end if;
      end if;
    end if;
  end process;

  -- Implement axi_wready generation
  -- axi_wready is asserted for one S_AXI_ACLK clock cycle when both
  -- S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
  -- de-asserted when reset is low. 

  process (S_AXI_ACLK)
  begin
    if rising_edge(S_AXI_ACLK) then
      if S_AXI_ARESETN = '0' then
        axi_wready <= '0';
      else
        if (axi_wready = '0' and S_AXI_WVALID = '1' and S_AXI_AWVALID = '1') then
          -- slave is ready to accept write data when 
          -- there is a valid write address and write data
          -- on the write address and data bus. This design 
          -- expects no outstanding transactions.           
          axi_wready <= '1';
        else
          axi_wready <= '0';
        end if;
      end if;
    end if;
  end process;

  -- Implement memory mapped register select and write logic generation
  -- The write data is accepted and written to memory mapped registers when
  -- axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
  -- select byte enables of slave registers while writing.
  -- These registers are cleared when reset (active low) is applied.
  -- Slave register write enable is asserted when valid address and data are available
  -- and the slave is ready to accept the write address and write data.
  slv_reg_wren <= axi_wready and S_AXI_WVALID and axi_awready and S_AXI_AWVALID;

  process (S_AXI_ACLK)
      variable loc_addr : std_logic_vector(OPT_MEM_ADDR_BITS downto 0);
  begin
      if rising_edge(S_AXI_ACLK) then
          if S_AXI_ARESETN = '0' then
              slv_reg0 (7 downto 0)<= (others => '0');
              wr_ps <= '0';
          else
              loc_addr := axi_awaddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
              if (slv_reg_wren = '1') then
                  if conv_integer(unsigned(loc_addr)) < SIZE_IMAGE then
            -- The address correspond directly to the address in the frame buffer
            -- The data are writing directly into the frame buffer
                      addr_ps(ADDR_WIDTH-1 downto 0) <= loc_addr(ADDR_WIDTH-1 downto 0);
                      d_in_ps                        <= S_AXI_WDATA(23 downto 0);
                      wr_ps <= '1';
                  elsif conv_integer(unsigned(loc_addr)) = SIZE_IMAGE then
            -- Address used to send the speed of the motor
                      speed_in <= S_AXI_WDATA(7 downto 0);
                      wr_ps <= '0';
                  elsif conv_integer(unsigned(loc_addr)) = SIZE_IMAGE+1 then
            -- Adress used to send the control's signals
                      slv_reg0(7 downto 0) <= S_AXI_WDATA(7 downto 0);
                      slv_reg1(2 downto 0) <= S_AXI_WDATA(10 downto 8);
                      wr_ps <= '0';
                  elsif conv_integer(unsigned(loc_addr)) = SIZE_IMAGE+2 then
            -- Address used to send the character and its color to display on
            -- The globe
                      ch         <= S_AXI_WDATA(7 downto 0);
                      char_color <= S_AXI_WDATA(31 downto 8);
                      wr_ps <= '0';
                  elsif conv_integer(unsigned(loc_addr)) = SIZE_IMAGE+3 then
            -- Address used to send the position on the globe of the character
                      char_posx <= S_AXI_WDATA(7 downto 0);
                      char_posy <= S_AXI_WDATA(15 downto 8);
                      wr_ps <= '0';
                  end if;
              else
                  wr_ps <= '0';
              end if;
          end if;
      end if;
  end process;

-- Implement write response logic generation
-- The write response and response valid signals are asserted by the slave 
-- when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
-- This marks the acceptance of address and indicates the status of 
-- write transaction.

  process (S_AXI_ACLK)
  begin
    if rising_edge(S_AXI_ACLK) then
      if S_AXI_ARESETN = '0' then
        axi_bvalid <= '0';
        axi_bresp  <= "00";             --need to work more on the responses
      else
        if (axi_awready = '1' and S_AXI_AWVALID = '1' and axi_wready = '1' and S_AXI_WVALID = '1' and axi_bvalid = '0') then
          axi_bvalid <= '1';
          axi_bresp  <= "00";
        elsif (S_AXI_BREADY = '1' and axi_bvalid = '1') then  --check if bready is asserted while bvalid is high)
          axi_bvalid <= '0';  -- (there is a possibility that bready is always asserted high)
        end if;
      end if;
    end if;
  end process;

-- Implement axi_arready generation
-- axi_arready is asserted for one S_AXI_ACLK clock cycle when
-- S_AXI_ARVALID is asserted. axi_awready is 
-- de-asserted when reset (active low) is asserted. 
-- The read address is also latched when S_AXI_ARVALID is 
-- asserted. axi_araddr is reset to zero on reset assertion.

  process (S_AXI_ACLK)
  begin
    if rising_edge(S_AXI_ACLK) then
      if S_AXI_ARESETN = '0' then
        axi_arready <= '0';
        axi_araddr  <= (others => '1');
      else
        if (axi_arready = '0' and S_AXI_ARVALID = '1') then
          -- indicates that the slave has acceped the valid read address
          axi_arready <= '1';
          -- Read Address latching 
          axi_araddr  <= S_AXI_ARADDR;
        else
          axi_arready <= '0';
        end if;
      end if;
    end if;
  end process;

-- Implement axi_arvalid generation
-- axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
-- S_AXI_ARVALID and axi_arready are asserted. The slave registers 
-- data are available on the axi_rdata bus at this instance. The 
-- assertion of axi_rvalid marks the validity of read data on the 
-- bus and axi_rresp indicates the status of read transaction.axi_rvalid 
-- is deasserted on reset (active low). axi_rresp and axi_rdata are 
-- cleared to zero on reset (active low).  
  process (S_AXI_ACLK)
  begin
    if rising_edge(S_AXI_ACLK) then
      if S_AXI_ARESETN = '0' then
        axi_rvalid <= '0';
        axi_rresp  <= "00";
      else
        if (axi_arready = '1' and S_AXI_ARVALID = '1' and axi_rvalid = '0') then
          -- Valid read data is available at the read data bus
          axi_rvalid <= '1';
          axi_rresp  <= "00";           -- 'OKAY' response
        elsif (axi_rvalid = '1' and S_AXI_RREADY = '1') then
          -- Read data is accepted by the master
          axi_rvalid <= '0';
        end if;
      end if;
    end if;
  end process;

-- Implement memory mapped register select and read logic generation
-- Slave register read enable is asserted when valid address is available
-- and the slave is ready to accept the read address.
  slv_reg_rden <= axi_arready and S_AXI_ARVALID and (not axi_rvalid);

  process (slv_reg0, axi_araddr, S_AXI_ARESETN, slv_reg_rden, d_out_ps, columnTimeUnit, columnTimeD)
    variable loc_addr : std_logic_vector(OPT_MEM_ADDR_BITS downto 0);
  begin
    -- Address decoding for reading registers
    -- Used to send back the inforation to the processor through the bus
    loc_addr := axi_araddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
    if conv_integer(unsigned(loc_addr)) < SIZE_IMAGE then
      reg_data_out(23 downto 0)  <= d_out_ps;
      reg_data_out(31 downto 24) <= (others => '0');
    elsif conv_integer(unsigned(loc_addr)) = SIZE_IMAGE+1 then
      reg_data_out <= slv_reg0;
    elsif conv_integer(unsigned(loc_addr)) = SIZE_IMAGE+4 then
      reg_data_out(COMPTEUR_RND-1 downto 0)              <= columnTimeUnit;
      reg_data_out(2*COMPTEUR_RND-1 downto COMPTEUR_RND) <= columnTimeD;
      reg_data_out(31 downto 2*COMPTEUR_RND)             <= (others => '0');
    else
      reg_data_out <= (others => '0');
    end if;
  end process;

-- Output register or memory read data
  process(S_AXI_ACLK) is
  begin
    if (rising_edge (S_AXI_ACLK)) then
      if (S_AXI_ARESETN = '0') then
        axi_rdata <= (others => '0');
      else
        if (slv_reg_rden = '1') then
          -- When there is a valid read address (S_AXI_ARVALID) with 
          -- acceptance of read address by the slave (axi_arready), 
          -- output the read dada 
          -- Read address mux
          axi_rdata <= reg_data_out;    -- register read data
        end if;
      end if;
    end if;
  end process;


-- Add user logic here
  -- Control signal passed from the register to the globe's ports
  ctrl           <= slv_reg0(7 downto 0);
  rotation_speed <= slv_reg1(2 downto 0);
  slv_reg0(8)    <= ram_read_pl;

  globe_inst : globe
    generic map (
      DATA_RAM_WIDTH => DATA_WIDTH,
      ADDR_RAM_WIDTH => ADDR_WIDTH
      )
    port map (
      clk            => S_AXI_ACLK,
      rst            => not S_AXI_ARESETN,
      infra_sensor   => not INFRA_SENSOR,
      strip_data_0   => strip_data_0,
      strip_clk_0    => strip_clk_0,
      strip_data_1   => strip_data_1,
      strip_clk_1    => strip_clk_1,
      columnTimeUnit => columnTimeUnit,
      columnTimeD    => columnTimeD,
      --
      d_in_ps        => d_in_ps,
      d_out_ps       => d_out_ps,
      addr_ps        => addr_ps,
      wr_ps          => wr_ps,
      ctrl           => ctrl,
      rotation_speed => rotation_speed,
      char_ps        => ch,
      char_color     => char_color,
      char_posx      => char_posx,
      char_posy      => char_posy,
      ram_read_pl    => ram_read_pl
      );

  pwm_0 : pwm_generator
    generic map(
      SPEED_LEN => 8,
      CLK_LEN   => 10
      )
    port map(
      clk      => S_AXI_ACLK,
      raz      => S_AXI_ARESETN,
      speed_in => speed_in,
      pwm      => PWM_OUT
      );


-- User logic ends

end arch_imp;
