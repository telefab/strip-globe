--------------------------------------------------------------------------------
-- Copyright (c) 1995-2013 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: P.20131013
--  \   \         Application: netgen
--  /   /         Filename: pwm_generator_synthesis.vhd
-- /___/   /\     Timestamp: Thu Nov 20 18:48:37 2014
-- \   \  /  \ 
--  \___\/\___\
--             
-- Command	: -intstyle ise -ar Structure -tm pwm_generator -w -dir netgen/synthesis -ofmt vhdl -sim pwm_generator.ngc pwm_generator_synthesis.vhd 
-- Device	: xc7z010-1-clg400
-- Input file	: pwm_generator.ngc
-- Output file	: E:\Programmation\Projet S5\Motor_controller\netgen\synthesis\pwm_generator_synthesis.vhd
-- # of Entities	: 1
-- Design Name	: pwm_generator
-- Xilinx	: C:\Xilinx\14.7\ISE_DS\ISE\
--             
-- Purpose:    
--     This VHDL netlist is a verification model and uses simulation 
--     primitives which may not represent the true implementation of the 
--     device, however the netlist is functionally correct and should not 
--     be modified. This file cannot be synthesized and should only be used 
--     with supported simulation tools.
--             
-- Reference:  
--     Command Line Tools User Guide, Chapter 23
--     Synthesis and Simulation Design Guide, Chapter 6
--             
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
use UNISIM.VPKG.ALL;

entity pwm_generator is
  port (
    clk : in STD_LOGIC := 'X'; 
    raz : in STD_LOGIC := 'X'; 
    pwm : out STD_LOGIC; 
    speed_in : in STD_LOGIC_VECTOR ( 5 downto 0 ) 
  );
end pwm_generator;

architecture Structure of pwm_generator is
  signal speed_in_5_IBUF_0 : STD_LOGIC; 
  signal speed_in_4_IBUF_1 : STD_LOGIC; 
  signal speed_in_3_IBUF_2 : STD_LOGIC; 
  signal speed_in_2_IBUF_3 : STD_LOGIC; 
  signal speed_in_1_IBUF_4 : STD_LOGIC; 
  signal speed_in_0_IBUF_5 : STD_LOGIC; 
  signal clk_BUFGP_6 : STD_LOGIC; 
  signal raz_IBUF_7 : STD_LOGIC; 
  signal pwm_OBUF_24 : STD_LOGIC; 
  signal pwm_count_5_speed_mem_5_LessThan_4_o : STD_LOGIC; 
  signal GND_5_o_GND_5_o_equal_2_o : STD_LOGIC; 
  signal N0 : STD_LOGIC; 
  signal N1 : STD_LOGIC; 
  signal Result_0_1 : STD_LOGIC; 
  signal Result_1_1 : STD_LOGIC; 
  signal Result_2_1 : STD_LOGIC; 
  signal Result_3_1 : STD_LOGIC; 
  signal Result_4_1 : STD_LOGIC; 
  signal Result_5_1 : STD_LOGIC; 
  signal pwm_count_5_speed_mem_5_LessThan_4_o1_50 : STD_LOGIC; 
  signal N4 : STD_LOGIC; 
  signal Mcount_clk_count_cy_1_rt_67 : STD_LOGIC; 
  signal Mcount_clk_count_cy_2_rt_68 : STD_LOGIC; 
  signal Mcount_clk_count_cy_3_rt_69 : STD_LOGIC; 
  signal Mcount_clk_count_cy_4_rt_70 : STD_LOGIC; 
  signal Mcount_clk_count_cy_5_rt_71 : STD_LOGIC; 
  signal Mcount_clk_count_cy_6_rt_72 : STD_LOGIC; 
  signal Mcount_clk_count_cy_7_rt_73 : STD_LOGIC; 
  signal Mcount_clk_count_cy_8_rt_74 : STD_LOGIC; 
  signal Mcount_clk_count_xor_9_rt_75 : STD_LOGIC; 
  signal GND_5_o_GND_5_o_equal_2_o_9_rstpot_76 : STD_LOGIC; 
  signal GND_5_o_GND_5_o_equal_2_o_9_cepot_77 : STD_LOGIC; 
  signal pwm_count_0_dpot_78 : STD_LOGIC; 
  signal pwm_count_1_dpot_79 : STD_LOGIC; 
  signal pwm_count_2_dpot_80 : STD_LOGIC; 
  signal pwm_count_3_dpot_81 : STD_LOGIC; 
  signal pwm_count_4_dpot_82 : STD_LOGIC; 
  signal pwm_count_5_dpot_83 : STD_LOGIC; 
  signal N9 : STD_LOGIC; 
  signal N10 : STD_LOGIC; 
  signal speed_mem : STD_LOGIC_VECTOR ( 5 downto 0 ); 
  signal clk_count : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal Result : STD_LOGIC_VECTOR ( 9 downto 5 ); 
  signal Mcount_clk_count_lut : STD_LOGIC_VECTOR ( 0 downto 0 ); 
  signal Mcount_clk_count_cy : STD_LOGIC_VECTOR ( 8 downto 0 ); 
  signal pwm_count : STD_LOGIC_VECTOR ( 5 downto 0 ); 
