-- Copyright 2018-2019 Delft University of Technology
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
-- This file was generated by Fletchgen. Modify this file at your own risk.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Array_pkg.all;
use work.mmio_pkg.all;

entity battery_status_Nucleus is
  generic (
    INDEX_WIDTH                   : integer := 32;
    TAG_WIDTH                     : integer := 1;
    INPUT_INPUT_BUS_ADDR_WIDTH    : integer := 64;
    OUTPUT_VOLTAGE_BUS_ADDR_WIDTH : integer := 64
  );
  port (
    kcd_clk                     : in std_logic;
    kcd_reset                   : in std_logic;
    mmio_awvalid                : in std_logic;
    mmio_awready                : out std_logic;
    mmio_awaddr                 : in std_logic_vector(31 downto 0);
    mmio_wvalid                 : in std_logic;
    mmio_wready                 : out std_logic;
    mmio_wdata                  : in std_logic_vector(63 downto 0);
    mmio_wstrb                  : in std_logic_vector(7 downto 0);
    mmio_bvalid                 : out std_logic;
    mmio_bready                 : in std_logic;
    mmio_bresp                  : out std_logic_vector(1 downto 0);
    mmio_arvalid                : in std_logic;
    mmio_arready                : out std_logic;
    mmio_araddr                 : in std_logic_vector(31 downto 0);
    mmio_rvalid                 : out std_logic;
    mmio_rready                 : in std_logic;
    mmio_rdata                  : out std_logic_vector(63 downto 0);
    mmio_rresp                  : out std_logic_vector(1 downto 0);
    input_input_valid           : in std_logic;
    input_input_ready           : out std_logic;
    input_input_dvalid          : in std_logic;
    input_input_last            : in std_logic;
    input_input                 : in std_logic_vector(63 downto 0);
    input_input_count           : in std_logic_vector(3 downto 0);
    input_input_unl_valid       : in std_logic;
    input_input_unl_ready       : out std_logic;
    input_input_unl_tag         : in std_logic_vector(TAG_WIDTH - 1 downto 0);
    input_input_cmd_valid       : out std_logic;
    input_input_cmd_ready       : in std_logic;
    input_input_cmd_firstIdx    : out std_logic_vector(INDEX_WIDTH - 1 downto 0);
    input_input_cmd_lastIdx     : out std_logic_vector(INDEX_WIDTH - 1 downto 0);
    input_input_cmd_ctrl        : out std_logic_vector(INPUT_INPUT_BUS_ADDR_WIDTH - 1 downto 0);
    input_input_cmd_tag         : out std_logic_vector(TAG_WIDTH - 1 downto 0);
    output_voltage_valid        : out std_logic;
    output_voltage_ready        : in std_logic;
    output_voltage_dvalid       : out std_logic;
    output_voltage_last         : out std_logic;
    output_voltage_length       : out std_logic_vector(31 downto 0);
    output_voltage_count        : out std_logic_vector(0 downto 0);
    output_voltage_item_valid   : out std_logic;
    output_voltage_item_ready   : in std_logic;
    output_voltage_item_dvalid  : out std_logic;
    output_voltage_item_last    : out std_logic;
    output_voltage_item         : out std_logic_vector(63 downto 0);
    output_voltage_item_count   : out std_logic_vector(0 downto 0);
    output_voltage_unl_valid    : in std_logic;
    output_voltage_unl_ready    : out std_logic;
    output_voltage_unl_tag      : in std_logic_vector(TAG_WIDTH - 1 downto 0);
    output_voltage_cmd_valid    : out std_logic;
    output_voltage_cmd_ready    : in std_logic;
    output_voltage_cmd_firstIdx : out std_logic_vector(INDEX_WIDTH - 1 downto 0);
    output_voltage_cmd_lastIdx  : out std_logic_vector(INDEX_WIDTH - 1 downto 0);
    output_voltage_cmd_ctrl     : out std_logic_vector(OUTPUT_VOLTAGE_BUS_ADDR_WIDTH * 2 - 1 downto 0);
    output_voltage_cmd_tag      : out std_logic_vector(TAG_WIDTH - 1 downto 0);
    plat_complete_req           : out std_logic;
    plat_complete_ack           : in std_logic;
    status                      : inout std_logic_vector(31 downto 0)
  );
end entity;

