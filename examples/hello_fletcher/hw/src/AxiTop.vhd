library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- use ieee.std_logic_misc.all;

library work;
use work.mmio_pkg.all;

entity AxiTop is
  generic (
    constant AFU_ACCEL_UUID : std_logic_vector(127 downto 0);
    -- Accelerator properties
    INDEX_WIDTH             : natural := 32;
    REG_WIDTH               : natural := 32;
    TAG_WIDTH               : natural := 1;
    -- AXI4 (full) bus properties for memory access.
    BUS_ADDR_WIDTH          : natural := 64;
    BUS_DATA_WIDTH          : natural := 512;
    BUS_LEN_WIDTH           : natural := 8;
    BUS_BURST_MAX_LEN       : natural := 64;
    BUS_BURST_STEP_LEN      : natural := 1;
    -- AXI4-lite bus properties for MMIO
    MMIO_ADDR_WIDTH         : natural := 32;
    MMIO_DATA_WIDTH         : natural := 32
  );

  port (
    -- Kernel clock domain.
    kcd_clk       : in std_logic;
    kcd_reset     : in std_logic;

    -- Bus clock domain.
    bcd_clk       : in std_logic;
    bcd_reset     : in std_logic;

    ---------------------------------------------------------------------------
    -- AXI4 master as Host Memory Interface
    ---------------------------------------------------------------------------
    -- Read address channel
    m_axi_araddr  : out std_logic_vector(BUS_ADDR_WIDTH - 1 downto 0);
    m_axi_arlen   : out std_logic_vector(7 downto 0);
    m_axi_arvalid : out std_logic := '0';
    m_axi_arready : in std_logic;
    m_axi_arsize  : out std_logic_vector(2 downto 0);

    -- Read data channel
    m_axi_rdata   : in std_logic_vector(BUS_DATA_WIDTH - 1 downto 0);
    m_axi_rresp   : in std_logic_vector(1 downto 0);
    m_axi_rlast   : in std_logic;
    m_axi_rvalid  : in std_logic;
    m_axi_rready  : out std_logic := '0';

    -- Write address channel
    m_axi_awvalid : out std_logic := '0';
    m_axi_awready : in std_logic;
    m_axi_awaddr  : out std_logic_vector(BUS_ADDR_WIDTH - 1 downto 0);
    m_axi_awlen   : out std_logic_vector(7 downto 0);
    m_axi_awsize  : out std_logic_vector(2 downto 0);

    -- Write data channel
    m_axi_wvalid  : out std_logic := '0';
    m_axi_wready  : in std_logic;
    m_axi_wdata   : out std_logic_vector(BUS_DATA_WIDTH - 1 downto 0);
    m_axi_wlast   : out std_logic;
    m_axi_wstrb   : out std_logic_vector(BUS_DATA_WIDTH/8 - 1 downto 0);

    ---------------------------------------------------------------------------
    -- AXI4-lite Slave as MMIO interface
    ---------------------------------------------------------------------------
    -- Write adress channel
    s_axi_awvalid : in std_logic;
    s_axi_awready : out std_logic;
    s_axi_awaddr  : in std_logic_vector(MMIO_ADDR_WIDTH - 1 downto 0);

    -- Write data channel
    s_axi_wvalid  : in std_logic;
    s_axi_wready  : out std_logic;
    s_axi_wdata   : in std_logic_vector(MMIO_DATA_WIDTH - 1 downto 0);
    s_axi_wstrb   : in std_logic_vector((MMIO_DATA_WIDTH/8) - 1 downto 0);

    -- Write response channel
    s_axi_bvalid  : out std_logic;
    s_axi_bready  : in std_logic;
    s_axi_bresp   : out std_logic_vector(1 downto 0);

    -- Read address channel
    s_axi_arvalid : in std_logic;
    s_axi_arready : out std_logic;
    s_axi_araddr  : in std_logic_vector(MMIO_ADDR_WIDTH - 1 downto 0);

    -- Read data channel
    s_axi_rvalid  : out std_logic;
    s_axi_rready  : in std_logic;
    s_axi_rdata   : out std_logic_vector(MMIO_DATA_WIDTH - 1 downto 0);
    s_axi_rresp   : out std_logic_vector(1 downto 0)
  );
end AxiTop;

architecture Behavorial of AxiTop is
  signal ground : std_logic_vector(31 downto 18);
begin

  ground <= (others => '0');

  mmio_inst : mmio
  generic map(
    F_AFU_ID_L_RESET_DATA => AFU_ACCEL_UUID(63 downto 0),
    F_AFU_ID_H_RESET_DATA => AFU_ACCEL_UUID(127 downto 64)
  )
  port map(
    kcd_clk                    => kcd_clk,
    kcd_reset                  => kcd_reset,
    s_axi_awvalid              => s_axi_awvalid,
    s_axi_awready              => s_axi_awready,
    s_axi_awaddr(17 downto 0)  => s_axi_awaddr,
    s_axi_awaddr(31 downto 18) => (others => '0'),
    s_axi_awprot => (others => '0'),
    s_axi_wvalid               => s_axi_wvalid,
    s_axi_wready               => s_axi_wready,
    s_axi_wdata                => s_axi_wdata,
    s_axi_wstrb                => s_axi_wstrb,
    s_axi_bvalid               => s_axi_bvalid,
    s_axi_bready               => s_axi_bready,
    s_axi_bresp                => s_axi_bresp,
    s_axi_arvalid              => s_axi_arvalid,
    s_axi_arready              => s_axi_arready,
    s_axi_araddr(17 downto 0)  => s_axi_araddr,
    s_axi_araddr(31 downto 18) => ground,
    s_axi_arprot => (others => '0'),
    s_axi_rvalid               => s_axi_rvalid,
    s_axi_rready               => s_axi_rready,
    s_axi_rdata                => s_axi_rdata,
    s_axi_rresp                => s_axi_rresp,
    s_axi_uirq                 => open
  );

  m_axi_araddr  <= (others => '0');
  m_axi_arlen   <= (others => '0');
  m_axi_arvalid <= '0';
  m_axi_arsize  <= (others => '0');
  m_axi_rready  <= '1';
  m_axi_awvalid <= '1';
  m_axi_awaddr  <= (others => '0');
  m_axi_awlen   <= (others => '0');
  m_axi_awsize  <= (others => '0');
  m_axi_wvalid  <= '1';
  m_axi_wdata   <= (others => '0');
  m_axi_wlast   <= '0';
  m_axi_wstrb   <= (others => '0');

end architecture;