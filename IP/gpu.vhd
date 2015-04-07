----------------------------------------------------------------------------------
-- Company: TELECOM Bretagne
-- Engineer: Antonin Martin--Schouler Nicolas Duminy
-- 
-- Create Date: 22.11.2014 16:51:00
-- Module Name: gpu - rtl 
-- Description: 
-- Responsable of the initialization of the frame buffers
-- Resposable of the different modifications possible : copy, rotation and
-- displaying letter
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

use work.globe_package.all;
use work.image_package.all;

entity gpu is
  generic (
    DATA_WIDTH : integer;
    ADDR_WIDTH : integer
    );
  port (
    clk             : in  std_logic;
    rst             : in  std_logic;
    pixel_in        : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    image_read      : in  std_logic;
    ram_read        : in  std_logic;
    ps_control      : in  std_logic;
    copy            : in  std_logic;
    letter_enable   : in  std_logic;
    rotation_enable : in  std_logic;
    rotation_speed  : in  std_logic_vector(2 downto 0);
    char_ps         : in  std_logic_vector(7 downto 0);
    char_color      : in  std_logic_vector(23 downto 0);
    char_posx       : in  std_logic_vector(7 downto 0);
    char_posy       : in  std_logic_vector(7 downto 0);
    ram_enable      : out std_logic;
    ram_select      : out std_logic;
    ram_select_rd   : out std_logic;
    pixel_out       : out std_logic_vector(DATA_WIDTH-1 downto 0);
    write_en        : out std_logic;
    write_en_letter : out std_logic;
    read_en         : out std_logic;
    addr_offset     : out std_logic;
    addr_letter     : out std_logic_vector(ADDR_WIDTH-1 downto 0);
    addr_letter_en  : out std_logic
    );
end gpu;

architecture rtl of gpu is

  --Component Declaration
  component letter_converter is
    port(
      clk      : in  std_logic;
      raz      : in  std_logic;
      char_ps  : in  std_logic_vector(7 downto 0);
      posX     : in  std_logic_vector(7 downto 0);
      posY     : in  std_logic_vector(7 downto 0);
      outX     : out std_logic_vector(7 downto 0);
      outY     : out std_logic_vector(7 downto 0);
      din_rts  : in  std_logic;
      dout_cts : in  std_logic;
      din_cts  : out std_logic;
      dout_rts : out std_logic
      );
  end component letter_converter;

  --Constant Declaration
  constant PIXEL_B : std_logic_vector(DATA_WIDTH-1 downto 0) := "111111110000000000000000";
  constant PIXEL_R : std_logic_vector(DATA_WIDTH-1 downto 0) := "000000001111111100000000";
  constant PIXEL_G : std_logic_vector(DATA_WIDTH-1 downto 0) := "000000000000000011111111";
  constant PIXEL_W : std_logic_vector(DATA_WIDTH-1 downto 0) := "111111111111111111111111";

  -- Signal Declaration
  type state is (init_state, idle, copy_state, rotation_state, letter_state, wait_for_count);
  signal current_state : state;
  signal next_state    : state;

  signal count_pixel    : integer range 0 to 48;
  signal column_counter : integer range 0 to 100;
  signal ram_select_r   : std_logic;
  signal send           : std_logic;
  --
  signal init_ram       : std_logic;
  signal rotate         : std_logic;
  signal copy_en        : std_logic;
  signal letter_en      : std_logic;
  signal count_en       : std_logic;
  signal end_count      : std_logic;
  signal end_copy       : std_logic;
  signal end_rotation   : std_logic;
  signal end_letter     : std_logic;
  signal end_init       : std_logic;
  --
  signal wait_for_pixel : std_logic;
  signal wait_for_write : std_logic;
  signal ram_select_wr  : std_logic;
  signal pixel_read     : std_logic;
  signal rd_dly         : std_logic;
  signal count_init     : integer range 0 to 2;
  signal count_copy     : integer range 0 to SIZE_IMAGE;
  signal count_image    : integer range 0 to 100;
  signal addr_letter_r  : integer range 0 to SIZE_IMAGE;
  signal letter_ready   : std_logic;

  signal outX     : std_logic_vector(7 downto 0);
  signal outY     : std_logic_vector(7 downto 0);
  signal din_rts  : std_logic;
  signal dout_cts : std_logic;
  signal din_cts  : std_logic;
  signal dout_rts : std_logic;
  