architecture Implementation of battery_status_Nucleus is
  component battery_status is
    generic (
      INDEX_WIDTH : integer := 32;
      TAG_WIDTH   : integer := 1
    );
    port (
      kcd_clk                     : in std_logic;
      kcd_reset                   : in std_logic;
      input_input_valid           : in std_logic;
      input_input_ready           : out std_logic;
      input_input_dvalid          : in std_logic;
      input_input_last            : in std_logic;
      input_input                 : in std_logic_vector(63 downto 0);
      input_input_count           : in std_logic_vector(3 downto 0);
      input_input_unl_valid       : in std_logic;
      input_input_unl_ready       : out std_logic;
      input_input_unl_tag         : in std_logic_vector(TAG_WIDTH - 1 downto 0);
      input_input_cmd_valid       : out std_logic;
      input_input_cmd_ready       : in std_logic;
      input_input_cmd_firstIdx    : out std_logic_vector(INDEX_WIDTH - 1 downto 0);
      input_input_cmd_lastIdx     : out std_logic_vector(INDEX_WIDTH - 1 downto 0);
      input_input_cmd_tag         : out std_logic_vector(TAG_WIDTH - 1 downto 0);
      output_voltage_valid        : out std_logic;
      output_voltage_ready        : in std_logic;
      output_voltage_dvalid       : out std_logic;
      output_voltage_last         : out std_logic;
      output_voltage_length       : out std_logic_vector(31 downto 0);
      output_voltage_count        : out std_logic_vector(0 downto 0);
      output_voltage_item_valid   : out std_logic;
      output_voltage_item_ready   : in std_logic;
      output_voltage_item_dvalid  : out std_logic;
      output_voltage_item_last    : out std_logic;
      output_voltage_item         : out std_logic_vector(63 downto 0);
      output_voltage_item_count   : out std_logic_vector(0 downto 0);
      output_voltage_unl_valid    : in std_logic;
      output_voltage_unl_ready    : out std_logic;
      output_voltage_unl_tag      : in std_logic_vector(TAG_WIDTH - 1 downto 0);
      output_voltage_cmd_valid    : out std_logic;
      output_voltage_cmd_ready    : in std_logic;
      output_voltage_cmd_firstIdx : out std_logic_vector(INDEX_WIDTH - 1 downto 0);
      output_voltage_cmd_lastIdx  : out std_logic_vector(INDEX_WIDTH - 1 downto 0);
      output_voltage_cmd_tag      : out std_logic_vector(TAG_WIDTH - 1 downto 0);
      start                       : in std_logic;
      stop                        : in std_logic;
      reset                       : in std_logic;
      idle                        : out std_logic;
      busy                        : out std_logic;
      done                        : out std_logic;
      result                      : out std_logic_vector(63 downto 0);
      input_firstidx              : in std_logic_vector(31 downto 0);
      input_lastidx               : in std_logic_vector(31 downto 0);
      output_firstidx             : in std_logic_vector(31 downto 0);
      output_lastidx              : in std_logic_vector(31 downto 0);
      plat_complete_req           : out std_logic;
      plat_complete_ack           : in std_logic
    );
  end component;

  -- signal battery_status_inst_kcd_clk                       : std_logic;
  signal battery_status_inst_kcd_reset                     : std_logic;

  signal battery_status_inst_input_input_valid             : std_logic;
  signal battery_status_inst_input_input_ready             : std_logic;
  signal battery_status_inst_input_input_dvalid            : std_logic;
  signal battery_status_inst_input_input_last              : std_logic;
  signal battery_status_inst_input_input                   : std_logic_vector(63 downto 0);
  signal battery_status_inst_input_input_count             : std_logic_vector(3 downto 0);

  signal battery_status_inst_input_input_unl_valid         : std_logic;
  signal battery_status_inst_input_input_unl_ready         : std_logic;
  signal battery_status_inst_input_input_unl_tag           : std_logic_vector(0 downto 0);

  signal battery_status_inst_input_input_cmd_valid         : std_logic;
  signal battery_status_inst_input_input_cmd_ready         : std_logic;
  signal battery_status_inst_input_input_cmd_firstIdx      : std_logic_vector(31 downto 0);
  signal battery_status_inst_input_input_cmd_lastIdx       : std_logic_vector(31 downto 0);
  signal battery_status_inst_input_input_cmd_tag           : std_logic_vector(0 downto 0);

  signal battery_status_inst_output_voltage_valid          : std_logic;
  signal battery_status_inst_output_voltage_ready          : std_logic;
  signal battery_status_inst_output_voltage_dvalid         : std_logic;
  signal battery_status_inst_output_voltage_last           : std_logic;
  signal battery_status_inst_output_voltage_length         : std_logic_vector(31 downto 0);
  signal battery_status_inst_output_voltage_count          : std_logic_vector(0 downto 0);
  signal battery_status_inst_output_voltage_item_valid     : std_logic;
  signal battery_status_inst_output_voltage_item_ready     : std_logic;
  signal battery_status_inst_output_voltage_item_dvalid    : std_logic;
  signal battery_status_inst_output_voltage_item_last      : std_logic;
  signal battery_status_inst_output_voltage_item           : std_logic_vector(63 downto 0);
  signal battery_status_inst_output_voltage_item_count     : std_logic_vector(0 downto 0);

  signal battery_status_inst_output_voltage_unl_valid      : std_logic;
  signal battery_status_inst_output_voltage_unl_ready      : std_logic;
  signal battery_status_inst_output_voltage_unl_tag        : std_logic_vector(0 downto 0);

  signal battery_status_inst_output_voltage_cmd_valid      : std_logic;
  signal battery_status_inst_output_voltage_cmd_ready      : std_logic;
  signal battery_status_inst_output_voltage_cmd_firstIdx   : std_logic_vector(31 downto 0);
  signal battery_status_inst_output_voltage_cmd_lastIdx    : std_logic_vector(31 downto 0);
  signal battery_status_inst_output_voltage_cmd_tag        : std_logic_vector(0 downto 0);

  signal battery_status_inst_start                         : std_logic;
  signal battery_status_inst_stop                          : std_logic;
  signal battery_status_inst_reset                         : std_logic;
  signal battery_status_inst_idle                          : std_logic;
  signal battery_status_inst_busy                          : std_logic;
  signal battery_status_inst_done                          : std_logic;
  signal battery_status_inst_result                        : std_logic_vector(63 downto 0);
  signal battery_status_inst_input_firstidx                : std_logic_vector(31 downto 0);
  signal battery_status_inst_input_lastidx                 : std_logic_vector(31 downto 0);
  signal battery_status_inst_output_firstidx               : std_logic_vector(31 downto 0);
  signal battery_status_inst_output_lastidx                : std_logic_vector(31 downto 0);
  -- signal mmio_inst_kcd_clk                                 : std_logic;
  signal mmio_inst_kcd_reset                               : std_logic;

  signal mmio_inst_f_start_data                            : std_logic;
  signal mmio_inst_f_stop_data                             : std_logic;
  signal mmio_inst_f_reset_data                            : std_logic;
  signal mmio_inst_f_idle_write_data                       : std_logic;
  signal mmio_inst_f_busy_write_data                       : std_logic;
  signal mmio_inst_f_done_write_data                       : std_logic;
  signal mmio_inst_f_result_write_data                     : std_logic_vector(63 downto 0);
  signal mmio_inst_f_input_firstidx_data                   : std_logic_vector(31 downto 0);
  signal mmio_inst_f_input_lastidx_data                    : std_logic_vector(31 downto 0);
  signal mmio_inst_f_output_firstidx_data                  : std_logic_vector(31 downto 0);
  signal mmio_inst_f_output_lastidx_data                   : std_logic_vector(31 downto 0);
  signal mmio_inst_f_input_input_values_data               : std_logic_vector(63 downto 0);
  signal mmio_inst_f_output_voltage_offsets_data           : std_logic_vector(63 downto 0);
  signal mmio_inst_f_output_voltage_values_data            : std_logic_vector(63 downto 0);
  signal mmio_inst_f_Profile_enable_data                   : std_logic;
  signal mmio_inst_f_Profile_clear_data                    : std_logic;

  signal mmio_inst_f_m_axi_ar_increment                    : std_logic;
  signal mmio_inst_f_m_axi_r_increment                     : std_logic;
  signal mmio_inst_f_m_axi_aw_increment                    : std_logic;
  signal mmio_inst_f_m_axi_w_increment                     : std_logic;
  signal mmio_inst_f_m_axi_b_increment                     : std_logic;

  signal mmio_inst_f_m_axi_wlast_increment                 : std_logic;
  signal mmio_inst_f_m_axi_rlast_increment                 : std_logic;
  signal mmio_inst_f_m_axi_awuser_increment                : std_logic;

  signal mmio_inst_mmio_awvalid                            : std_logic;
  signal mmio_inst_mmio_awready                            : std_logic;
  signal mmio_inst_mmio_awaddr                             : std_logic_vector(31 downto 0);
  signal mmio_inst_mmio_wvalid                             : std_logic;
  signal mmio_inst_mmio_wready                             : std_logic;
  signal mmio_inst_mmio_wdata                              : std_logic_vector(63 downto 0);
  signal mmio_inst_mmio_wstrb                              : std_logic_vector(7 downto 0);
  signal mmio_inst_mmio_bvalid                             : std_logic;
  signal mmio_inst_mmio_bready                             : std_logic;
  signal mmio_inst_mmio_bresp                              : std_logic_vector(1 downto 0);
  signal mmio_inst_mmio_arvalid                            : std_logic;
  signal mmio_inst_mmio_arready                            : std_logic;
  signal mmio_inst_mmio_araddr                             : std_logic_vector(31 downto 0);
  signal mmio_inst_mmio_rvalid                             : std_logic;
  signal mmio_inst_mmio_rready                             : std_logic;
  signal mmio_inst_mmio_rdata                              : std_logic_vector(63 downto 0);
  signal mmio_inst_mmio_rresp                              : std_logic_vector(1 downto 0);

  signal input_input_cmd_accm_inst_kernel_cmd_valid        : std_logic;
  signal input_input_cmd_accm_inst_kernel_cmd_ready        : std_logic;
  signal input_input_cmd_accm_inst_kernel_cmd_firstIdx     : std_logic_vector(INDEX_WIDTH - 1 downto 0);
  signal input_input_cmd_accm_inst_kernel_cmd_lastIdx      : std_logic_vector(INDEX_WIDTH - 1 downto 0);
  signal input_input_cmd_accm_inst_kernel_cmd_tag          : std_logic_vector(TAG_WIDTH - 1 downto 0);

  signal input_input_cmd_accm_inst_nucleus_cmd_valid       : std_logic;
  signal input_input_cmd_accm_inst_nucleus_cmd_ready       : std_logic;
  signal input_input_cmd_accm_inst_nucleus_cmd_firstIdx    : std_logic_vector(INDEX_WIDTH - 1 downto 0);
  signal input_input_cmd_accm_inst_nucleus_cmd_lastIdx     : std_logic_vector(INDEX_WIDTH - 1 downto 0);
  signal input_input_cmd_accm_inst_nucleus_cmd_ctrl        : std_logic_vector(INPUT_INPUT_BUS_ADDR_WIDTH - 1 downto 0);
  signal input_input_cmd_accm_inst_nucleus_cmd_tag         : std_logic_vector(TAG_WIDTH - 1 downto 0);

  signal output_voltage_cmd_accm_inst_kernel_cmd_valid     : std_logic;
  signal output_voltage_cmd_accm_inst_kernel_cmd_ready     : std_logic;
  signal output_voltage_cmd_accm_inst_kernel_cmd_firstIdx  : std_logic_vector(INDEX_WIDTH - 1 downto 0);
  signal output_voltage_cmd_accm_inst_kernel_cmd_lastIdx   : std_logic_vector(INDEX_WIDTH - 1 downto 0);
  signal output_voltage_cmd_accm_inst_kernel_cmd_tag       : std_logic_vector(TAG_WIDTH - 1 downto 0);

  signal output_voltage_cmd_accm_inst_nucleus_cmd_valid    : std_logic;
  signal output_voltage_cmd_accm_inst_nucleus_cmd_ready    : std_logic;
  signal output_voltage_cmd_accm_inst_nucleus_cmd_firstIdx : std_logic_vector(INDEX_WIDTH - 1 downto 0);
  signal output_voltage_cmd_accm_inst_nucleus_cmd_lastIdx  : std_logic_vector(INDEX_WIDTH - 1 downto 0);
  signal output_voltage_cmd_accm_inst_nucleus_cmd_ctrl     : std_logic_vector(2 * OUTPUT_VOLTAGE_BUS_ADDR_WIDTH - 1 downto 0);
  signal output_voltage_cmd_accm_inst_nucleus_cmd_tag      : std_logic_vector(TAG_WIDTH - 1 downto 0);

  signal input_input_cmd_accm_inst_ctrl                    : std_logic_vector(INPUT_INPUT_BUS_ADDR_WIDTH - 1 downto 0);
  signal output_voltage_cmd_accm_inst_ctrl                 : std_logic_vector(2 * OUTPUT_VOLTAGE_BUS_ADDR_WIDTH - 1 downto 0);

  signal dingen_status, dingen_control                     : std_logic_vector(63 downto 0);

