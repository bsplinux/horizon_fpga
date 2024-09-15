library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.condor_pl_pkg.all;
use work.sim_pkg.all;
use work.regs_pkg.all;

entity limits is
    port(
        clk               : in  std_logic;
        sync_rst          : in  std_logic;
        registers         : in  reg_array_t;
        limits_stat       : out std_logic_vector(limits_range);
        lamp_state        : out std_logic_vector(1 downto 0);
        lamp_out          : out std_logic;
        P_IN_STATUS_FPGA  : out std_logic;
        P_OUT_STATUS_FPGA : out std_logic
    );
end entity limits;

architecture RTL of limits is
    signal uvp_error : std_logic;
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
    signal stat_115_a_in : std_logic;
    signal stat_115_b_in : std_logic;
    signal stat_115_c_in : std_logic;
    signal stat_115_a_out : std_logic;
    signal stat_115_b_out : std_logic;
    signal stat_115_c_out : std_logic;
    signal stat_v_out4_out : std_logic;
    signal relays_ok : std_logic;
    signal relay1_ok : std_logic;
    signal relay2_ok : std_logic;
    signal relay3_ok : std_logic;
    signal lamp_28vdc : std_logic;
    signal lamp_115vac : std_logic;
    signal AC_IN_PH1_UV : std_logic;
    signal AC_IN_PH2_UV : std_logic;
    signal AC_IN_PH3_UV : std_logic;
    signal DC_IN_UV     : std_logic;
    
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
        stat_115_a_in     => stat_115_a_in,
        stat_115_b_in     => stat_115_b_in,
        stat_115_c_in     => stat_115_c_in,
        stat_28_dc_in     => stat_28_dc_in,
        stat_115_ac_out   => stat_115_ac_out,
        stat_115_a_out    => stat_115_a_out,
        stat_115_b_out    => stat_115_b_out,
        stat_115_c_out    => stat_115_c_out,
        stat_v_out4_out   => stat_v_out4_out,
        stat_dc1_out      => stat_dc1_out,
        stat_dc2_out      => stat_dc2_out,
        stat_dc5_out      => stat_dc5_out,
        stat_dc6_out      => stat_dc6_out,
        stat_dc7_out      => stat_dc7_out,
        stat_dc8_out      => stat_dc8_out,
        stat_dc9_out      => stat_dc9_out,
        stat_dc10_out     => stat_dc10_out
    );

    uvp_i: entity work.uvp
    port map(
        clk             => clk,
        sync_rst        => sync_rst,
        registers       => registers,
        uvp_error       => uvp_error,
        AC_IN_PH1_UV    => AC_IN_PH1_UV,
        AC_IN_PH2_UV    => AC_IN_PH2_UV,
        AC_IN_PH3_UV    => AC_IN_PH3_UV,
        DC_IN_UV        => DC_IN_UV    
    );
    
    limits_stat(limit_uvp)             <= uvp_error                              ;
    limits_stat(limit_uvp_ph1)         <= AC_IN_PH1_UV                           ;
    limits_stat(limit_uvp_ph2)         <= AC_IN_PH2_UV                           ;
    limits_stat(limit_uvp_ph3)         <= AC_IN_PH3_UV                           ;
    limits_stat(limit_uvp_dc)          <= DC_IN_UV                               ;
    limits_stat(limit_stat_p_in)       <= P_IN_STATUS_FPGA                       ;
    limits_stat(limit_stat_p_out)      <= P_OUT_STATUS_FPGA                      ;
    limits_stat(limit_stat_115_ac_in ) <= stat_115_ac_in                         ;
    limits_stat(limit_stat_115_a_in  ) <= stat_115_a_in                          ;
    limits_stat(limit_stat_115_b_in  ) <= stat_115_b_in                          ;
    limits_stat(limit_stat_115_c_in  ) <= stat_115_c_in                          ;
    limits_stat(limit_stat_28_dc_in  ) <= stat_28_dc_in                          ;
    limits_stat(limit_stat_115_ac_out) <= stat_115_ac_out                        ;
    limits_stat(limit_stat_115_a_out ) <= stat_115_a_out                         ;
    limits_stat(limit_stat_115_b_out ) <= stat_115_b_out                         ;
    limits_stat(limit_stat_115_c_out ) <= stat_115_c_out                         ;
    limits_stat(limit_stat_v_out4_out) <= stat_v_out4_out                        ;
    limits_stat(limit_stat_dc1_out   ) <= stat_dc1_out                           ;
    limits_stat(limit_stat_dc2_out   ) <= stat_dc2_out                           ;
    limits_stat(limit_stat_dc5_out   ) <= stat_dc5_out                           ;
    limits_stat(limit_stat_dc6_out   ) <= stat_dc6_out                           ;
    limits_stat(limit_stat_dc7_out   ) <= stat_dc7_out                           ;
    limits_stat(limit_stat_dc8_out   ) <= stat_dc8_out                           ;
    limits_stat(limit_stat_dc9_out   ) <= stat_dc9_out                           ;
    limits_stat(limit_stat_dc10_out  ) <= stat_dc10_out                          ;
    limits_stat(limit_relay_3p       ) <= relays_ok                              ;   
    limits_stat(limit_relay_3p_a     ) <= relay1_ok                              ;   
    limits_stat(limit_relay_3p_b     ) <= relay2_ok                              ;   
    limits_stat(limit_relay_3p_c     ) <= relay3_ok                              ;   
    limits_stat(limit_lamp_28vdc     ) <= lamp_28vdc                             ;
    limits_stat(limit_lamp_115vac    ) <= lamp_115vac                            ;
    
    lamp_i: entity work.lamp
    port map(
        clk              => clk,
        sync_rst         => sync_rst,
        registers        => registers,
        stat_28vdc_good  => lamp_28vdc,
        stat_115vac_good => lamp_115vac,
        lamp_state       => lamp_state,
        lamp_out         => lamp_out
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
