library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use ieee.numeric_bit.all;

--library UNISIM;
--use UNISIM.VComponents.all;
use work.condor_pl_pkg.all;
use work.sim_pkg.all;
use work.regs_pkg.all;

entity condor_pl_uzed is
    generic(
        SYNTHESIS_TIME       : std_logic_vector(31 downto 0) := X"DEADBEEF";
        SIM_INPUT_FILE_NAME  : string                        := "no_file";
        SIM_OUTPUT_FILE_NAME : string                        := "no_file"
    );
    Port ( 
        DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
        DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
        DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
        DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
        DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
        DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
        DDR_cas_n : inout STD_LOGIC;
        DDR_ck_n : inout STD_LOGIC;
        DDR_ck_p : inout STD_LOGIC;
        DDR_cke : inout STD_LOGIC;
        DDR_cs_n : inout STD_LOGIC;
        DDR_odt : inout STD_LOGIC;
        DDR_ras_n : inout STD_LOGIC;
        DDR_reset_n : inout STD_LOGIC;
        DDR_we_n : inout STD_LOGIC;
        FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
        FIXED_IO_ddr_vrn : inout STD_LOGIC;
        FIXED_IO_ddr_vrp : inout STD_LOGIC;
        FIXED_IO_ps_clk : inout STD_LOGIC;
        FIXED_IO_ps_porb : inout STD_LOGIC;
        FIXED_IO_ps_srstb : inout STD_LOGIC
    );

end condor_pl_uzed;