begin
  XST_VCC : VCC
    port map (
      P => N0
    );
  XST_GND : GND
    port map (
      G => N1
    );
  speed_mem_0 : FDC
    generic map(
      INIT => '0'
    )
    port map (
      C => clk_BUFGP_6,
      CLR => raz_IBUF_7,
      D => speed_in_0_IBUF_5,
      Q => speed_mem(0)
    );
  speed_mem_1 : FDC
    generic map(
      INIT => '0'
    )
    port map (
      C => clk_BUFGP_6,
      CLR => raz_IBUF_7,
      D => speed_in_1_IBUF_4,
      Q => speed_mem(1)
    );
  speed_mem_2 : FDC
    generic map(
      INIT => '0'
    )
    port map (
      C => clk_BUFGP_6,
      CLR => raz_IBUF_7,
      D => speed_in_2_IBUF_3,
      Q => speed_mem(2)
    );
  speed_mem_3 : FDC
    generic map(
      INIT => '0'
    )
    port map (
      C => clk_BUFGP_6,
      CLR => raz_IBUF_7,
      D => speed_in_3_IBUF_2,
      Q => speed_mem(3)
    );
  speed_mem_4 : FDC
    generic map(
      INIT => '0'
    )
    port map (
      C => clk_BUFGP_6,
      CLR => raz_IBUF_7,
      D => speed_in_4_IBUF_1,
      Q => speed_mem(4)
    );
  speed_mem_5 : FDC
    generic map(
      INIT => '0'
    )
    port map (
      C => clk_BUFGP_6,
      CLR => raz_IBUF_7,
      D => speed_in_5_IBUF_0,
      Q => speed_mem(5)
    );
  pwm_9 : FDCE
    port map (
      C => clk_BUFGP_6,
      CE => GND_5_o_GND_5_o_equal_2_o,
      CLR => raz_IBUF_7,
      D => pwm_count_5_speed_mem_5_LessThan_4_o,
      Q => pwm_OBUF_24
    );
  clk_count_0 : FDC
    generic map(
      INIT => '0'
    )
    port map (
      C => clk_BUFGP_6,
      CLR => raz_IBUF_7,
      D => Result_0_1,
      Q => clk_count(0)
    );
  clk_count_1 : FDC
    generic map(
      INIT => '0'
    )
    port map (
      C => clk_BUFGP_6,
      CLR => raz_IBUF_7,
      D => Result_1_1,
      Q => clk_count(1)
    );
  clk_count_2 : FDC
    generic map(
      INIT => '0'
    )
    port map (
      C => clk_BUFGP_6,
      CLR => raz_IBUF_7,
      D => Result_2_1,
      Q => clk_count(2)
    );
  clk_count_3 : FDC
    generic map(
      INIT => '0'
    )
    port map (
      C => clk_BUFGP_6,
      CLR => raz_IBUF_7,
      D => Result_3_1,
      Q => clk_count(3)
    );
  clk_count_4 : FDC
    generic map(
      INIT => '0'
    )
    port map (
      C => clk_BUFGP_6,
      CLR => raz_IBUF_7,
      D => Result_4_1,
      Q => clk_count(4)
    );
  clk_count_5 : FDC
    generic map(
      INIT => '0'
    )
    port map (
      C => clk_BUFGP_6,
      CLR => raz_IBUF_7,
      D => Result_5_1,
      Q => clk_count(5)
    );
  clk_count_6 : FDC
    generic map(
      INIT => '0'
    )
    port map (
      C => clk_BUFGP_6,
      CLR => raz_IBUF_7,
      D => Result(6),
      Q => clk_count(6)
    );
  clk_count_7 : FDC
    generic map(
      INIT => '0'
    )
    port map (
      C => clk_BUFGP_6,
      CLR => raz_IBUF_7,
      D => Result(7),
      Q => clk_count(7)
    );
  clk_count_8 : FDC
    generic map(
      INIT => '0'
    )
    port map (
      C => clk_BUFGP_6,
      CLR => raz_IBUF_7,
      D => Result(8),
      Q => clk_count(8)
    );
  clk_count_9 : FDC
    generic map(
      INIT => '0'
    )
    port map (
      C => clk_BUFGP_6,
      CLR => raz_IBUF_7,
      D => Result(9),
      Q => clk_count(9)
    );
  pwm_count_0 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk_BUFGP_6,
      CE => GND_5_o_GND_5_o_equal_2_o_9_cepot_77,
      CLR => raz_IBUF_7,
      D => pwm_count_0_dpot_78,
      Q => pwm_count(0)
    );
  pwm_count_1 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk_BUFGP_6,
      CE => GND_5_o_GND_5_o_equal_2_o_9_cepot_77,
      CLR => raz_IBUF_7,
      D => pwm_count_1_dpot_79,
      Q => pwm_count(1)
    );
  pwm_count_2 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk_BUFGP_6,
      CE => GND_5_o_GND_5_o_equal_2_o_9_cepot_77,
      CLR => raz_IBUF_7,
      D => pwm_count_2_dpot_80,
      Q => pwm_count(2)
    );
  pwm_count_3 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk_BUFGP_6,
      CE => GND_5_o_GND_5_o_equal_2_o_9_cepot_77,
      CLR => raz_IBUF_7,
      D => pwm_count_3_dpot_81,
      Q => pwm_count(3)
    );
  pwm_count_4 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk_BUFGP_6,
      CE => GND_5_o_GND_5_o_equal_2_o_9_cepot_77,
      CLR => raz_IBUF_7,
      D => pwm_count_4_dpot_82,
      Q => pwm_count(4)
    );
  pwm_count_5 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk_BUFGP_6,
      CE => GND_5_o_GND_5_o_equal_2_o_9_cepot_77,
      CLR => raz_IBUF_7,
      D => pwm_count_5_dpot_83,
      Q => pwm_count(5)
    );
  Mcount_clk_count_cy_0_Q : MUXCY
    port map (
      CI => N1,
      DI => N0,
      S => Mcount_clk_count_lut(0),
      O => Mcount_clk_count_cy(0)
    );
  Mcount_clk_count_xor_0_Q : XORCY
    port map (
      CI => N1,
      LI => Mcount_clk_count_lut(0),
      O => Result_0_1
    );
  Mcount_clk_count_cy_1_Q : MUXCY
    port map (
      CI => Mcount_clk_count_cy(0),
      DI => N1,
      S => Mcount_clk_count_cy_1_rt_67,
      O => Mcount_clk_count_cy(1)
    );
  Mcount_clk_count_xor_1_Q : XORCY
    port map (
      CI => Mcount_clk_count_cy(0),
      LI => Mcount_clk_count_cy_1_rt_67,
      O => Result_1_1
    );
  Mcount_clk_count_cy_2_Q : MUXCY
    port map (
      CI => Mcount_clk_count_cy(1),
      DI => N1,
      S => Mcount_clk_count_cy_2_rt_68,
      O => Mcount_clk_count_cy(2)
    );
  Mcount_clk_count_xor_2_Q : XORCY
    port map (
      CI => Mcount_clk_count_cy(1),
      LI => Mcount_clk_count_cy_2_rt_68,
      O => Result_2_1
    );
  Mcount_clk_count_cy_3_Q : MUXCY
    port map (
      CI => Mcount_clk_count_cy(2),
      DI => N1,
      S => Mcount_clk_count_cy_3_rt_69,
      O => Mcount_clk_count_cy(3)
    );
  Mcount_clk_count_xor_3_Q : XORCY
    port map (
      CI => Mcount_clk_count_cy(2),
      LI => Mcount_clk_count_cy_3_rt_69,
      O => Result_3_1
    );
  Mcount_clk_count_cy_4_Q : MUXCY
    port map (
      CI => Mcount_clk_count_cy(3),
      DI => N1,
      S => Mcount_clk_count_cy_4_rt_70,
      O => Mcount_clk_count_cy(4)
    );
  Mcount_clk_count_xor_4_Q : XORCY
    port map (
      CI => Mcount_clk_count_cy(3),
      LI => Mcount_clk_count_cy_4_rt_70,
      O => Result_4_1
    );
  Mcount_clk_count_cy_5_Q : MUXCY
    port map (
      CI => Mcount_clk_count_cy(4),
      DI => N1,
      S => Mcount_clk_count_cy_5_rt_71,
      O => Mcount_clk_count_cy(5)
    );
  Mcount_clk_count_xor_5_Q : XORCY
    port map (
      CI => Mcount_clk_count_cy(4),
      LI => Mcount_clk_count_cy_5_rt_71,
      O => Result_5_1
    );
  Mcount_clk_count_cy_6_Q : MUXCY
    port map (
      CI => Mcount_clk_count_cy(5),
      DI => N1,
      S => Mcount_clk_count_cy_6_rt_72,
      O => Mcount_clk_count_cy(6)
    );
  Mcount_clk_count_xor_6_Q : XORCY
    port map (
      CI => Mcount_clk_count_cy(5),
      LI => Mcount_clk_count_cy_6_rt_72,
      O => Result(6)
    );
  Mcount_clk_count_cy_7_Q : MUXCY
    port map (
      CI => Mcount_clk_count_cy(6),
      DI => N1,
      S => Mcount_clk_count_cy_7_rt_73,
      O => Mcount_clk_count_cy(7)
    );
  Mcount_clk_count_xor_7_Q : XORCY
    port map (
      CI => Mcount_clk_count_cy(6),
      LI => Mcount_clk_count_cy_7_rt_73,
      O => Result(7)
    );
  Mcount_clk_count_cy_8_Q : MUXCY
    port map (
      CI => Mcount_clk_count_cy(7),
      DI => N1,
      S => Mcount_clk_count_cy_8_rt_74,
      O => Mcount_clk_count_cy(8)
    );
  Mcount_clk_count_xor_8_Q : XORCY
    port map (
      CI => Mcount_clk_count_cy(7),
      LI => Mcount_clk_count_cy_8_rt_74,
      O => Result(8)
    );
  Mcount_clk_count_xor_9_Q : XORCY
    port map (
      CI => Mcount_clk_count_cy(8),
      LI => Mcount_clk_count_xor_9_rt_75,
      O => Result(9)
    );
  pwm_count_5_speed_mem_5_LessThan_4_o2 : LUT6
    generic map(
      INIT => X"00F0C0FC80F8E0FE"
    )
    port map (
      I0 => speed_mem(0),
      I1 => speed_mem(1),
      I2 => speed_mem(2),
      I3 => pwm_count(2),
      I4 => pwm_count(1),
      I5 => pwm_count(0),
      O => pwm_count_5_speed_mem_5_LessThan_4_o1_50
    );
  Mcount_pwm_count_xor_5_11 : LUT6
    generic map(
      INIT => X"6AAAAAAAAAAAAAAA"
    )
    port map (
      I0 => pwm_count(5),
      I1 => pwm_count(0),
      I2 => pwm_count(1),
      I3 => pwm_count(2),
      I4 => pwm_count(3),
      I5 => pwm_count(4),
      O => Result(5)
    );
  GND_5_o_GND_5_o_equal_2_o_9_SW0 : LUT5
    generic map(
      INIT => X"FFFFFFFE"
    )
    port map (
      I0 => clk_count(3),
      I1 => clk_count(4),
      I2 => clk_count(5),
      I3 => clk_count(8),
      I4 => clk_count(9),
      O => N4
    );
  GND_5_o_GND_5_o_equal_2_o_9_Q : LUT6
    generic map(
      INIT => X"0000000000000001"
    )
    port map (
      I0 => clk_count(0),
      I1 => clk_count(1),
      I2 => clk_count(2),
      I3 => clk_count(7),
      I4 => clk_count(6),
      I5 => N4,
      O => GND_5_o_GND_5_o_equal_2_o
    );
  speed_in_5_IBUF : IBUF
    port map (
      I => speed_in(5),
      O => speed_in_5_IBUF_0
    );
  speed_in_4_IBUF : IBUF
    port map (
      I => speed_in(4),
      O => speed_in_4_IBUF_1
    );
  speed_in_3_IBUF : IBUF
    port map (
      I => speed_in(3),
      O => speed_in_3_IBUF_2
    );
  speed_in_2_IBUF : IBUF
    port map (
      I => speed_in(2),
      O => speed_in_2_IBUF_3
    );
  speed_in_1_IBUF : IBUF
    port map (
      I => speed_in(1),
      O => speed_in_1_IBUF_4
    );
  speed_in_0_IBUF : IBUF
    port map (
      I => speed_in(0),
      O => speed_in_0_IBUF_5
    );
  raz_IBUF : IBUF
    port map (
      I => raz,
      O => raz_IBUF_7
    );
  pwm_OBUF : OBUF
    port map (
      I => pwm_OBUF_24,
      O => pwm
    );
  Mcount_clk_count_cy_1_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => clk_count(1),
      O => Mcount_clk_count_cy_1_rt_67
    );
  Mcount_clk_count_cy_2_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => clk_count(2),
      O => Mcount_clk_count_cy_2_rt_68
    );
  Mcount_clk_count_cy_3_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => clk_count(3),
      O => Mcount_clk_count_cy_3_rt_69
    );
  Mcount_clk_count_cy_4_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => clk_count(4),
      O => Mcount_clk_count_cy_4_rt_70
    );
  Mcount_clk_count_cy_5_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => clk_count(5),
      O => Mcount_clk_count_cy_5_rt_71
    );
  Mcount_clk_count_cy_6_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => clk_count(6),
      O => Mcount_clk_count_cy_6_rt_72
    );
  Mcount_clk_count_cy_7_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => clk_count(7),
      O => Mcount_clk_count_cy_7_rt_73
    );
  Mcount_clk_count_cy_8_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => clk_count(8),
      O => Mcount_clk_count_cy_8_rt_74
    );
  Mcount_clk_count_xor_9_rt : LUT1
    generic map(
      INIT => X"2"
    )
    port map (
      I0 => clk_count(9),
      O => Mcount_clk_count_xor_9_rt_75
    );
  GND_5_o_GND_5_o_equal_2_o_9_rstpot : LUT5
    generic map(
      INIT => X"00000001"
    )
    port map (
      I0 => clk_count(0),
      I1 => clk_count(1),
      I2 => clk_count(2),
      I3 => clk_count(7),
      I4 => clk_count(6),
      O => GND_5_o_GND_5_o_equal_2_o_9_rstpot_76
    );
  GND_5_o_GND_5_o_equal_2_o_9_cepot : LUT5
    generic map(
      INIT => X"00000001"
    )
    port map (
      I0 => clk_count(3),
      I1 => clk_count(4),
      I2 => clk_count(5),
      I3 => clk_count(8),
      I4 => clk_count(9),
      O => GND_5_o_GND_5_o_equal_2_o_9_cepot_77
    );
  pwm_count_5_dpot : LUT3
    generic map(
      INIT => X"CA"
    )
    port map (
      I0 => pwm_count(5),
      I1 => Result(5),
      I2 => GND_5_o_GND_5_o_equal_2_o_9_rstpot_76,
      O => pwm_count_5_dpot_83
    );
  pwm_count_0_dpot : LUT2
    generic map(
      INIT => X"6"
    )
    port map (
      I0 => GND_5_o_GND_5_o_equal_2_o_9_rstpot_76,
      I1 => pwm_count(0),
      O => pwm_count_0_dpot_78
    );
  pwm_count_1_dpot : LUT3
    generic map(
      INIT => X"6A"
    )
    port map (
      I0 => pwm_count(1),
      I1 => GND_5_o_GND_5_o_equal_2_o_9_rstpot_76,
      I2 => pwm_count(0),
      O => pwm_count_1_dpot_79
    );
  pwm_count_2_dpot : LUT4
    generic map(
      INIT => X"6AAA"
    )
    port map (
      I0 => pwm_count(2),
      I1 => pwm_count(1),
      I2 => pwm_count(0),
      I3 => GND_5_o_GND_5_o_equal_2_o_9_rstpot_76,
      O => pwm_count_2_dpot_80
    );
  pwm_count_3_dpot : LUT5
    generic map(
      INIT => X"6CCCCCCC"
    )
    port map (
      I0 => pwm_count(2),
      I1 => pwm_count(3),
      I2 => pwm_count(1),
      I3 => pwm_count(0),
      I4 => GND_5_o_GND_5_o_equal_2_o_9_rstpot_76,
      O => pwm_count_3_dpot_81
    );
  pwm_count_4_dpot : LUT6
    generic map(
      INIT => X"6AAAAAAAAAAAAAAA"
    )
    port map (
      I0 => pwm_count(4),
      I1 => pwm_count(3),
      I2 => pwm_count(2),
      I3 => pwm_count(1),
      I4 => pwm_count(0),
      I5 => GND_5_o_GND_5_o_equal_2_o_9_rstpot_76,
      O => pwm_count_4_dpot_82
    );
  clk_BUFGP : BUFGP
    port map (
      I => clk,
      O => clk_BUFGP_6
    );
  Mcount_clk_count_lut_0_INV_0 : INV
    port map (
      I => clk_count(0),
      O => Mcount_clk_count_lut(0)
    );
  pwm_count_5_speed_mem_5_LessThan_4_o1 : MUXF7
    port map (
      I0 => N9,
      I1 => N10,
      S => pwm_count_5_speed_mem_5_LessThan_4_o1_50,
      O => pwm_count_5_speed_mem_5_LessThan_4_o
    );
  pwm_count_5_speed_mem_5_LessThan_4_o1_F : LUT6
    generic map(
      INIT => X"4D44DD4D4D444D44"
    )
    port map (
      I0 => pwm_count(5),
      I1 => speed_mem(5),
      I2 => pwm_count(4),
      I3 => speed_mem(4),
      I4 => pwm_count(3),
      I5 => speed_mem(3),
      O => N9
    );
  pwm_count_5_speed_mem_5_LessThan_4_o1_G : LUT6
    generic map(
      INIT => X"8A00AA8AEFAAFFEF"
    )
    port map (
      I0 => speed_mem(5),
      I1 => speed_mem(3),
      I2 => pwm_count(3),
      I3 => speed_mem(4),
      I4 => pwm_count(4),
      I5 => pwm_count(5),
      O => N10
    );

end Structure;

