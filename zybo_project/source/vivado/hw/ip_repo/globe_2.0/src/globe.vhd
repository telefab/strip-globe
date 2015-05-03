----------------------------------------------------------------------------------
-- Company: TELECOM Bretagne
-- Engineer: Antonin Martin--Schouler Nicolas Duminy
-- 
-- Create Date: 22.11.2014 16:51:00
-- Module Name: globe - rtl
-- Description: 
-- Top modul responsable of the communication between the different parts of
-- the system and the processor
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

use work.globe_package.all;
use work.image_package.all;
use work.display_package.all;

entity globe is
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
    wr_ps          : in std_logic;
    ctrl           : in  std_logic_vector(7 downto 0);
    rotation_speed : in  std_logic_vector(2 downto 0);
    char_ps        : in  std_logic_vector(7 downto 0);
    char_color     : in  std_logic_vector(23 downto 0);
    char_posx      : in  std_logic_vector(7 downto 0);
    char_posy      : in  std_logic_vector(7 downto 0);
    d_out_ps       : out std_logic_vector(DATA_RAM_WIDTH-1 downto 0);
    ram_read_pl    : out std_logic
    );
end globe;

architecture rtl of globe is

  -- Component declaration
  component interface is
    generic (
      DATA_WIDTH : integer;
      ADDR_WIDTH : integer
      );
    port (
      clk             : in  std_logic;
      rst             : in  std_logic;
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
      wr0_ps          : in  std_logic;
      wr1_ps          : in  std_logic;
      d_out_ram       : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      d_in_ram        : out std_logic_vector(DATA_WIDTH-1 downto 0);
      addr            : out std_logic_vector(ADDR_WIDTH-1 downto 0);
      ram_select_rd   : out std_logic;
      ram_enable      : out std_logic;
      wr0             : out std_logic;
      wr1             : out std_logic
      );
  end component interface;

  component frame_buffer is
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
  end component frame_buffer;

  component display_controller is
    generic (
      DATA_WIDTH : integer;
      ADDR_WIDTH : integer
      );
    port (
      clk            : in  std_logic;
      rst            : in  std_logic;
      infra_sensor   : in  std_logic;
      d_out_ram      : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      addr           : out std_logic_vector(ADDR_WIDTH-1 downto 0);
      strip_data_0   : out std_logic;
      strip_clk_0    : out std_logic;
      strip_data_1   : out std_logic;
      strip_clk_1    : out std_logic;
      image_read     : out std_logic;
      columnTimeUnit : out std_logic_vector(COMPTEUR_RND-1 downto 0);
      columnTimeD    : out std_logic_vector(COMPTEUR_RND-1 downto 0)
      );
  end component display_controller;

  -- Double buffering signals
  signal fb_display_active : std_logic;
  signal fb_switch      : std_logic;
  signal fb_switch_delayed     : std_logic;
  signal fb_switch_required : std_logic;
  signal fb_switch_required_clr : std_logic;
  signal we_0, we_1, we_pl : std_logic;
  signal d_out_0, d_out_1   : std_logic_vector(DATA_RAM_WIDTH-1 downto 0);
  signal d_in_0, d_in_1   : std_logic_vector(DATA_RAM_WIDTH-1 downto 0);
  signal d_out_pl   : std_logic_vector(DATA_RAM_WIDTH-1 downto 0);
  signal d_in_pl   : std_logic_vector(DATA_RAM_WIDTH-1 downto 0);
  signal d_addr_0, d_addr_1         : std_logic_vector(ADDR_RAM_WIDTH-1 downto 0);
  signal d_addr_pl         : std_logic_vector(ADDR_RAM_WIDTH-1 downto 0);

  -- Signal declaration
  signal image_read     : std_logic;
  signal ram_read_r     : std_logic;

  signal copy            : std_logic;
  signal letter_enable   : std_logic;
  signal rotation_enable : std_logic;

begin

  -- The globe implement dual-buffering. 
  -- At any time, only one buffer is usable by the PS part, and another one is usable by the PL part
  -- This is managed through fb_display_active, which is '0' when framebuffer 0 is active for the PL part, 
  -- and '1' when fb 1 is active for the PL part. 

  -- Control signals from the processor
    fb_switch       <= ctrl(0); -- on rising edge, switch the active frame buffer. The actual switch takes place on next image
                                -- ctrl(1 to 4) is unused
--  ram_enable_ps   <= ctrl(2);
--  ps_control      <= ctrl(3);  -- Inform that the processor is taking control of
--  -- the system
--  ram_read_ps     <= ctrl(4);
  copy            <= ctrl(5);
  letter_enable   <= ctrl(6);
  rotation_enable <= ctrl(7);

