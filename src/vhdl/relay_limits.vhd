library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.condor_pl_pkg.all;
use work.sim_pkg.all;
use work.regs_pkg.all;

entity relay_limits is
    port(
        clk                : in  std_logic;
        sync_rst           : in  std_logic;
        registers          : in  reg_array_t;
        --regs_updating    : in  reg_slv_array_t;
        --regs_reading     : in  reg_slv_array_t;
        --internal_regs    : out reg_array_t;
        --internal_regs_we : out reg_slv_array_t;
        relays_ok          : out std_logic;
        relay1_ok          : out std_logic;
        relay2_ok          : out std_logic;
        relay3_ok          : out std_logic
    );
end entity relay_limits;

architecture RTL of relay_limits is
    constant RELAY_TH : integer := 200; -- resulution is 100mv and thershold is 20 V => 20 [V]/0.1[V/UNIT] = 200 [UNITS]
    signal v1, v2, v3, v1_relay, v2_relay, v3_relay: unsigned(15 downto 0);
begin
    v1 <= unsigned(registers(SPI_RMS_Vsns_PH1)(15 downto 0));
    v2 <= unsigned(registers(SPI_RMS_Vsns_PH2)(15 downto 0));
    v3 <= unsigned(registers(SPI_RMS_Vsns_PH3)(15 downto 0));
    v1_relay <= unsigned(registers(SPI_RMS_Vsns_PH_A_RLY)(15 downto 0));
    v2_relay <= unsigned(registers(SPI_RMS_Vsns_PH_B_RLY)(15 downto 0));
    v3_relay <= unsigned(registers(SPI_RMS_Vsns_PH_C_RLY)(15 downto 0));

    process(clk)
        
    begin
        if rising_edge(clk) then
            if sync_rst then
                relays_ok <= '0';
                relay1_ok <= '0';
                relay2_ok <= '0';
                relay3_ok <= '0';
            else
                relay1_ok <= '1';
                relay2_ok <= '1';
                relay3_ok <= '1';
                relays_ok <= relay1_ok and relay2_ok and relay3_ok;
                
                if registers(GENERAL_CONTROL)(GENERAL_CONTROL_RELAY_CHECK) = '0' then -- for debug we can disable this check
                    relays_ok <= '1';
                end if;
                
                if ((v1 - v1_relay) > RELAY_TH) or ((v1_relay - v1) > RELAY_TH) then
                    relay1_ok <= '0';
                end if;
                if ((v2 - v2_relay) > RELAY_TH) or ((v2_relay - v2) > RELAY_TH) then
                    relay2_ok <= '0';
                end if;
                if ((v3 - v3_relay) > RELAY_TH) or ((v3_relay - v3) > RELAY_TH) then
                    relay3_ok <= '0';
                end if;
            end if;
        end if;
    end process;
    
end architecture RTL;
