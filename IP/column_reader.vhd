----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 19.11.2014 15:47:53
-- Design Name: 
-- Module Name: column_reader - rtl
-- Description: 
-- Read two column in the frame buffer (one for each side of the ring) and
-- divide them into strip in order to send them to every send_pixels
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

use work.globe_package.all;
use work.image_package.all;
use work.display_package.all;

entity column_reader is
  generic (
    DATA_WIDTH        : integer;
    ADDR_WIDTH        : integer;
    NB_STRIP          : integer;
    NB_PIXEL_BY_STRIP : integer
    );
  port (
    clk          : in  std_logic;
    rst          : in  std_logic;
    ready        : in  std_logic;
    new_image    : in  std_logic;
    new_column   : in  std_logic;
    d_out_ram    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    addr         : out std_logic_vector(ADDR_WIDTH-1 downto 0);
    pixel_vector : out std_logic_vector(6*DATA_WIDTH-1 downto 0);
    new_pixel    : out std_logic;
    image_read   : out std_logic
    );
end column_reader;

architecture rtl of column_reader is

  -- Signal 
  type state is (init, idle, read_state, ready_to_send, send_state);
  signal current_state : state;
  signal next_state    : state;

  signal count_strip  : integer range 0 to NB_STRIP;
  signal count_pixel  : integer range 0 to NB_PIXEL_BY_STRIP;
  signal count_send   : integer range 0 to NB_PIXEL_BY_STRIP;
  signal read_column  : std_logic;
  signal strip_sent   : std_logic;
  signal send         : std_logic;
  signal columns_read : std_logic;
  signal strip0       : strip_type;
  signal strip1       : strip_type;
  signal strip2       : strip_type;
  signal strip3       : strip_type;
  signal strip4       : strip_type;
  signal strip5       : strip_type;
  signal addr_r1      : integer range 0 to SIZE_IMAGE;
  signal addr_r2      : integer range 0 to SIZE_IMAGE;
  signal addr_r2_r    : integer range 0 to SIZE_IMAGE;
  --
  signal read_ram     : std_logic;
  