--  interface_inst : interface
--    generic map (
--      DATA_WIDTH => DATA_RAM_WIDTH,
--      ADDR_WIDTH => ADDR_RAM_WIDTH
--      )
--    port map (
--      clk             => clk,
--      rst             => rst,
--      image_read      => image_read,
--      ram_read        => ram_read_r,
--      ps_control      => '0',
--      copy            => copy,
--      letter_enable   => letter_enable,
--      rotation_enable => rotation_enable,
--      rotation_speed  => rotation_speed,
--      char_ps         => char_ps,
--      char_color      => char_color,
--      char_posx       => char_posx,
--      char_posy       => char_posy,
--      wr0_ps          => wr0_ps,
--      wr1_ps          => wr1_ps,
--      ram_enable      => ram_enable_pl,
--      d_out_ram       => d_out_2,
--      d_in_ram        => d_in_pl,
--      ram_select_rd   => ram_select_rd,
--      addr            => addr_pl,
--      wr0             => wr0_pl,
--      wr1             => wr1_pl
--      );

  frame_buffer0 : frame_buffer
    generic map (
      DATA_WIDTH => DATA_RAM_WIDTH,
      ADDR_WIDTH => ADDR_RAM_WIDTH
      )
    port map (
      clk     => clk,
      we      => we_0,
      addr    => d_addr_0,
      d_in    => d_in_0,
      d_out   => d_out_0
    );

    frame_buffer1 : frame_buffer
    generic map (
      DATA_WIDTH => DATA_RAM_WIDTH,
      ADDR_WIDTH => ADDR_RAM_WIDTH
      )
    port map (
      clk     => clk,
      we      => we_1,
      addr    => d_addr_1,
      d_in    => d_in_1,
      d_out   => d_out_1
    );

    -- Mux FBs input according to fb_display_active
    process (fb_display_active, addr_ps, d_addr_pl, d_in_ps, d_in_pl, wr_ps, we_pl, d_out_1, d_out_0)
    begin
        if (fb_display_active = '0') then
            d_in_0 <= d_in_pl;
            d_addr_0 <= d_addr_pl;
            we_0 <= we_pl;
            d_out_pl <= d_out_0;
            d_in_1 <= d_in_ps;
            d_addr_1 <= addr_ps;
            we_1 <= wr_ps;
            d_out_ps <= d_out_1;
        else
            d_in_1 <= d_in_pl;
            d_addr_1 <= d_addr_pl;
            we_1 <= we_pl;
            d_out_pl <= d_out_1;
            d_in_0 <= d_in_ps;
            d_addr_0 <= addr_ps;
            we_0 <= wr_ps;
            d_out_ps <= d_out_0;
        end if;
    end process;

    -- fb_switch_required is '1' when a switch has been required, meaning a rising edge has been detected on fb_switch, and has not yet been taken into account
    process (clk,rst)
    begin
        if rst = '1' then
            fb_switch_required <= '0';
            fb_switch_delayed <= '0';
        elsif rising_edge(clk) then
            fb_switch_delayed <= fb_switch;
            if (fb_switch_delayed = '0') and (fb_switch = '1') then
                fb_switch_required <= '1';
            elsif fb_switch_required_clr = '1' then
                fb_switch_required <= '0';
            end if;
        end if;
    end process;

    -- Manage fb_display_active according to fb_switch and image_read
    process (clk, rst)
    begin
        if rst = '1' then
            fb_display_active <= '1';
        elsif rising_edge(clk) then
            if image_read = '1' and fb_switch_required = '1' then
                fb_display_active <= not fb_display_active;
                fb_switch_required_clr <= '1';
            else
                fb_switch_required_clr <= '0';
            end if;
        end if;
    end process;

            
  display_controller_inst : display_controller
    generic map (
      DATA_WIDTH => DATA_RAM_WIDTH,
      ADDR_WIDTH => ADDR_RAM_WIDTH
      )
    port map (
      clk            => clk,
      rst            => rst,
      infra_sensor   => infra_sensor,
      d_out_ram      => d_out_pl,
      addr           => d_addr_pl,
      strip_data_0   => strip_data_0,
      strip_clk_0    => strip_clk_0,
      strip_data_1   => strip_data_1,
      strip_clk_1    => strip_clk_1,
      image_read     => image_read,
      columnTimeUnit => columnTimeUnit,
      columnTimeD    => columnTimeD
      );

end rtl;
