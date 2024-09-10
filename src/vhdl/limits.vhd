library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.condor_pl_pkg.all;
use work.sim_pkg.all;
use work.regs_pkg.all;

entity limits is
    port(
        clk              : in  std_logic;
        sync_rst         : in  std_logic;
        registers        : in  reg_array_t;
--        regs_updating    : in  reg_slv_array_t;
--        regs_reading     : in  reg_slv_array_t;
--        internal_regs    : out reg_array_t;
--        internal_regs_we : out reg_slv_array_t;
        PSU_Status       : out std_logic_vector(PSU_Status_range);
        PSU_Status_mask  : out std_logic_vector(PSU_Status_range);
        limits_stat      : out std_logic_vector(limits_range);
        lamp_stat        : out std_logic
--        power_2_ios      : in  power_2_ios_t
    );
end entity limits;

architecture RTL of limits is
    signal uvp_error : std_logic;
    signal PSU_Status_uvp : std_logic_vector(PSU_Status_range);
    signal PSU_Status_mask_uvp : std_logic_vector(PSU_Status_range);
    signal P_IN_STATUS_FPGA : std_logic;
    signal P_OUT_STATUS_FPGA : std_logic;
    signal PSU_Status_logic : std_logic_vector(PSU_Status_range);
    signal PSU_Status_mask_logic : std_logic_vector(PSU_Status_range);
    signal stat_115_ac_in : std_logic;
    signal stat_28_dc_in : std_logic;
    signal stat_115_ac_out : std_logic;
    signal stat_dc1_out : std_logic;
    signal stat_dc2_out : std_logic;
    signal stat_dc5_out : std_logic;
    signal stat_dc6_out : std_logic;
    signal stat_dc7_out : std_logic;
    signal stat_dc8_out : std_logic;
    signal stat_dc9_out : std_logic;
    signal stat_dc10_out : std_logic;
    signal relays_ok : std_logic;
    signal relay1_ok : std_logic;
    signal relay2_ok : std_logic;
    signal relay3_ok : std_logic;

begin
    -- over voltage
    -- over temperatue
    -- over current
    -- power in/out status for logic statuses
    logic_status_i: entity work.logic_status
    port map(
        clk               => clk,
        sync_rst          => sync_rst,
        registers         => registers,
        P_IN_STATUS_FPGA  => P_IN_STATUS_FPGA,
        P_OUT_STATUS_FPGA => P_OUT_STATUS_FPGA,
        stat_115_ac_in    => stat_115_ac_in,
        stat_28_dc_in     => stat_28_dc_in,
        stat_115_ac_out   => stat_115_ac_out,
        stat_dc1_out      => stat_dc1_out,
        stat_dc2_out      => stat_dc2_out,
        stat_dc5_out      => stat_dc5_out,
        stat_dc6_out      => stat_dc6_out,
        stat_dc7_out      => stat_dc7_out,
        stat_dc8_out      => stat_dc8_out,
        stat_dc9_out      => stat_dc9_out,
        stat_dc10_out     => stat_dc10_out,
        PSU_Status        => PSU_Status_logic,
        PSU_Status_mask   => PSU_Status_mask_logic
    );
    
    uvp_i: entity work.uvp
    port map(
        clk             => clk,
        sync_rst        => sync_rst,
        registers       => registers,
        uvp_error       => uvp_error,
        PSU_Status      => PSU_Status_uvp,
        PSU_Status_mask => PSU_Status_mask_uvp
    );
    
    PSU_status <=  (PSU_status_uvp and PSU_status_mask_uvp) or (PSU_status_logic and PSU_status_mask_logic);
    PSU_status_mask <= PSU_status_mask_uvp and PSU_status_mask_logic;
    
    limits_stat(limit_uvp)             <= uvp_error;
    limits_stat(limit_uvp_ph1)         <= PSU_Status_uvp(psu_status_AC_IN_PH1_UV);
    limits_stat(limit_uvp_ph2)         <= PSU_Status_uvp(psu_status_AC_IN_PH2_UV);
    limits_stat(limit_uvp_ph3)         <= PSU_Status_uvp(psu_status_AC_IN_PH3_UV);
    limits_stat(limit_uvp_dc)          <= PSU_Status_uvp(psu_status_DC_IN_UV)    ;
    limits_stat(limit_stat_p_in)       <= P_IN_STATUS_FPGA       ;
    limits_stat(limit_stat_p_out)      <= P_OUT_STATUS_FPGA      ;
    limits_stat(limit_stat_115_ac_in ) <= stat_115_ac_in ;
    limits_stat(limit_stat_28_dc_in  ) <= stat_28_dc_in  ;
    limits_stat(limit_stat_115_ac_out) <= stat_115_ac_out;
    limits_stat(limit_stat_dc1_out   ) <= stat_dc1_out   ;
    limits_stat(limit_stat_dc2_out   ) <= stat_dc2_out   ;
    limits_stat(limit_stat_dc5_out   ) <= stat_dc5_out   ;
    limits_stat(limit_stat_dc6_out   ) <= stat_dc6_out   ;
    limits_stat(limit_stat_dc7_out   ) <= stat_dc7_out   ;
    limits_stat(limit_stat_dc8_out   ) <= stat_dc8_out   ;
    limits_stat(limit_stat_dc9_out   ) <= stat_dc9_out   ;
    limits_stat(limit_stat_dc10_out  ) <= stat_dc10_out  ;
    limits_stat(limit_relay_3p       ) <= relays_ok      ;   
    limits_stat(limit_relay_3p_a     ) <= relay1_ok      ;   
    limits_stat(limit_relay_3p_b     ) <= relay2_ok      ;   
    limits_stat(limit_relay_3p_c     ) <= relay3_ok      ;   
    
    lamp_i: entity work.lamp
    port map(
        clk       => clk,
        sync_rst  => sync_rst,
        registers => registers,
        lamp_stat => lamp_stat
    );
    
    relay_limits_i: entity work.relay_limits
    port map(
        clk       => clk,
        sync_rst  => sync_rst,
        registers => registers,
        relays_ok  => relays_ok,
        relay1_ok  => relay1_ok,
        relay2_ok  => relay2_ok,
        relay3_ok  => relay3_ok
    );
    
    
end architecture RTL;
