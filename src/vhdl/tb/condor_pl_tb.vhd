library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.condor_pl_pkg.all;
--use work.sim_pkg.all;
use work.regs_pkg.all;

entity condor_pl_tb is
    generic(
        SYNTHESIS_TIME : std_logic_vector(31 downto 0) := X"21032416";
        SIM_INPUT_FILE_NAME : string := "file name will be set by simulator top level generics";
        SIM_OUTPUT_FILE_NAME : string := "file name will be set by simulator top level generics";
        HLS_EN : boolean := false
    );
end entity condor_pl_tb;

architecture RTL of condor_pl_tb is
    
    signal POWERON_FPGA : std_logic := '0';
    signal FAN_PG1_FPGA : std_logic := '0';
    signal FAN_HALL1_FPGA : std_logic := '0';
    signal FAN_EN1_FPGA : std_logic;
    signal FAN_CTRL1_FPGA : std_logic;
    signal P_IN_STATUS_FPGA : std_logic;
    signal POD_STATUS_FPGA : std_logic;
    signal ECTCU_INH_FPGA : std_logic;
    signal P_OUT_STATUS_FPGA : std_logic;
    signal CCTCU_INH_FPGA : std_logic;
    signal SHUTDOWN_OUT_FPGA : std_logic;
    signal RESET_OUT_FPGA : std_logic;
    signal SPARE_OUT_FPGA : std_logic;
    signal ESHUTDOWN_OUT_FPGA : std_logic;
    signal RELAY_1PH_FPGA : std_logic;
    signal RELAY_3PH_FPGA : std_logic;
    signal FAN_PG3_FPGA : std_logic := '0';
    signal FAN_HALL3_FPGA : std_logic := '0';
    signal FAN_EN3_FPGA : std_logic;
    signal FAN_CTRL3_FPGA : std_logic;
    signal FAN_PG2_FPGA : std_logic := '0';
    signal FAN_HALL2_FPGA : std_logic := '0';
    signal FAN_EN2_FPGA : std_logic;
    signal FAN_CTRL2_FPGA : std_logic;
    signal EN_PFC_FB : std_logic;
    signal PG_BUCK_FB : std_logic := '0';
    signal EN_PSU_1_FB : std_logic;
    signal PG_PSU_1_FB : std_logic := '0';
    signal EN_PSU_2_FB : std_logic;
    signal PG_PSU_2_FB : std_logic := '0';
    signal EN_PSU_5_FB : std_logic;
    signal PG_PSU_5_FB : std_logic := '0';
    signal EN_PSU_6_FB : std_logic;
    signal PG_PSU_6_FB : std_logic := '0';
    signal EN_PSU_7_FB : std_logic;
    signal PG_PSU_7_FB : std_logic := '0';
    signal EN_PSU_8_FB : std_logic;
    signal PG_PSU_8_FB : std_logic := '0';
    signal EN_PSU_9_FB : std_logic;
    signal PG_PSU_9_FB : std_logic := '0';
    signal EN_PSU_10_FB : std_logic;
    signal PG_PSU_10_FB : std_logic := '0';
    signal lamp_status_fpga : std_logic := '0';
    signal PH_A_ON_fpga : std_logic := '0';
    signal PH_B_ON_fpga : std_logic := '0';
    signal PH_C_ON_fpga : std_logic := '0';
    
    signal pg_off : std_logic;
    signal VP_0 : std_logic;
    signal VN_0 : std_logic;
