library ieee;
use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
use work.regs_pkg.all;

entity regs is
    generic (
        AXI_ADDR_SIZE           : integer := 10; 
        UART_ADDR_SIZE          : integer := 10; 
        SYNTHESIS_TIME          : std_logic_vector := X"00000000";
        SIM_INPUT_FILE_NAME     : string := "no_file";
        SIM_OUTPUT_FILE_NAME    : string := "no_file"
    );
    port(
        clk             : in  std_logic;
        sync_rst        : in  STD_LOGIC;
        -- AXI access
        AXI_we          : in  STD_LOGIC;
        AXI_a           : in  STD_LOGIC_VECTOR(AXI_ADDR_SIZE -1 downto 0);
        AXI_d           : in  STD_LOGIC_VECTOR(31 downto 0);
        d_to_AXI        : out STD_LOGIC_VECTOR(31 downto 0);

        -- AXI access
        UART_we         : in  STD_LOGIC;
        UART_a          : in  STD_LOGIC_VECTOR(UART_ADDR_SIZE -1 downto 0);
        UART_d          : in  STD_LOGIC_VECTOR(31 downto 0);
        d_to_UART       : out STD_LOGIC_VECTOR(31 downto 0);

        -- to all blocks
        registers       : out reg_array_t;
        regs_updating   : out reg_slv_array_t;
        regs_reading    : out reg_slv_array_t;
        -- internal write access
        internal_regs    : in  reg_array_t;
        internal_regs_we : in  reg_slv_array_t
    );
end entity regs;

architecture arch of regs is
    constant NUM_REG_SETS           : integer := 3;
    constant REGISTERS_INIT_NEW     : reg_array_t := update_synthesis_time(SYNTHESIS_TIME); 
    signal bank_regs_in             : reg_arrays_t(NUM_REG_SETS - 1 downto 0);
    signal regs_from_axi            : reg_array_t;
    signal regs_from_uart           : reg_array_t;
    signal bank_regs_we             : reg_slv_arrays_t(NUM_REG_SETS - 1 downto 0);
    signal registers_sig            : reg_array_t;
    signal regs_we_from_axi         : reg_slv_array_t;
    signal regs_we_from_uart        : reg_slv_array_t;
    constant REG_SET_WRITABLE     : reg_slv_arrays_t(NUM_REG_SETS - 1 downto 0) := (INTERNALY_WRITEABLE_REGS , CPU_WRITEABLE_REGS , CPU_WRITEABLE_REGS);
    signal uart_reading : reg_slv_array_t;
    signal axi_reading : reg_slv_array_t;
    signal sim_reading : reg_slv_array_t;

begin
    bank_regs_in  <= (internal_regs , regs_from_uart , regs_from_axi);
    bank_regs_we  <= ((internal_regs_we and INTERNALY_WRITEABLE_REGS) , (regs_we_from_uart and CPU_WRITEABLE_REGS) , (regs_we_from_axi and CPU_WRITEABLE_REGS));
    registers     <= registers_sig;
    
    axi_a_decode : entity work.adr_decode
    generic map(
        A_SIZE => AXI_ADDR_SIZE - 2,
        readable => READABLE_REGISTERS,
        writable => CPU_WRITEABLE_REGS
    )
    port map(
        d_val    => open,
        re       => open,
        a        => AXI_a(AXI_ADDR_SIZE - 1 downto 2),
        d_in     => AXI_d,
        d_out    => d_to_AXI,
        regs_in  => registers_sig,
        regs_out => regs_from_axi,
        regs_we  => regs_we_from_axi,
        we(0)       => AXI_we,
        we(3 downto 1) => (others => '0'),
        regs_we_be => open,
        reading  => axi_reading
    );

    uart_a_decode : entity work.adr_decode
    generic map(
        A_SIZE => UART_ADDR_SIZE - 2,
        readable => READABLE_REGISTERS,
        writable => CPU_WRITEABLE_REGS
    )
    port map(
        d_val    => open,
        re       => open,
        a        => UART_a(UART_ADDR_SIZE - 1 downto 2),
        d_in     => UART_d,
        d_out    => d_to_UART,
        regs_in  => registers_sig,
        regs_out => regs_from_uart,
        regs_we  => regs_we_from_uart,
        we(0)       => UART_we,
        we(3 downto 1) => (others => '0'),
        regs_we_be => open,
        reading  => uart_reading
    );
    regs_reading <= uart_reading or axi_reading or sim_reading;
    
    reg_bank : entity work.reg_bank_x
    generic map(
        NUM_REG_SETS        => NUM_REG_SETS,
        REGS_INIT           => REGISTERS_INIT_NEW,
        WRITABLE            => WRITEABLE_REGS,
        REG_SET_WRITABLE    => REG_SET_WRITABLE,
        SIM_IN_FILE_NAME    => SIM_INPUT_FILE_NAME,
        SIM_OUT_FILE_NAME   => SIM_OUTPUT_FILE_NAME
    )
    port map(
        clk => clk,
        async_rstn => open,
        sync_rst => sync_rst,
        regs_out => registers_sig,
        regs_in => bank_regs_in,
        regs_we => bank_regs_we,
        updating => regs_updating,
        sim_reading => sim_reading
    );
    
end architecture arch;




    