begin

  status <= (
    -- 12 => battery_status_inst_input_input_ready, 13 => battery_status_inst_input_input_valid,                 -- 01
    -- 14 => battery_status_inst_input_input_unl_ready, 15 => battery_status_inst_input_input_unl_valid,         -- 00
    -- 16 => battery_status_inst_input_input_cmd_ready, 17 => battery_status_inst_input_input_cmd_valid,         --  01 
    18 => battery_status_inst_output_voltage_ready, 19 => battery_status_inst_output_voltage_valid,           -- 01
    20 => battery_status_inst_output_voltage_item_ready, 21 => battery_status_inst_output_voltage_item_valid, -- 01 
    22 => battery_status_inst_output_voltage_unl_ready, 23 => battery_status_inst_output_voltage_unl_valid,   --00 
    24 => battery_status_inst_output_voltage_cmd_ready, 25 => battery_status_inst_output_voltage_cmd_valid,   --01 
    26     => battery_status_inst_input_input_last,
    27     => battery_status_inst_output_voltage_last,
    28     => battery_status_inst_output_voltage_item_last,
    others => 'Z'
    );

  mmio_inst_f_m_axi_ar_increment     <= status(0) and status(1);
  mmio_inst_f_m_axi_r_increment      <= status(2) and status(3);
  mmio_inst_f_m_axi_aw_increment     <= status(4) and status(5);
  mmio_inst_f_m_axi_w_increment      <= status(6) and status(7);
  mmio_inst_f_m_axi_b_increment      <= status(8) and status(9);

  mmio_inst_f_m_axi_wlast_increment  <= status(6) and status(7) and status(31);
  mmio_inst_f_m_axi_rlast_increment  <= status(2) and status(3) and status(30);
  mmio_inst_f_m_axi_awuser_increment <= status(4) and status(5) and status(29);

  battery_status_inst : battery_status
  generic map(
    INDEX_WIDTH => 32,
    TAG_WIDTH   => 1
  )
  port map(
    kcd_clk                     => kcd_clk,
    kcd_reset                   => battery_status_inst_kcd_reset,
    input_input_valid           => battery_status_inst_input_input_valid,
    input_input_ready           => battery_status_inst_input_input_ready,
    input_input_dvalid          => battery_status_inst_input_input_dvalid,
    input_input_last            => battery_status_inst_input_input_last,
    input_input                 => battery_status_inst_input_input,
    input_input_count           => battery_status_inst_input_input_count,
    input_input_unl_valid       => battery_status_inst_input_input_unl_valid,
    input_input_unl_ready       => battery_status_inst_input_input_unl_ready,
    input_input_unl_tag         => battery_status_inst_input_input_unl_tag,
    input_input_cmd_valid       => battery_status_inst_input_input_cmd_valid,
    input_input_cmd_ready       => battery_status_inst_input_input_cmd_ready,
    input_input_cmd_firstIdx    => battery_status_inst_input_input_cmd_firstIdx,
    input_input_cmd_lastIdx     => battery_status_inst_input_input_cmd_lastIdx,
    input_input_cmd_tag         => battery_status_inst_input_input_cmd_tag,
    output_voltage_valid        => battery_status_inst_output_voltage_valid,
    output_voltage_ready        => battery_status_inst_output_voltage_ready,
    output_voltage_dvalid       => battery_status_inst_output_voltage_dvalid,
    output_voltage_last         => battery_status_inst_output_voltage_last,
    output_voltage_length       => battery_status_inst_output_voltage_length,
    output_voltage_count        => battery_status_inst_output_voltage_count,
    output_voltage_item_valid   => battery_status_inst_output_voltage_item_valid,
    output_voltage_item_ready   => battery_status_inst_output_voltage_item_ready,
    output_voltage_item_dvalid  => battery_status_inst_output_voltage_item_dvalid,
    output_voltage_item_last    => battery_status_inst_output_voltage_item_last,
    output_voltage_item         => battery_status_inst_output_voltage_item,
    output_voltage_item_count   => battery_status_inst_output_voltage_item_count,
    output_voltage_unl_valid    => battery_status_inst_output_voltage_unl_valid,
    output_voltage_unl_ready    => battery_status_inst_output_voltage_unl_ready,
    output_voltage_unl_tag      => battery_status_inst_output_voltage_unl_tag,
    output_voltage_cmd_valid    => battery_status_inst_output_voltage_cmd_valid,
    output_voltage_cmd_ready    => battery_status_inst_output_voltage_cmd_ready,
    output_voltage_cmd_firstIdx => battery_status_inst_output_voltage_cmd_firstIdx,
    output_voltage_cmd_lastIdx  => battery_status_inst_output_voltage_cmd_lastIdx,
    output_voltage_cmd_tag      => battery_status_inst_output_voltage_cmd_tag,
    start                       => battery_status_inst_start,
    stop                        => battery_status_inst_stop,
    reset                       => battery_status_inst_reset,
    idle                        => battery_status_inst_idle,
    busy                        => battery_status_inst_busy,
    done                        => battery_status_inst_done,
    result                      => battery_status_inst_result,
    input_firstidx              => battery_status_inst_input_firstidx,
    input_lastidx               => battery_status_inst_input_lastidx,
    output_firstidx             => battery_status_inst_output_firstidx,
    output_lastidx              => battery_status_inst_output_lastidx,
    plat_complete_ack           => plat_complete_ack,
    plat_complete_req           => plat_complete_req
  );

  mmio_inst : mmio
  port map(
    kcd_clk                       => kcd_clk,
    kcd_reset                     => mmio_inst_kcd_reset,
    f_start_data                  => mmio_inst_f_start_data,
    f_stop_data                   => mmio_inst_f_stop_data,
    f_reset_data                  => mmio_inst_f_reset_data,
    f_idle_write_data             => mmio_inst_f_idle_write_data,
    f_busy_write_data             => mmio_inst_f_busy_write_data,
    f_done_write_data             => mmio_inst_f_done_write_data,
    f_result_write_data           => mmio_inst_f_result_write_data,
    f_input_firstidx_data         => mmio_inst_f_input_firstidx_data,
    f_input_lastidx_data          => mmio_inst_f_input_lastidx_data,
    f_output_firstidx_data        => mmio_inst_f_output_firstidx_data,
    f_output_lastidx_data         => mmio_inst_f_output_lastidx_data,
    f_input_input_values_data     => mmio_inst_f_input_input_values_data,
    f_output_voltage_offsets_data => mmio_inst_f_output_voltage_offsets_data,
    f_output_voltage_values_data  => mmio_inst_f_output_voltage_values_data,
    f_clk_counter_increment       => '1',
    f_stream_status_write_data    => status,
    f_dingen_vhd_write_data       => dingen_status,
    f_dingen_vhd_control_data     => dingen_control,
    f_m_axi_ar_increment          => mmio_inst_f_m_axi_ar_increment,
    f_m_axi_r_increment           => mmio_inst_f_m_axi_r_increment,
    f_m_axi_aw_increment          => mmio_inst_f_m_axi_aw_increment,
    f_m_axi_w_increment           => mmio_inst_f_m_axi_w_increment,
    f_m_axi_b_increment           => mmio_inst_f_m_axi_b_increment,
    f_m_axi_wlast_increment       => mmio_inst_f_m_axi_wlast_increment,
    f_m_axi_rlast_increment       => mmio_inst_f_m_axi_rlast_increment,
    f_m_axi_awuser_increment      => mmio_inst_f_m_axi_awuser_increment,
    mmio_awvalid                  => mmio_inst_mmio_awvalid,
    mmio_awready                  => mmio_inst_mmio_awready,
    mmio_awaddr                   => mmio_inst_mmio_awaddr,
    mmio_wvalid                   => mmio_inst_mmio_wvalid,
    mmio_wready                   => mmio_inst_mmio_wready,
    mmio_wdata                    => mmio_inst_mmio_wdata,
    mmio_wstrb                    => mmio_inst_mmio_wstrb,
    mmio_bvalid                   => mmio_inst_mmio_bvalid,
    mmio_bready                   => mmio_inst_mmio_bready,
    mmio_bresp                    => mmio_inst_mmio_bresp,
    mmio_arvalid                  => mmio_inst_mmio_arvalid,
    mmio_arready                  => mmio_inst_mmio_arready,
    mmio_araddr                   => mmio_inst_mmio_araddr,
    mmio_rvalid                   => mmio_inst_mmio_rvalid,
    mmio_rready                   => mmio_inst_mmio_rready,
    mmio_rdata                    => mmio_inst_mmio_rdata,
    mmio_rresp                    => mmio_inst_mmio_rresp
  );

  input_input_cmd_accm_inst : ArrayCmdCtrlMerger
  generic map(
    NUM_ADDR       => 1,
    BUS_ADDR_WIDTH => INPUT_INPUT_BUS_ADDR_WIDTH,
    INDEX_WIDTH    => INDEX_WIDTH,
    TAG_WIDTH      => TAG_WIDTH
  )
  port map(
    kernel_cmd_valid     => input_input_cmd_accm_inst_kernel_cmd_valid,
    kernel_cmd_ready     => input_input_cmd_accm_inst_kernel_cmd_ready,
    kernel_cmd_firstIdx  => input_input_cmd_accm_inst_kernel_cmd_firstIdx,
    kernel_cmd_lastIdx   => input_input_cmd_accm_inst_kernel_cmd_lastIdx,
    kernel_cmd_tag       => input_input_cmd_accm_inst_kernel_cmd_tag,
    nucleus_cmd_valid    => input_input_cmd_accm_inst_nucleus_cmd_valid,
    nucleus_cmd_ready    => input_input_cmd_accm_inst_nucleus_cmd_ready,
    nucleus_cmd_firstIdx => input_input_cmd_accm_inst_nucleus_cmd_firstIdx,
    nucleus_cmd_lastIdx  => input_input_cmd_accm_inst_nucleus_cmd_lastIdx,
    nucleus_cmd_ctrl     => input_input_cmd_accm_inst_nucleus_cmd_ctrl,
    nucleus_cmd_tag      => input_input_cmd_accm_inst_nucleus_cmd_tag,
    ctrl                 => input_input_cmd_accm_inst_ctrl
  );

  output_voltage_cmd_accm_inst : ArrayCmdCtrlMerger
  generic map(
    NUM_ADDR       => 2,
    BUS_ADDR_WIDTH => OUTPUT_VOLTAGE_BUS_ADDR_WIDTH,
    INDEX_WIDTH    => INDEX_WIDTH,
    TAG_WIDTH      => TAG_WIDTH
  )
  port map(
    kernel_cmd_valid     => output_voltage_cmd_accm_inst_kernel_cmd_valid,
    kernel_cmd_ready     => output_voltage_cmd_accm_inst_kernel_cmd_ready,
    kernel_cmd_firstIdx  => output_voltage_cmd_accm_inst_kernel_cmd_firstIdx,
    kernel_cmd_lastIdx   => output_voltage_cmd_accm_inst_kernel_cmd_lastIdx,
    kernel_cmd_tag       => output_voltage_cmd_accm_inst_kernel_cmd_tag,
    nucleus_cmd_valid    => output_voltage_cmd_accm_inst_nucleus_cmd_valid,
    nucleus_cmd_ready    => output_voltage_cmd_accm_inst_nucleus_cmd_ready,
    nucleus_cmd_firstIdx => output_voltage_cmd_accm_inst_nucleus_cmd_firstIdx,
    nucleus_cmd_lastIdx  => output_voltage_cmd_accm_inst_nucleus_cmd_lastIdx,
    nucleus_cmd_ctrl     => output_voltage_cmd_accm_inst_nucleus_cmd_ctrl,
    nucleus_cmd_tag      => output_voltage_cmd_accm_inst_nucleus_cmd_tag,
    ctrl                 => output_voltage_cmd_accm_inst_ctrl
  );

  dingen_vhd_inst : entity work.dingen_vhd generic map(
    DATA_WIDTH  => 52,
    COUNT_WIDTH => 12,
    DEPTH_LOG2  => 10
    )
    port map(
      clk               => kcd_clk,
      data(51 downto 32) => (others => '0'),
      data(31 downto 0) => status,
      control           => dingen_control,
      status            => dingen_status
    );

  input_input_cmd_valid                            <= input_input_cmd_accm_inst_nucleus_cmd_valid;
  input_input_cmd_accm_inst_nucleus_cmd_ready      <= input_input_cmd_ready;
  input_input_cmd_firstIdx                         <= input_input_cmd_accm_inst_nucleus_cmd_firstIdx;
  input_input_cmd_lastIdx                          <= input_input_cmd_accm_inst_nucleus_cmd_lastIdx;
  input_input_cmd_ctrl                             <= input_input_cmd_accm_inst_nucleus_cmd_ctrl;
  input_input_cmd_tag                              <= input_input_cmd_accm_inst_nucleus_cmd_tag;

  output_voltage_valid                             <= battery_status_inst_output_voltage_valid;
  battery_status_inst_output_voltage_ready         <= output_voltage_ready;
  output_voltage_dvalid                            <= battery_status_inst_output_voltage_dvalid;
  output_voltage_last                              <= battery_status_inst_output_voltage_last;
  output_voltage_length                            <= battery_status_inst_output_voltage_length;
  output_voltage_count                             <= battery_status_inst_output_voltage_count;
  output_voltage_item_valid                        <= battery_status_inst_output_voltage_item_valid;
  battery_status_inst_output_voltage_item_ready    <= output_voltage_item_ready;
  output_voltage_item_dvalid                       <= battery_status_inst_output_voltage_item_dvalid;
  output_voltage_item_last                         <= battery_status_inst_output_voltage_item_last;
  output_voltage_item                              <= battery_status_inst_output_voltage_item;
  output_voltage_item_count                        <= battery_status_inst_output_voltage_item_count;

  output_voltage_cmd_valid                         <= output_voltage_cmd_accm_inst_nucleus_cmd_valid;
  output_voltage_cmd_accm_inst_nucleus_cmd_ready   <= output_voltage_cmd_ready;
  output_voltage_cmd_firstIdx                      <= output_voltage_cmd_accm_inst_nucleus_cmd_firstIdx;
  output_voltage_cmd_lastIdx                       <= output_voltage_cmd_accm_inst_nucleus_cmd_lastIdx;
  output_voltage_cmd_ctrl                          <= output_voltage_cmd_accm_inst_nucleus_cmd_ctrl;
  output_voltage_cmd_tag                           <= output_voltage_cmd_accm_inst_nucleus_cmd_tag;

  -- battery_status_inst_kcd_clk                      <= kcd_clk;
  battery_status_inst_kcd_reset                    <= kcd_reset;

  battery_status_inst_input_input_valid            <= input_input_valid;
  input_input_ready                                <= battery_status_inst_input_input_ready;
  battery_status_inst_input_input_dvalid           <= input_input_dvalid;
  battery_status_inst_input_input_last             <= input_input_last;
  battery_status_inst_input_input                  <= input_input;
  battery_status_inst_input_input_count            <= input_input_count;

  battery_status_inst_input_input_unl_valid        <= input_input_unl_valid;
  input_input_unl_ready                            <= battery_status_inst_input_input_unl_ready;
  battery_status_inst_input_input_unl_tag          <= input_input_unl_tag;

  battery_status_inst_output_voltage_unl_valid     <= output_voltage_unl_valid;
  output_voltage_unl_ready                         <= battery_status_inst_output_voltage_unl_ready;
  battery_status_inst_output_voltage_unl_tag       <= output_voltage_unl_tag;

  battery_status_inst_start                        <= mmio_inst_f_start_data;
  battery_status_inst_stop                         <= mmio_inst_f_stop_data;
  battery_status_inst_reset                        <= mmio_inst_f_reset_data;
  battery_status_inst_input_firstidx               <= mmio_inst_f_input_firstidx_data;
  battery_status_inst_input_lastidx                <= mmio_inst_f_input_lastidx_data;
  battery_status_inst_output_firstidx              <= mmio_inst_f_output_firstidx_data;
  battery_status_inst_output_lastidx               <= mmio_inst_f_output_lastidx_data;
  -- mmio_inst_kcd_clk                                <= kcd_clk;
  mmio_inst_kcd_reset                              <= kcd_reset;

  mmio_inst_f_idle_write_data                      <= battery_status_inst_idle;
  mmio_inst_f_busy_write_data                      <= battery_status_inst_busy;
  mmio_inst_f_done_write_data                      <= battery_status_inst_done;
  mmio_inst_f_result_write_data                    <= battery_status_inst_result;
  mmio_inst_mmio_awvalid                           <= mmio_awvalid;
  mmio_awready                                     <= mmio_inst_mmio_awready;
  mmio_inst_mmio_awaddr                            <= mmio_awaddr;
  mmio_inst_mmio_wvalid                            <= mmio_wvalid;
  mmio_wready                                      <= mmio_inst_mmio_wready;
  mmio_inst_mmio_wdata                             <= mmio_wdata;
  mmio_inst_mmio_wstrb                             <= mmio_wstrb;
  mmio_bvalid                                      <= mmio_inst_mmio_bvalid;
  mmio_inst_mmio_bready                            <= mmio_bready;
  mmio_bresp                                       <= mmio_inst_mmio_bresp;
  mmio_inst_mmio_arvalid                           <= mmio_arvalid;
  mmio_arready                                     <= mmio_inst_mmio_arready;
  mmio_inst_mmio_araddr                            <= mmio_araddr;
  mmio_rvalid                                      <= mmio_inst_mmio_rvalid;
  mmio_inst_mmio_rready                            <= mmio_rready;
  mmio_rdata                                       <= mmio_inst_mmio_rdata;
  mmio_rresp                                       <= mmio_inst_mmio_rresp;

  input_input_cmd_accm_inst_kernel_cmd_valid       <= battery_status_inst_input_input_cmd_valid;
  battery_status_inst_input_input_cmd_ready        <= input_input_cmd_accm_inst_kernel_cmd_ready;
  input_input_cmd_accm_inst_kernel_cmd_firstIdx    <= battery_status_inst_input_input_cmd_firstIdx;
  input_input_cmd_accm_inst_kernel_cmd_lastIdx     <= battery_status_inst_input_input_cmd_lastIdx;
  input_input_cmd_accm_inst_kernel_cmd_tag         <= battery_status_inst_input_input_cmd_tag;

  output_voltage_cmd_accm_inst_kernel_cmd_valid    <= battery_status_inst_output_voltage_cmd_valid;
  battery_status_inst_output_voltage_cmd_ready     <= output_voltage_cmd_accm_inst_kernel_cmd_ready;
  output_voltage_cmd_accm_inst_kernel_cmd_firstIdx <= battery_status_inst_output_voltage_cmd_firstIdx;
  output_voltage_cmd_accm_inst_kernel_cmd_lastIdx  <= battery_status_inst_output_voltage_cmd_lastIdx;
  output_voltage_cmd_accm_inst_kernel_cmd_tag      <= battery_status_inst_output_voltage_cmd_tag;

  input_input_cmd_accm_inst_ctrl(63 downto 0)      <= mmio_inst_f_input_input_values_data;
  output_voltage_cmd_accm_inst_ctrl(63 downto 0)   <= mmio_inst_f_output_voltage_offsets_data;
  output_voltage_cmd_accm_inst_ctrl(127 downto 64) <= mmio_inst_f_output_voltage_values_data;

end architecture;