library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.regs_pkg.all;

entity regs_tb is
    generic(
        SIM_INPUT_FILE_NAME     : string := "no_file";
        SIM_OUTPUT_FILE_NAME    : string := "no_file"
    );
end entity regs_tb;

architecture RTL of regs_tb is
    signal clk : std_logic := '0';
    signal sync_rst : STD_LOGIC;
    signal AXI_we : STD_LOGIC;
    signal AXI_a : STD_LOGIC_VECTOR(9 downto 0);
    signal AXI_d : STD_LOGIC_VECTOR(31 downto 0);
    signal d_to_AXI : STD_LOGIC_VECTOR(31 downto 0);
    signal UART_we : STD_LOGIC;
    signal UART_a : STD_LOGIC_VECTOR(9 downto 0);
    signal UART_d : STD_LOGIC_VECTOR(31 downto 0);
    signal d_to_UART : STD_LOGIC_VECTOR(31 downto 0);
    signal registers : reg_array_t;
    signal regs_updating : reg_slv_array_t;
    signal regs_reading : reg_slv_array_t;
    signal internal_regs : reg_array_t;
    signal internal_regs_we : reg_slv_array_t;
    
begin
    clk <= not clk after 5 ns;
    sync_rst <= '1', '0' after 300 ns;
    
    uut: entity work.regs
    generic map(
        --AXI_ADDR_SIZE        => AXI_ADDR_SIZE,
        --UART_ADDR_SIZE       => UART_ADDR_SIZE,
        SYNTHESIS_TIME       => X"01022416",
        SIM_INPUT_FILE_NAME  => SIM_INPUT_FILE_NAME,
        SIM_OUTPUT_FILE_NAME => SIM_OUTPUT_FILE_NAME
    )
    port map(
        clk              => clk,
        sync_rst         => sync_rst,
        AXI_we           => AXI_we,
        AXI_a            => AXI_a,
        AXI_d            => AXI_d,
        d_to_AXI         => d_to_AXI,
        UART_we          => UART_we,
        UART_a           => UART_a,
        UART_d           => UART_d,
        d_to_UART        => d_to_UART,
        registers        => registers,
        regs_updating    => regs_updating,
        regs_reading     => regs_reading,
        internal_regs    => internal_regs,
        internal_regs_we => internal_regs_we
    );
    
    AXI_we <= '0';
    AXI_a <= (others => '0');
    AXI_d <= (others => '0');
    UART_we <= '0';
    UART_a <= (others => '0');
    UART_d <= (others => '0');
    
    internal_regs <= (others => X"00000000");
    internal_regs_we <= (others => '0');
    
    
end architecture RTL;
