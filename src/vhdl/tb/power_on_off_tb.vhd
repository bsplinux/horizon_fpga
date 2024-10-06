library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.condor_pl_pkg.all;
use work.sim_pkg.all;
use work.regs_pkg.all;

entity power_on_off_tb is
end entity power_on_off_tb;

architecture RTL of power_on_off_tb is
    signal clk : std_logic := '0';
    signal sync_rst : std_logic;
    signal registers : reg_array_t;
    signal power_2_ios : power_2_ios_t;
    signal clk1mili : std_logic := '0';
    signal free_running_1ms : std_logic;
    signal fans_en : std_logic;
    signal limits_stat : std_logic_vector(limits_range);
    signal general_stat : std_logic_vector(full_reg_range);
    
    signal stop_clock: boolean;
begin
    clk <= not clk after 5 ns when not stop_clock else '0';
    sync_rst <= '1', '0' after 300 ns;
    clk1mili <= not clk1mili after 500 us when not stop_clock else '0';

    process(clk)
        variable s : std_logic;
    begin
        if rising_edge(clk) then
            free_running_1ms <= '0';
            if clk1mili and not s then
                free_running_1ms <= '1';
            end if;
            s := clk1mili;
        end if;
        
    end process;
    
    uut: entity work.power_on_off
    port map(
        clk              => clk,
        sync_rst         => sync_rst,
        registers        => registers,
        power_2_ios      => power_2_ios,
        free_running_1ms => free_running_1ms,
        fans_en          => fans_en,
        limits_stat      => limits_stat,
        general_stat     => general_stat
    );
    

    process
    begin
        registers <= (others => X"00000000");        
        limits_stat <= (others => '0');

        registers(IO_IN)(IO_IN_POWERON_FPGA) <= '0';
        wait for 100 ms;
        registers(IO_IN)(IO_IN_POWERON_FPGA) <= '1';
        wait for 1 sec;
        registers(IO_IN)(IO_IN_POWERON_FPGA) <= '0';
        wait for 51 ms;
        registers(IO_IN)(IO_IN_POWERON_FPGA) <= '1';
        wait for 100 ms;
        registers(IO_IN)(IO_IN_POWERON_FPGA) <= '0';
        wait for 49 ms;
        registers(IO_IN)(IO_IN_POWERON_FPGA) <= '1';
        wait for 100 ms;
        registers(IO_IN)(IO_IN_POWERON_FPGA) <= '0';
        wait for 2000 ms;
        registers(IO_IN)(IO_IN_POWERON_FPGA) <= '1';
        wait for 1000 ms;
        --pg_off <= '0';
        wait for 1 ms;
        --pg_off <= '1';
        wait for 100 ms;
        registers(IO_IN)(IO_IN_POWERON_FPGA) <= '0';
        wait for 99 ms;
        registers(IO_IN)(IO_IN_POWERON_FPGA) <= '1';
        wait for 100 ms;
        registers(IO_IN)(IO_IN_POWERON_FPGA) <= '0';
        wait for 100 ms;
        registers(IO_IN)(IO_IN_POWERON_FPGA) <= '1';
        wait for 1000 ms;
        
        
        wait for 10 us;
        stop_clock <= true;
        wait;
    end process;
end architecture RTL;
