-- Generated using vhdMMIO 0.0.3 (https://github.com/abs-tudelft/vhdmmio)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library work;
use work.vhdmmio_pkg.all;

package mmio_pkg is

  -- Component declaration for mmio.
  component mmio is
    generic (

      -- Interface for field AFU_ID_L: AFU_ID_L.
      F_AFU_ID_L_RESET_DATA : std_logic_vector(63 downto 0) := (others => '0');

      -- Interface for field AFU_ID_H: AFU_ID_H.
      F_AFU_ID_H_RESET_DATA : std_logic_vector(63 downto 0) := (others => '0')

    );
    port (

      -- Clock sensitive to the rising edge and synchronous, active-high reset.
      kcd_clk : in std_logic;
      kcd_reset : in std_logic := '0';

      -- AXI4-lite + interrupt request bus to the master.
      s_axi_awvalid : in  std_logic := '0';
      s_axi_awready : out std_logic := '1';
      s_axi_awaddr  : in  std_logic_vector(31 downto 0) := X"00000000";
      s_axi_awprot  : in  std_logic_vector(2 downto 0) := "000";
      s_axi_wvalid  : in  std_logic := '0';
      s_axi_wready  : out std_logic := '1';
      s_axi_wdata   : in  std_logic_vector(63 downto 0) := (others => '0');
      s_axi_wstrb   : in  std_logic_vector(7 downto 0) := (others => '0');
      s_axi_bvalid  : out std_logic := '0';
      s_axi_bready  : in  std_logic := '1';
      s_axi_bresp   : out std_logic_vector(1 downto 0) := "00";
      s_axi_arvalid : in  std_logic := '0';
      s_axi_arready : out std_logic := '1';
      s_axi_araddr  : in  std_logic_vector(31 downto 0) := X"00000000";
      s_axi_arprot  : in  std_logic_vector(2 downto 0) := "000";
      s_axi_rvalid  : out std_logic := '0';
      s_axi_rready  : in  std_logic := '1';
      s_axi_rdata   : out std_logic_vector(63 downto 0) := (others => '0');
      s_axi_rresp   : out std_logic_vector(1 downto 0) := "00";
      s_axi_uirq    : out std_logic := '0'

    );
  end component;

end package mmio_pkg;
