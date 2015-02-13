-- This file contains the global definitions for the
--
-------------------------------------------------------------------------
--
--  Package          : image_package
--  Package body     : none
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

package image_package is

  -- Synthese constantes
  constant NB_COLUMN         : integer := 100;
  constant NB_LIGNE          : integer := 48;
  constant NB_PIXEL_BY_STRIP : integer := 16;

   -- Simulation constantes
  --constant NB_COLUMN         : integer := 5;
  --constant NB_LIGNE          : integer := 60;
  --constant NB_PIXEL_BY_STRIP : integer := 20;

  constant SIZE_IMAGE : integer := NB_LIGNE * NB_COLUMN;

  type pixel_type is array (2 downto 0) of std_logic_vector(7 downto 0);  -- B, R, G
  type strip_type is array (NB_PIXEL_BY_STRIP - 1 downto 0) of pixel_type;
  type image_type is array (SIZE_IMAGE - 1 downto 0) of pixel_type;

  function pixel_to_std_logic_vector(pixel : pixel_type) return std_logic_vector;
  function std_logic_vector_to_pixel(pixel : std_logic_vector(23 downto 0)) return pixel_type;
  
end;

package body image_package is

  function pixel_to_std_logic_vector(pixel : pixel_type) return std_logic_vector is
    variable pixel_out : std_logic_vector(23 downto 0);
  begin
    pixel_out(7 downto 0)   := pixel(0);
    pixel_out(15 downto 8)  := pixel(1);
    pixel_out(23 downto 16) := pixel(2);
    return pixel_out;
  end function pixel_to_std_logic_vector;

  function std_logic_vector_to_pixel(pixel : std_logic_vector(23 downto 0)) return pixel_type is
    variable pixel_out : pixel_type;
  begin
    pixel_out(0) := pixel(7 downto 0);
    pixel_out(1) := pixel(15 downto 8);
    pixel_out(2) := pixel(23 downto 16);
    return pixel_out;
  end function std_logic_vector_to_pixel;
  
end package body;