begin

  state_machine_control : process(rst, clk)
  begin
    if rst = '1' then
      current_state <= init;
    elsif rising_edge(clk) then
      current_state <= next_state;
    end if;
  end process state_machine_control;

  state_machine : process(current_state, new_column, new_image, ready, columns_read,
                          strip_sent)
  begin
    case current_state is
      when init =>
        read_column <= '0';
        send        <= '0';
        new_pixel   <= '0';
        next_state  <= idle;
      when idle =>
        -- Waiting for the speed controller to give the start signal
        read_column <= '0';
        send        <= '0';
        new_pixel   <= '0';
        if new_column = '1' then
          read_column <= '1';
          next_state  <= read_state;
        elsif new_image = '1' then
          read_column <= '1';
          next_state  <= read_state;
        else
          next_state <= idle;
        end if;
      when read_state =>
        -- Two columns are read (one for each side of the ring)
        read_column <= '1';
        send        <= '0';
        new_pixel   <= '0';
        if columns_read = '1' then      -- The column are read
          read_column <= '0';
          next_state  <= ready_to_send;
        else
          next_state <= read_state;
        end if;
      when ready_to_send =>
        -- Waiting for the send_pixels to be ready
        read_column <= '0';
        send        <= '0';
        new_pixel   <= '0';
        if ready = '1' then             -- The send_pixels are ready
          send       <= '1';
          next_state <= send_state;
        else
          next_state <= ready_to_send;
        end if;
      when send_state =>
        -- A pixel is send to each send_pixel
        read_column <= '0';
        send        <= '0';
        new_pixel   <= '1';
        if strip_sent = '1' then  -- The strips are send the column_reader goes
          -- back to waiting for the speed_controller
          -- start signal
          next_state <= idle;
        else
          next_state <= ready_to_send;
        end if;
      when others =>
        read_column <= '0';
        send        <= '0';
        new_pixel   <= '0';
        next_state  <= idle;
    end case;
  end process state_machine;

  addr_r2_r <= addr_r2 + ADDR2_START when addr_r2 < ADDR2_START else
               addr_r2 - ADDR2_START;

  -- Switching between the address of the two column
  addr <= std_logic_vector(to_unsigned(addr_r1, ADDR_WIDTH)) when count_strip < NB_STRIP/2 else
               std_logic_vector(to_unsigned(addr_r2_r, ADDR_WIDTH));

  read_column_proc : process(clk, rst)
  begin
    if rst = '1' then
      count_pixel  <= 0;
      count_strip  <= 0;
      columns_read <= '0';
      strip0       <= (others => (others => (others => '0')));
      strip1       <= (others => (others => (others => '0')));
      strip2       <= (others => (others => (others => '0')));
      strip3       <= (others => (others => (others => '0')));
      strip4       <= (others => (others => (others => '0')));
      strip5       <= (others => (others => (others => '0')));
      addr_r1      <= 0;
      addr_r2      <= 0;
      image_read   <= '0';
      read_ram     <= '0';
    elsif rising_edge(clk) then
      columns_read <= '0';
      image_read   <= '0';
      if new_image = '1' then
        addr_r1     <= 0;
        addr_r2     <= 0;
        count_pixel <= 0;
        count_strip <= 0;
        read_ram    <= '0';
      end if;
      if read_column = '1' then
        if count_strip < NB_STRIP then
          if count_pixel < NB_PIXEL_BY_STRIP then
            if read_ram = '0' then
              -- The pixel is read in the frame buffer and store in a register
              -- Each strip has its own register
              case count_strip is
                when 0      => strip0(count_pixel) <= std_logic_vector_to_pixel(d_out_ram);
                when 1      => strip1(count_pixel) <= std_logic_vector_to_pixel(d_out_ram);
                when 2      => strip2(count_pixel) <= std_logic_vector_to_pixel(d_out_ram);
                when 3      => strip3(count_pixel) <= std_logic_vector_to_pixel(d_out_ram);
                when 4      => strip4(count_pixel) <= std_logic_vector_to_pixel(d_out_ram);
                when 5      => strip5(count_pixel) <= std_logic_vector_to_pixel(d_out_ram);
                when others => strip0(count_pixel) <= std_logic_vector_to_pixel(d_out_ram);
              end case;
              read_ram <= '1';
            else
              -- Then the reading address is updated
              if count_strip < NB_STRIP/2 then
                if addr_r1 < SIZE_IMAGE-1 then
                  addr_r1 <= addr_r1 + 1;
                else
                  addr_r1 <= 0;
                end if;
              else
                if addr_r2 < SIZE_IMAGE-1 then
                  addr_r2 <= addr_r2 + 1;
                else
                  addr_r2    <= 0;
                  image_read <= '1';
                end if;
              end if;
              count_pixel <= count_pixel + 1;
              read_ram    <= '0';
            end if;
            
          else
            -- All the pixels of a strip are stored
            -- The column_reader pass to the next one
            count_pixel <= 0;
            count_strip <= count_strip + 1;
          end if;
        else
          -- All the strip are stored
          count_strip  <= 0;
          columns_read <= '1';
        end if;
      end if;
    end if;
  end process read_column_proc;

  send_strip : process(clk, rst)
  begin
    if rst = '1' then
      pixel_vector <= (others => '0');
      count_send   <= 0;
      strip_sent   <= '0';
    elsif rising_edge(clk) then
      strip_sent <= '0';
      if send = '1' then
        -- Each time the send_pixels are ready a pixel is sent to all of them
        -- through the pixel_vector array
        count_send                                       <= count_send + 1;
        pixel_vector(DATA_WIDTH-1 downto 0)              <= pixel_to_std_logic_vector(strip0(count_send));
        pixel_vector(2*DATA_WIDTH-1 downto DATA_WIDTH)   <= pixel_to_std_logic_vector(strip1(count_send));
        pixel_vector(3*DATA_WIDTH-1 downto 2*DATA_WIDTH) <= pixel_to_std_logic_vector(strip2(count_send));
        pixel_vector(4*DATA_WIDTH-1 downto 3*DATA_WIDTH) <= pixel_to_std_logic_vector(strip3(count_send));
        pixel_vector(5*DATA_WIDTH-1 downto 4*DATA_WIDTH) <= pixel_to_std_logic_vector(strip4(count_send));
        pixel_vector(6*DATA_WIDTH-1 downto 5*DATA_WIDTH) <= pixel_to_std_logic_vector(strip5(count_send));
        if count_send = NB_PIXEL_BY_STRIP - 1 then
          -- All the pixel are sent
          strip_sent <= '1';
          count_send <= 0;
        end if;
      end if;
    end if;
  end process send_strip;

end rtl;
