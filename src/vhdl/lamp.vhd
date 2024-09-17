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
        stat_28vdc_good    : out std_logic;
        stat_115vac_good   : out std_logic;
        lamp_state         : out std_logic_vector(1 downto 0);
        lamp_out           : out std_logic
    );
end entity lamp;

architecture RTL of lamp is
    type lamp_status_t is (lamp_off, lamp_on, lamp1Hz, lamp4Hz);

    signal stat_MIU_comm_good : std_logic;
    signal stat_power_on      : std_logic;
    signal v28_in             : signed(15 downto 0);
    signal vph1,vph2,vph3     : signed(15 downto 0);
    
    constant LIMIT_18  : integer := 360 ; -- 18[V] / 0.05 [V/UNIT] = 360 [UNITS]
    constant LIMIT_32  : integer := 640 ; -- 32[V] / 0.05 [V/UNIT] = 640 [UNITS]

    constant LIMIT_125 : integer := 1250; -- 125[V] / 0.1 [V/UNIT] = 1250 [UNITS]
    constant LIMIT_95  : integer :=  950; --  95[V] / 0.1 [V/UNIT] =  950 [UNITS]
    
begin
    stat_power_on      <= registers(GENERAL_STATUS)(GENERAL_STATUS_power_on_debaunced);
    stat_MIU_comm_good <= registers(CPU_STATUS)(CPU_STATUS_MIU_COM_Status); 

    v28_in <= signed(registers(SPI_28V_IN_sns)(15 downto 0));
    vph1   <= signed(registers(SPI_RMS_Vsns_PH1)(15 downto 0));
    vph2   <= signed(registers(SPI_RMS_Vsns_PH2)(15 downto 0));
    vph3   <= signed(registers(SPI_RMS_Vsns_PH3)(15 downto 0));
    
    limits_pr: process(clk)
    begin
        if rising_edge(clk) then
            if sync_rst then
                stat_28vdc_good <= '0';
                stat_115vac_good <= '0';
            else
                stat_28vdc_good <= '1';
                if v28_in > LIMIT_32 or v28_in < LIMIT_18 then
                    stat_28vdc_good <= '0';
                end if;
    
                stat_115vac_good <= '1';
                if ((vph1 > LIMIT_125) or (vph1 < LIMIT_95)) or ((vph2 > LIMIT_125) or (vph2 < LIMIT_95)) or ((vph3 > LIMIT_125) or (vph3 < LIMIT_95)) then
                    stat_115vac_good <= '0';
                end if;
               
            end if;
        end if;
    end process;
    
    
    gen_led_pr: process(clk)
        variable cnt : integer range 0 to 100_000_000;
        CONSTANT CNT_HALF_1Hz : integer := 50_000_000;-- how many 100MHz ticks in half a second
        CONSTANT CNT_HALF_4Hz : integer := 12_500_000;-- how many 100MHz ticks in 1/8th of a second
        variable state : lamp_status_t;    
    begin
        if rising_edge(clk) then
            if sync_rst then
                lamp_out <= '0';
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
                    lamp_out <= '0';
                    cnt := 0;
                    lamp_state <= LAMP_STATE_LOW;
                when lamp_on =>
                    lamp_out <= '1';
                    cnt := 0;
                    lamp_state <= LAMP_STATE_HIGH;
                when lamp1Hz =>
                    cnt := cnt + 1;
                    if cnt >= CNT_HALF_1Hz then
                        lamp_out <= not lamp_out;
                        cnt := 0;
                    end if;
                    lamp_state <= LAMP_STATE_1K;
                when lamp4Hz =>
                    cnt := cnt + 1;
                    if cnt >= CNT_HALF_4Hz then
                        lamp_out <= not lamp_out;
                        cnt := 0;
                    end if;
                    lamp_state <= LAMP_STATE_4K;
                end case;
                
            end if;
        end if;
    end process;
    
end architecture RTL;