architecture RTL of condor_pl_uzed is
    signal I_SNS_ADC_CS_FPGA : std_logic;
    signal I_SNS_ADC_SDI_FPGA : std_logic;
    signal I_SNS_ADC_SCLK_FPGA : std_logic;
    signal I_SNS_ADC_SDO_FPGA : std_logic;
    signal ZCR_SNS_ADC_SCLK_FPGA : std_logic;
    signal ZCR_SNS_ADC_CS_FPGA : std_logic;
    signal ZCR_SNS_ADC_SDO_FPGA : std_logic;
    signal ZCR_SNS_ADC_SDI_FPGA : std_logic;
    signal POWERON_FPGA : std_logic;
    signal FAN_PG1_FPGA : std_logic;
    signal FAN_HALL1_FPGA : std_logic;
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
    signal HV_ADC_SDI_FPGA : std_logic;
    signal HV_ADC_SCLK_FPGA : std_logic;
    signal HV_ADC_CS_FPGA : std_logic;
    signal HV_ADC_SDO_FPGA : std_logic;
    signal RELAY_1PH_FPGA : std_logic;
    signal RELAY_3PH_FPGA : std_logic;
    signal FAN_PG3_FPGA : std_logic;
    signal FAN_HALL3_FPGA : std_logic;
    signal FAN_EN3_FPGA : std_logic;
    signal FAN_CTRL3_FPGA : std_logic;
    signal FAN_PG2_FPGA : std_logic;
    signal FAN_HALL2_FPGA : std_logic;
    signal FAN_EN2_FPGA : std_logic;
    signal FAN_CTRL2_FPGA : std_logic;
    signal UART_RXD_PL : std_logic;
    signal UART_TXD_PL : std_logic;
    signal RS485_RXD_1 : std_logic;
    signal RS485_DE_7 : std_logic;
    signal RS485_TXD_7 : std_logic;
    signal RS485_TXD_8 : std_logic;
    signal RS485_RXD_8 : std_logic;
    signal RS485_RXD_9 : std_logic;
    signal RS485_DE_8 : std_logic;
    signal RS485_DE_9 : std_logic;
    signal RS485_TXD_9 : std_logic;
    signal EN_PFC_FB : std_logic;
    signal PG_BUCK_FB : std_logic;
    signal EN_PSU_1_FB : std_logic;
    signal PG_PSU_1_FB : std_logic;
    signal EN_PSU_2_FB : std_logic;
    signal PG_PSU_2_FB : std_logic;
    signal EN_PSU_5_FB : std_logic;
    signal PG_PSU_5_FB : std_logic;
    signal RS485_DE_1 : std_logic;
    signal RS485_TXD_1 : std_logic;
    signal EN_PSU_6_FB : std_logic;
    signal PG_PSU_6_FB : std_logic;
    signal EN_PSU_7_FB : std_logic;
    signal PG_PSU_7_FB : std_logic;
    signal EN_PSU_8_FB : std_logic;
    signal PG_PSU_8_FB : std_logic;
    signal EN_PSU_9_FB : std_logic;
    signal PG_PSU_9_FB : std_logic;
    signal EN_PSU_10_FB : std_logic;
    signal PG_PSU_10_FB : std_logic;
    signal RS485_TXD_2 : std_logic;
    signal RS485_RXD_2 : std_logic;
    signal RS485_RXD_3 : std_logic;
    signal RS485_DE_2 : std_logic;
    signal RS485_DE_3 : std_logic;
    signal RS485_TXD_3 : std_logic;
    signal RS485_TXD_4 : std_logic;
    signal RS485_RXD_4 : std_logic;
    signal RS485_RXD_5 : std_logic;
    signal RS485_DE_4 : std_logic;
    signal RS485_DE_5 : std_logic;
    signal RS485_TXD_5 : std_logic;
    signal RS485_TXD_6 : std_logic;
    signal RS485_RXD_6 : std_logic;
    signal RS485_RXD_7 : std_logic;
    signal RS485_DE_6 : std_logic;
    signal lamp_status_fpga : std_logic;
    signal PH_A_ON_fpga : std_logic;
    signal PH_B_ON_fpga : std_logic;
    signal PH_C_ON_fpga : std_logic;
    
    COMPONENT ila_0
    PORT (
        clk : IN STD_LOGIC;
        probe0 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe1 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe2 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe3 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe4 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe5 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe6 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe7 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe8 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe9 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe10 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe11 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe12 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe13 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe14 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe15 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe16 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe17 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe18 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe19 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe20 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe21 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe22 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe23 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe24 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe25 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe26 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe27 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe28 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe29 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe30 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe31 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe32 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe33 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe34 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe35 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe36 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe37 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe38 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe39 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe40 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe41 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe42 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe43 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe44 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe45 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe46 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe47 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe48 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe49 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe50 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe51 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe52 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe53 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe54 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe55 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe56 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe57 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe58 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe59 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe60 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe61 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe62 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe63 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe64 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe65 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe66 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe67 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe68 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe69 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe70 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe71 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe72 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe73 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe74 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe75 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe76 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe77 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe78 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe79 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe80 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe81 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe82 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe83 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe84 : IN STD_LOGIC_VECTOR(0 DOWNTO 0)
    );
    END COMPONENT  ;
    
    COMPONENT vio_0
      PORT (
        clk : IN STD_LOGIC;
        probe_out0 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_out1 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_out2 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_out3 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_out4 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_out5 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_out6 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_out7 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_out8 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_out9 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_out10 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_out11 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_out12 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_out13 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_out14 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_out15 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_out16 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_out17 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_out18 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_out19 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_out20 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_out21 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_out22 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_out23 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_out24 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_out25 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_out26 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_out27 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_out28 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_out29 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_out30 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_out31 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_out32 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0) 
      );
    END COMPONENT;
    
    signal clk : std_logic;