begin
    PG_BUCK_FB   <= EN_PFC_FB    after 10 ms;
    PG_PSU_1_FB  <= pg_off and EN_PSU_1_FB  ;--after 10 ms;
    PG_PSU_2_FB  <= EN_PSU_2_FB  after 11 ms;
    PG_PSU_5_FB  <= EN_PSU_5_FB  after 12 ms;
    PG_PSU_6_FB  <= EN_PSU_6_FB  after 13 ms;
    PG_PSU_7_FB  <= EN_PSU_7_FB  after 14 ms;
    PG_PSU_8_FB  <= EN_PSU_8_FB  after 15 ms;
    PG_PSU_9_FB  <= EN_PSU_9_FB  after 16 ms;
    PG_PSU_10_FB <= EN_PSU_10_FB after 17 ms;

    pwer_pr: process
    begin
        pg_off <= '1';
        FAN_HALL1_FPGA <= '0';-- for sumulation using it for out of range 
        
        POWERON_FPGA <= '0';
        wait for 100 ms;
        POWERON_FPGA <= '1';
        wait for 1 sec;
        POWERON_FPGA <= '0';
        wait for 51 ms;
        POWERON_FPGA <= '1';
        wait for 100 ms;
        POWERON_FPGA <= '0';
        wait for 49 ms;
        POWERON_FPGA <= '1';
        wait for 100 ms;
        POWERON_FPGA <= '0';
        wait for 2000 ms;
        POWERON_FPGA <= '1';
        wait for 1000 ms;
        pg_off <= '0';
        wait for 1 ms;
        pg_off <= '1';
        wait for 100 ms;
        POWERON_FPGA <= '0';
        wait for 99 ms;
        POWERON_FPGA <= '1';
        wait for 100 ms;
        POWERON_FPGA <= '0';
        wait for 100 ms;
        POWERON_FPGA <= '1';
        wait for 1000 ms;
        -- generate out of range
        FAN_HALL1_FPGA <= '1';-- for sumulation using it for out of range 
        wait for 100 ms;
        FAN_HALL1_FPGA <= '0';-- for sumulation using it for out of range 
        
        wait;
    end process;
    

    uut: entity work.condor_pl
    generic map(
        SYNTHESIS_TIME       => SYNTHESIS_TIME,
        SIM_INPUT_FILE_NAME  => SIM_INPUT_FILE_NAME,
        SIM_OUTPUT_FILE_NAME => SIM_OUTPUT_FILE_NAME,
        HLS_EN               => HLS_EN
    )
    port map(
        DDR_addr              => open,
        DDR_dqs_p             => open,
        DDR_dq                => open,
        DDR_ba                => open,
        DDR_dm                => open,
        DDR_dqs_n             => open,
        DDR_cas_n             => open,
        DDR_ck_n              => open,
        DDR_ck_p              => open,
        DDR_cke               => open,
        DDR_cs_n              => open,
        DDR_odt               => open,
        DDR_ras_n             => open,
        DDR_reset_n           => open,
        DDR_we_n              => open,
        FIXED_IO_mio          => open,
        FIXED_IO_ddr_vrn      => open,
        FIXED_IO_ddr_vrp      => open,
        FIXED_IO_ps_clk       => open,
        FIXED_IO_ps_porb      => open,
        FIXED_IO_ps_srstb     => open,
        I_SNS_ADC_CS_FPGA     => open,
        I_SNS_ADC_SDI_FPGA    => open,
        I_SNS_ADC_SCLK_FPGA   => open,
        I_SNS_ADC_SDO_FPGA    => '0',
        ZCR_SNS_ADC_SCLK_FPGA => open,
        ZCR_SNS_ADC_CS_FPGA   => open,
        ZCR_SNS_ADC_SDO_FPGA  => '0',
        ZCR_SNS_ADC_SDI_FPGA  => open,
        POWERON_FPGA          => POWERON_FPGA,
        FAN_PG1_FPGA          => FAN_PG1_FPGA,
        FAN_HALL1_FPGA        => FAN_HALL1_FPGA,
        FAN_EN1_FPGA          => FAN_EN1_FPGA,
        FAN_CTRL1_FPGA        => FAN_CTRL1_FPGA,
        P_IN_STATUS_FPGA      => P_IN_STATUS_FPGA,
        POD_STATUS_FPGA       => POD_STATUS_FPGA,
        ECTCU_INH_FPGA        => ECTCU_INH_FPGA,
        P_OUT_STATUS_FPGA     => P_OUT_STATUS_FPGA,
        CCTCU_INH_FPGA        => CCTCU_INH_FPGA,
        SHUTDOWN_OUT_FPGA     => SHUTDOWN_OUT_FPGA,
        RESET_OUT_FPGA        => RESET_OUT_FPGA,
        SPARE_OUT_FPGA        => SPARE_OUT_FPGA,
        ESHUTDOWN_OUT_FPGA    => ESHUTDOWN_OUT_FPGA,
        HV_ADC_SDI_FPGA       => open,
        HV_ADC_SCLK_FPGA      => open,
        HV_ADC_CS_FPGA        => open,
        HV_ADC_SDO_FPGA       => '0',
        RELAY_1PH_FPGA        => RELAY_1PH_FPGA,
        RELAY_3PH_FPGA        => RELAY_3PH_FPGA,
        FAN_PG3_FPGA          => FAN_PG3_FPGA,
        FAN_HALL3_FPGA        => FAN_HALL3_FPGA,
        FAN_EN3_FPGA          => FAN_EN3_FPGA,
        FAN_CTRL3_FPGA        => FAN_CTRL3_FPGA,
        FAN_PG2_FPGA          => FAN_PG2_FPGA,
        FAN_HALL2_FPGA        => FAN_HALL2_FPGA,
        FAN_EN2_FPGA          => FAN_EN2_FPGA,
        FAN_CTRL2_FPGA        => FAN_CTRL2_FPGA,
        UART_RXD_PL           => '0', 
        UART_TXD_PL           => open, 
        RS485_RXD_1           => '0',
        RS485_DE_7            => open,
        RS485_TXD_7           => open, 
        RS485_TXD_8           => open, 
        RS485_RXD_8           => '0',
        RS485_RXD_9           => '0',
        RS485_DE_8            => open, 
        RS485_DE_9            => open, 
        RS485_TXD_9           => open,
        EN_PFC_FB             => EN_PFC_FB,
        PG_BUCK_FB            => PG_BUCK_FB,
        EN_PSU_1_FB           => EN_PSU_1_FB,
        PG_PSU_1_FB           => PG_PSU_1_FB,
        EN_PSU_2_FB           => EN_PSU_2_FB,
        PG_PSU_2_FB           => PG_PSU_2_FB,
        EN_PSU_5_FB           => EN_PSU_5_FB,
        PG_PSU_5_FB           => PG_PSU_5_FB,
        RS485_DE_1            => open,
        RS485_TXD_1           => open,
        EN_PSU_6_FB           => EN_PSU_6_FB,
        PG_PSU_6_FB           => PG_PSU_6_FB,
        EN_PSU_7_FB           => EN_PSU_7_FB,
        PG_PSU_7_FB           => PG_PSU_7_FB,
        EN_PSU_8_FB           => EN_PSU_8_FB,
        PG_PSU_8_FB           => PG_PSU_8_FB,
        EN_PSU_9_FB           => EN_PSU_9_FB,
        PG_PSU_9_FB           => PG_PSU_9_FB,
        EN_PSU_10_FB          => EN_PSU_10_FB,
        PG_PSU_10_FB          => PG_PSU_10_FB,
        RS485_TXD_2           => open, 
        RS485_RXD_2           => '0', 
        RS485_RXD_3           => '0',
        RS485_DE_2            => open, 
        RS485_DE_3            => open, 
        RS485_TXD_3           => open, 
        RS485_TXD_4           => open,
        RS485_RXD_4           => '0',
        RS485_RXD_5           => '0',
        RS485_DE_4            => open, 
        RS485_DE_5            => open, 
        RS485_TXD_5           => open, 
        RS485_TXD_6           => open, 
        RS485_RXD_6           => '0',
        RS485_RXD_7           => '0',
        RS485_DE_6            => open,
        lamp_status_fpga      => lamp_status_fpga,
        PH_A_ON_fpga          => PH_A_ON_fpga,
        PH_B_ON_fpga          => PH_B_ON_fpga,
        PH_C_ON_fpga          => PH_C_ON_fpga,
        VP_0 => VP_0,
        VN_0 => VN_0
    );
    
end architecture RTL;