begin

  -- Mapping of the component responsable for the conversion of the
  -- character in pixels
  letter_inst : letter_converter
    port map (
      clk      => clk,
      raz      => rst,
      char_ps  => char_ps,
      posX     => char_posx,
      posY     => char_posy,
      outX     => outX,
      outY     => outY,
      din_rts  => din_rts,
      dout_cts => dout_cts,
      din_cts  => din_cts,
      dout_rts => dout_rts
      );

  process(clk, rst)
  begin
    if rst = '1' then
      current_state <= init_state;
    elsif rising_edge(clk) then
      if ps_control = '0' then
        current_state <= next_state;
      else
        current_state <= idle;
      end if;
    end if;
  end process;

  process(current_state, copy, letter_enable, rotation_enable, end_count, end_copy, end_rotation, end_letter, end_init)
  begin
    case current_state is
      when init_state =>
        -- During the init phase the two frame buffer are initialise with zeros
        init_ram  <= '1';
        rotate    <= '0';
        copy_en   <= '0';
        letter_en <= '0';
        count_en  <= '0';
        din_rts   <= '0';
        if end_init = '1' then
          next_state <= idle;
          init_ram   <= '0';
        else
          next_state <= init_state;
        end if;
      when idle =>
        init_ram  <= '0';
        rotate    <= '0';
        copy_en   <= '0';
        letter_en <= '0';
        count_en  <= '0';
        din_rts   <= '0';
        -- The next state depends on the signal sent by the processor
        if copy = '1' then
          next_state <= copy_state;
        elsif letter_enable = '1'then
          next_state <= letter_state;
          din_rts    <= '1';
        elsif rotation_enable = '1' then
          next_state <= rotation_state;
        else
          next_state <= idle;
        end if;
      when copy_state =>
        -- In this state the frame buffer read by the display controller
        -- will be copied in the other frame buffer
        init_ram  <= '0';
        rotate    <= '0';
        copy_en   <= '1';
        letter_en <= '0';
        count_en  <= '0';
        din_rts   <= '0';
        if end_copy = '1' then
          next_state <= idle;
          copy_en    <= '0';
        else
          next_state <= copy_state;
        end if;
      when letter_state =>
        -- In this state the pixels corresponding of a letter will be written
        -- in a frame buffer (choose by the processor)
        init_ram  <= '0';
        rotate    <= '0';
        copy_en   <= '0';
        letter_en <= '1';
        count_en  <= '0';
        din_rts   <= '0';
        if end_letter = '1' then
          next_state <= idle;
          letter_en  <= '0';
        else
          next_state <= letter_state;
        end if;
      when rotation_state =>
        -- In this state the frame buffer read by the display controller will
        -- be copy in the other frame buffer with a deplacement of one column
        init_ram  <= '0';
        rotate    <= '1';
        copy_en   <= '1';
        letter_en <= '0';
        count_en  <= '0';
        din_rts   <= '0';
        if end_rotation = '1' then
          next_state <= wait_for_count;
          copy_en    <= '0';
          rotate     <= '0';
        else
          next_state <= rotation_state;
        end if;
      when wait_for_count =>
        -- In this state the GPU is waiting for the display controller to
        -- display a number of images (which correspond to the signal
        -- rotation_speed) before doing an other rotation
        init_ram  <= '0';
        rotate    <= '0';
        copy_en   <= '0';
        letter_en <= '0';
        count_en  <= '1';
        din_rts   <= '0';
        if end_count = '1' then
          next_state <= rotation_state;
          count_en   <= '0';
        elsif rotation_enable = '0' then  -- The processor inform the GPU that
                                          -- the rotation is over
          next_state <= idle;
        else
          next_state <= wait_for_count;
        end if;
    end case;
  end process;

  process(clk, rst)
  begin
    if rst = '1' then
      count_image <= 0;
      end_count   <= '0';
    elsif rising_edge(clk) then
      end_count <= '0';
      if count_en = '1' then
        if image_read = '1' then  -- Another image has been read by the display
          -- controller
          if count_image < conv_integer(unsigned(rotation_speed)) then
            -- The number of image read is below the number of image choosen
            -- the counter is updated
            count_image <= count_image + 1;
          else
            -- The number of image read is equal to the number of image choosen
            -- the counter is over a new rotation can be done
            count_image <= 0;
            end_count   <= '1';
          end if;
        end if;
      end if;
    end if;
  end process;

  operating_proc : process (rst, clk)
  begin
    if rst = '1' then
      pixel_out      <= (others => '0');
      count_pixel    <= 0;
      addr_offset    <= '0';
      column_counter <= 0;
      ram_select_wr  <= '0';
      ram_enable     <= '0';
      rd_dly         <= '0';
      --
      write_en       <= '0';
      read_en        <= '0';
      pixel_read     <= '0';
      wait_for_pixel <= '0';
      wait_for_write <= '0';
      --
      end_init       <= '0';
      end_copy       <= '0';
      end_letter     <= '0';
      --
      count_init     <= 0;
      count_copy     <= 0;
      --
      dout_cts       <= '0';
      addr_letter_r  <= 0;
      addr_letter_en <= '0';
    elsif rising_edge(clk) then
      end_init   <= '0';
      end_copy   <= '0';
      end_letter <= '0';
      if init_ram = '1' then                    -- Initialisation state
        if column_counter < NB_COLUMN then
          write_en <= '1';
          if count_pixel < 3*NB_PIXEL_BY_STRIP-1 then
            pixel_out   <= (others => '0');
            count_pixel <= count_pixel + 1;
          else
            column_counter <= column_counter + 1;
            count_pixel    <= 0;
          end if;
        else
          write_en       <= '0';
          column_counter <= 0;
          ram_select_wr  <= not ram_select_wr;  -- Switch between the two frame
                                                -- buffers
          if count_init < 1 then
            count_init <= count_init + 1;
          else
            -- When the two frame buffer are initialise the initialisation is done
            count_init <= 0;
            end_init   <= '1';
            ram_enable <= '0';
          end if;
        end if;
      end if;

      if copy_en = '1' then             -- The copy start
        if rotate = '1' then  -- If it is a rotation the beginning address as to
          -- be moved by one column
          addr_offset <= '1';
          ram_enable  <= not ram_read;
        end if;
        -- Selection of the the frame buffers for the reading and the writing
        ram_select_wr <= not ram_read;
        ram_select_rd <= ram_read;
        -- First the pixel is read a frame buffer
        if pixel_read = '0' then
          write_en       <= '0';
          read_en        <= '1';
          wait_for_pixel <= '1';
          if wait_for_pixel = '1' then
            read_en <= '0';
            rd_dly  <= '1';
            if rd_dly = '1' then
              rd_dly         <= '0';
              wait_for_pixel <= '0';
              pixel_read     <= '1';
            end if;
          end if;
        else
          -- Then the pixel is written in the other one
          write_en       <= '1';
          pixel_out      <= pixel_in;
          wait_for_write <= '1';
          if wait_for_write = '1' then
            write_en       <= '0';
            pixel_read     <= '0';
            wait_for_write <= '0';
            if count_copy < SIZE_IMAGE - 1 then
              count_copy <= count_copy + 1;
            else
              -- All the frame buffer is copied the copy (or the rotation) is over
              count_copy <= 0;
              if rotate = '0' then
                end_copy <= '1';
              else
                end_rotation <= '1';
                addr_offset  <= '0';
              end if;
              pixel_read <= '0';
            end if;
          end if;
        end if;
      end if;

      if letter_en = '1' then
        addr_letter_en <= '1';  -- To inform the write_image that the address will be now
        -- controlled from here
        dout_cts       <= '1';  -- To inform the letter_converter that the GPU
        -- is ready
        pixel_out      <= char_color;
        if dout_rts = '1' then  -- The letter_converter send a new address for a
          -- pixel
          addr_letter_r <= conv_integer(unsigned(outY)) * NB_LIGNE + conv_integer(unsigned(outX));
        else
          if din_cts = '1' then         -- All the pixels have been sent
            end_letter     <= '1';
            dout_cts       <= '0';
            addr_letter_en <= '0';
          end if;
        end if;
      end if;

      if rotate = '0' then
        addr_offset <= '0';
      end if;
    end if;
  end process operating_proc;

  write_en_letter <= dout_rts and dout_cts;
  ram_select      <= ram_select_wr;
  addr_letter     <= std_logic_vector(conv_unsigned(addr_letter_r, ADDR_WIDTH));

end;