begin

    clk <= <<signal  uut.ps_clk100: std_logic >>;
    
    uut: entity work.condor_pl
    generic map(
        SYNTHESIS_TIME       => SYNTHESIS_TIME,
        SIM_INPUT_FILE_NAME  => SIM_INPUT_FILE_NAME,
        SIM_OUTPUT_FILE_NAME => SIM_OUTPUT_FILE_NAME
    )
    port map(
        DDR_addr              => DDR_addr,
        DDR_dqs_p             => DDR_dqs_p,
        DDR_dq                => DDR_dq,
        DDR_ba                => DDR_ba,
        DDR_dm                => DDR_dm,
        DDR_dqs_n             => DDR_dqs_n,
        DDR_cas_n             => DDR_cas_n,
        DDR_ck_n              => DDR_ck_n,
        DDR_ck_p              => DDR_ck_p,
        DDR_cke               => DDR_cke,
        DDR_cs_n              => DDR_cs_n,
        DDR_odt               => DDR_odt,
        DDR_ras_n             => DDR_ras_n,
        DDR_reset_n           => DDR_reset_n,
        DDR_we_n              => DDR_we_n,
        FIXED_IO_mio          => FIXED_IO_mio,
        FIXED_IO_ddr_vrn      => FIXED_IO_ddr_vrn,
        FIXED_IO_ddr_vrp      => FIXED_IO_ddr_vrp,
        FIXED_IO_ps_clk       => FIXED_IO_ps_clk,
        FIXED_IO_ps_porb      => FIXED_IO_ps_porb,
        FIXED_IO_ps_srstb     => FIXED_IO_ps_srstb,
        I_SNS_ADC_CS_FPGA     => I_SNS_ADC_CS_FPGA,
        I_SNS_ADC_SDI_FPGA    => I_SNS_ADC_SDI_FPGA,
        I_SNS_ADC_SCLK_FPGA   => I_SNS_ADC_SCLK_FPGA,
        I_SNS_ADC_SDO_FPGA    => I_SNS_ADC_SDO_FPGA,
        ZCR_SNS_ADC_SCLK_FPGA => ZCR_SNS_ADC_SCLK_FPGA,
        ZCR_SNS_ADC_CS_FPGA   => ZCR_SNS_ADC_CS_FPGA,
        ZCR_SNS_ADC_SDO_FPGA  => ZCR_SNS_ADC_SDO_FPGA,
        ZCR_SNS_ADC_SDI_FPGA  => ZCR_SNS_ADC_SDI_FPGA,
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
        HV_ADC_SDI_FPGA       => HV_ADC_SDI_FPGA,
        HV_ADC_SCLK_FPGA      => HV_ADC_SCLK_FPGA,
        HV_ADC_CS_FPGA        => HV_ADC_CS_FPGA,
        HV_ADC_SDO_FPGA       => HV_ADC_SDO_FPGA,
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
        UART_RXD_PL           => UART_RXD_PL,
        UART_TXD_PL           => UART_TXD_PL,
        RS485_RXD_1           => RS485_RXD_1,
        RS485_DE_7            => RS485_DE_7,
        RS485_TXD_7           => RS485_TXD_7,
        RS485_TXD_8           => RS485_TXD_8,
        RS485_RXD_8           => RS485_RXD_8,
        RS485_RXD_9           => RS485_RXD_9,
        RS485_DE_8            => RS485_DE_8,
        RS485_DE_9            => RS485_DE_9,
        RS485_TXD_9           => RS485_TXD_9,
        EN_PFC_FB             => EN_PFC_FB,
        PG_BUCK_FB            => PG_BUCK_FB,
        EN_PSU_1_FB           => EN_PSU_1_FB,
        PG_PSU_1_FB           => PG_PSU_1_FB,
        EN_PSU_2_FB           => EN_PSU_2_FB,
        PG_PSU_2_FB           => PG_PSU_2_FB,
        EN_PSU_5_FB           => EN_PSU_5_FB,
        PG_PSU_5_FB           => PG_PSU_5_FB,
        RS485_DE_1            => RS485_DE_1,
        RS485_TXD_1           => RS485_TXD_1,
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
        RS485_TXD_2           => RS485_TXD_2,
        RS485_RXD_2           => RS485_RXD_2,
        RS485_RXD_3           => RS485_RXD_3,
        RS485_DE_2            => RS485_DE_2,
        RS485_DE_3            => RS485_DE_3,
        RS485_TXD_3           => RS485_TXD_3,
        RS485_TXD_4           => RS485_TXD_4,
        RS485_RXD_4           => RS485_RXD_4,
        RS485_RXD_5           => RS485_RXD_5,
        RS485_DE_4            => RS485_DE_4,
        RS485_DE_5            => RS485_DE_5,
        RS485_TXD_5           => RS485_TXD_5,
        RS485_TXD_6           => RS485_TXD_6,
        RS485_RXD_6           => RS485_RXD_6,
        RS485_RXD_7           => RS485_RXD_7,
        RS485_DE_6            => RS485_DE_6,
        lamp_status_fpga      => lamp_status_fpga,
        PH_A_ON_fpga          => PH_A_ON_fpga,
        PH_B_ON_fpga          => PH_B_ON_fpga,
        PH_C_ON_fpga          => PH_C_ON_fpga
    );

    ila_i: ila_0
    port map(
        clk     => clk,
        probe0(0)  => POWERON_FPGA         ,
        probe1(0)  => FAN_PG1_FPGA         ,
        probe2(0)  => FAN_HALL1_FPGA       ,
        probe3(0)  => FAN_PG3_FPGA         ,
        probe4(0)  => FAN_HALL3_FPGA       ,
        probe5(0)  => FAN_PG2_FPGA         ,
        probe6(0)  => FAN_HALL2_FPGA       ,
        probe7(0)  => PG_BUCK_FB           ,
        probe8(0)  => PG_PSU_1_FB          ,
        probe9(0)  => PG_PSU_2_FB          ,
        probe10(0) => PG_PSU_5_FB          ,
        probe11(0) => PG_PSU_6_FB          ,
        probe12(0) => PG_PSU_7_FB          ,
        probe13(0) => PG_PSU_8_FB          ,
        probe14(0) => PG_PSU_9_FB          ,
        probe15(0) => PG_PSU_10_FB         ,
        probe16(0) => lamp_status_fpga     ,
        probe17(0) => PH_A_ON_fpga         ,
        probe18(0) => PH_B_ON_fpga         ,
        probe19(0) => PH_C_ON_fpga         ,
        probe20(0) => FAN_EN1_FPGA         ,
        probe21(0) => FAN_CTRL1_FPGA       ,
        probe22(0) => P_IN_STATUS_FPGA     ,
        probe23(0) => POD_STATUS_FPGA      ,
        probe24(0) => ECTCU_INH_FPGA       ,
        probe25(0) => P_OUT_STATUS_FPGA    ,
        probe26(0) => CCTCU_INH_FPGA       ,
        probe27(0) => SHUTDOWN_OUT_FPGA    ,
        probe28(0) => RESET_OUT_FPGA       ,
        probe29(0) => SPARE_OUT_FPGA       ,
        probe30(0) => ESHUTDOWN_OUT_FPGA   ,
        probe31(0) => RELAY_1PH_FPGA       ,
        probe32(0) => RELAY_3PH_FPGA       ,
        probe33(0) => FAN_EN3_FPGA         ,
        probe34(0) => FAN_CTRL3_FPGA       ,
        probe35(0) => FAN_EN2_FPGA         ,
        probe36(0) => FAN_CTRL2_FPGA       ,
        probe37(0) => EN_PFC_FB            ,
        probe38(0) => EN_PSU_1_FB          ,
        probe39(0) => EN_PSU_2_FB          ,
        probe40(0) => EN_PSU_5_FB          ,
        probe41(0) => EN_PSU_6_FB          ,
        probe42(0) => EN_PSU_7_FB          ,
        probe43(0) => EN_PSU_8_FB          ,
        probe44(0) => EN_PSU_9_FB          ,
        probe45(0) => EN_PSU_10_FB         ,
        probe46(0) => RS485_DE_7           ,
        probe47(0) => RS485_DE_8           ,
        probe48(0) => RS485_DE_9           ,
        probe49(0) => RS485_DE_1           ,
        probe50(0) => RS485_DE_2           ,
        probe51(0) => RS485_DE_3           ,
        probe52(0) => RS485_DE_4           ,
        probe53(0) => RS485_DE_5           ,
        probe54(0) => RS485_DE_6           ,
        probe55(0) => RS485_RXD_1          ,
        probe56(0) => RS485_TXD_1          ,
        probe57(0) => RS485_RXD_2          ,
        probe58(0) => RS485_TXD_2          ,
        probe59(0) => RS485_RXD_3          ,
        probe60(0) => RS485_TXD_3          ,
        probe61(0) => RS485_RXD_4          ,
        probe62(0) => RS485_TXD_4          ,
        probe63(0) => RS485_RXD_5          ,
        probe64(0) => RS485_TXD_5          ,
        probe65(0) => RS485_RXD_6          ,
        probe66(0) => RS485_TXD_6          ,
        probe67(0) => RS485_RXD_7          ,
        probe68(0) => RS485_TXD_7          ,
        probe69(0) => RS485_RXD_8          ,
        probe70(0) => RS485_TXD_8          ,
        probe71(0) => RS485_RXD_9          ,
        probe72(0) => RS485_TXD_9          ,
        probe73(0) => I_SNS_ADC_SCLK_FPGA  ,
        probe74(0) => I_SNS_ADC_CS_FPGA    ,
        probe75(0) => I_SNS_ADC_SDO_FPGA   ,
        probe76(0) => I_SNS_ADC_SDI_FPGA   ,
        probe77(0) => ZCR_SNS_ADC_SDO_FPGA ,
        probe78(0) => ZCR_SNS_ADC_SDI_FPGA ,
        probe79(0) => ZCR_SNS_ADC_SCLK_FPGA,
        probe80(0) => ZCR_SNS_ADC_CS_FPGA  ,
        probe81(0) => HV_ADC_SDO_FPGA      ,
        probe82(0) => HV_ADC_SDI_FPGA      ,
        probe83(0) => HV_ADC_SCLK_FPGA     ,
        probe84(0) => HV_ADC_CS_FPGA   
    );
    
    vio_i: vio_0
    port map(
        clk         => clk,
        probe_out0(0)  => POWERON_FPGA        ,
        probe_out1(0)  => FAN_PG1_FPGA        ,
        probe_out2(0)  => FAN_HALL1_FPGA      ,
        probe_out3(0)  => FAN_PG3_FPGA        ,
        probe_out4(0)  => FAN_HALL3_FPGA      ,
        probe_out5(0)  => FAN_PG2_FPGA        ,
        probe_out6(0)  => FAN_HALL2_FPGA      ,
        probe_out7(0)  => PG_BUCK_FB          ,
        probe_out8(0)  => PG_PSU_1_FB         ,
        probe_out9(0)  => PG_PSU_2_FB         ,
        probe_out10(0) => PG_PSU_5_FB         ,
        probe_out11(0) => PG_PSU_6_FB         ,
        probe_out12(0) => PG_PSU_7_FB         ,
        probe_out13(0) => PG_PSU_8_FB         ,
        probe_out14(0) => PG_PSU_9_FB         ,
        probe_out15(0) => PG_PSU_10_FB        ,
        probe_out16(0) => lamp_status_fpga    ,
        probe_out17(0) => PH_A_ON_fpga        ,
        probe_out18(0) => PH_B_ON_fpga        ,
        probe_out19(0) => PH_C_ON_fpga        ,
        probe_out20(0) => RS485_RXD_1         ,
        probe_out21(0) => RS485_RXD_2         ,
        probe_out22(0) => RS485_RXD_3         ,
        probe_out23(0) => RS485_RXD_4         ,
        probe_out24(0) => RS485_RXD_5         ,
        probe_out25(0) => RS485_RXD_6         ,
        probe_out26(0) => RS485_RXD_7         ,
        probe_out27(0) => RS485_RXD_8         ,
        probe_out28(0) => RS485_RXD_9         ,
        probe_out29(0) => open         ,
        probe_out30(0) => I_SNS_ADC_SDO_FPGA  ,
        probe_out31(0) => ZCR_SNS_ADC_SDO_FPGA,
        probe_out32(0) => HV_ADC_SDO_FPGA
    );
    

end architecture RTL;
