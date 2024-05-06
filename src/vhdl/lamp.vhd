library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.condor_pl_pkg.all;
use work.sim_pkg.all;
use work.regs_pkg.all;

entity lamp is
    port(
        clk                : in  std_logic;
        sync_rst           : in  std_logic;
        registers          : in  reg_array_t;
        --regs_updating    : in  reg_slv_array_t;
        --regs_reading     : in  reg_slv_array_t;
        --internal_regs    : out reg_array_t;
        --internal_regs_we : out reg_slv_array_t;
        lamp_stat          : out std_logic
    );
end entity lamp;

architecture RTL of lamp is
    type lamp_status_t is (lamp_off, lamp_on, lamp1Hz, lamp4Hz);

    signal stat_28vdc_good    : std_logic;
    signal stat_115vac_good   : std_logic;
    signal stat_MIU_comm_good : std_logic;
    signal stat_power_on      : std_logic;
    signal PSU_status         : std_logic_vector(PSU_Status_range);
begin
    PSU_Status <= registers(LOG_PSU_STATUS_H) & registers(LOG_PSU_STATUS_L);
    
--    stat_28vdc_good    <= not PSU_Status(psu_status_DC_IN_Status);
--    stat_115vac_good   <= not PSU_Status(psu_status_AC_IN_Status);
--    stat_MIU_comm_good <= PSU_Status(psu_status_MIU_COM_Status);
    stat_power_on      <= PSU_Status(psu_status_ON_OFF_Switch_State);
    stat_28vdc_good    <= not PSU_Status(psu_status_DC_IN_UV); 
    stat_115vac_good   <=  not PSU_Status(psu_status_AC_IN_PH1_UV) and not PSU_Status(psu_status_AC_IN_PH2_UV) and not PSU_Status(psu_status_AC_IN_PH3_UV);  
    stat_MIU_comm_good <= '1'; -- assume on as we don't have SW yet

    gen_led_pr: process(clk)
        variable cnt : integer range 0 to 100_000_000;
        CONSTANT CNT_HALF_1Hz : integer := 50_000_000;-- how many 100MHz ticks in half a second
        CONSTANT CNT_HALF_4Hz : integer := 12_500_000;-- how many 100MHz ticks in 1/8th of a second
        variable state : lamp_status_t;    
    begin
        if rising_edge(clk) then
            if sync_rst then
                lamp_stat <= '0';
                state := lamp_off;
                cnt := 0;
            else
                if not stat_28vdc_good and not stat_115vac_good then
                    state := lamp_off;
                elsif stat_28vdc_good and not stat_115vac_good then
                    state := lamp1Hz;
                elsif not stat_28vdc_good and stat_115vac_good then
                    state := lamp_off;
                elsif stat_28vdc_good and stat_115vac_good and not stat_power_on then
                    state := lamp_on;
                elsif stat_28vdc_good and stat_115vac_good and stat_power_on and not stat_MIU_comm_good then
                    state := lamp4Hz;
                elsif stat_28vdc_good and stat_115vac_good and stat_power_on and stat_MIU_comm_good then
                    state := lamp_off;
                end if;
                
                case state is 
                when lamp_off =>
                    lamp_stat <= '0';
                    cnt := 0;
                when lamp_on =>
                    lamp_stat <= '1';
                    cnt := 0;
                when lamp1Hz =>
                    cnt := cnt + 1;
                    if cnt >= CNT_HALF_1Hz then
                        lamp_stat <= not lamp_stat;
                        cnt := 0;
                    end if;
                when lamp4Hz =>
                    cnt := cnt + 1;
                    if cnt >= CNT_HALF_4Hz then
                        lamp_stat <= not lamp_stat;
                        cnt := 0;
                    end if;
                end case;
                
            end if;
        end if;
    end process;
    
end architecture RTL;
