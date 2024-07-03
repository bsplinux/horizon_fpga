library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use ieee.numeric_bit.all;

--library UNISIM;
--use UNISIM.VComponents.all;
use work.condor_pl_pkg.all;
use work.sim_pkg.all;
use work.regs_pkg.all;

entity condor_pl is
    generic(
        SYNTHESIS_TIME       : std_logic_vector(31 downto 0) := X"DEADBEEF";
        SIM_INPUT_FILE_NAME  : string                        := "no_file";
        SIM_OUTPUT_FILE_NAME : string                        := "no_file";
        HLS_EN               : boolean                       := true
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
        FIXED_IO_ps_srstb : inout STD_LOGIC;
    	-- pl 
    	I_SNS_ADC_CS_FPGA    	: out std_logic;
    	I_SNS_ADC_SDI_FPGA   	: out std_logic;
    	I_SNS_ADC_SCLK_FPGA  	: out std_logic;
    	I_SNS_ADC_SDO_FPGA   	: in  std_logic;
    	ZCR_SNS_ADC_SCLK_FPGA	: out std_logic;
    	ZCR_SNS_ADC_CS_FPGA  	: out std_logic;
    	ZCR_SNS_ADC_SDO_FPGA 	: in  std_logic;
    	ZCR_SNS_ADC_SDI_FPGA 	: out std_logic;
    	POWERON_FPGA         	: in  std_logic;
    	FAN_PG1_FPGA         	: in  std_logic;
    	FAN_HALL1_FPGA       	: in  std_logic;
    	FAN_EN1_FPGA         	: out std_logic;
    	FAN_CTRL1_FPGA       	: out std_logic;
    	P_IN_STATUS_FPGA     	: out std_logic;
    	POD_STATUS_FPGA      	: out std_logic;
    	ECTCU_INH_FPGA       	: out std_logic;
    	P_OUT_STATUS_FPGA    	: out std_logic;
    	CCTCU_INH_FPGA       	: out std_logic;
    	SHUTDOWN_OUT_FPGA    	: out std_logic; 
    	RESET_OUT_FPGA       	: out std_logic;
    	SPARE_OUT_FPGA       	: out std_logic; 
    	ESHUTDOWN_OUT_FPGA   	: out std_logic;
    	HV_ADC_SDI_FPGA      	: out std_logic;
    	HV_ADC_SCLK_FPGA     	: out std_logic;
    	HV_ADC_CS_FPGA       	: out std_logic;
    	HV_ADC_SDO_FPGA      	: in  std_logic;
    	RELAY_1PH_FPGA       	: out std_logic;
    	RELAY_3PH_FPGA       	: out std_logic;
    	FAN_PG3_FPGA         	: in  std_logic;
    	FAN_HALL3_FPGA       	: in  std_logic;
    	FAN_EN3_FPGA         	: out std_logic;
    	FAN_CTRL3_FPGA       	: out std_logic;
    	FAN_PG2_FPGA         	: in  std_logic;
    	FAN_HALL2_FPGA       	: in  std_logic;
    	FAN_EN2_FPGA         	: out std_logic;
    	FAN_CTRL2_FPGA       	: out std_logic;
    	UART_RXD_PL	            : in  std_logic;
    	UART_TXD_PL	            : out std_logic;
    	RS485_RXD_1          	: in  std_logic;
    	RS485_DE_7           	: out std_logic;
    	RS485_TXD_7          	: out std_logic;
    	RS485_TXD_8          	: out std_logic;
    	RS485_RXD_8          	: in  std_logic;
    	RS485_RXD_9          	: in  std_logic;
    	RS485_DE_8           	: out std_logic;
    	RS485_DE_9           	: out std_logic;
    	RS485_TXD_9          	: out std_logic;
    	EN_PFC_FB            	: out std_logic;
    	PG_BUCK_FB           	: in  std_logic;
    	EN_PSU_1_FB          	: out std_logic;
    	PG_PSU_1_FB          	: in  std_logic;
    	EN_PSU_2_FB          	: out std_logic;
    	PG_PSU_2_FB          	: in  std_logic;
    	EN_PSU_5_FB          	: out std_logic;
    	PG_PSU_5_FB          	: in  std_logic;
    	RS485_DE_1           	: out std_logic;
    	RS485_TXD_1          	: out std_logic;
    	EN_PSU_6_FB          	: out std_logic;
    	PG_PSU_6_FB          	: in  std_logic;
    	EN_PSU_7_FB          	: out std_logic;
    	PG_PSU_7_FB          	: in  std_logic;
    	EN_PSU_8_FB          	: out std_logic;
    	PG_PSU_8_FB          	: in  std_logic;
    	EN_PSU_9_FB          	: out std_logic;
    	PG_PSU_9_FB          	: in  std_logic;
    	EN_PSU_10_FB         	: out std_logic;
    	PG_PSU_10_FB         	: in  std_logic;
    	RS485_TXD_2          	: out std_logic;
    	RS485_RXD_2          	: in  std_logic;
    	RS485_RXD_3          	: in  std_logic;
    	RS485_DE_2           	: out std_logic;
    	RS485_DE_3           	: out std_logic;
    	RS485_TXD_3          	: out std_logic;
    	RS485_TXD_4          	: out std_logic;
    	RS485_RXD_4          	: in  std_logic;
    	RS485_RXD_5          	: in  std_logic;
    	RS485_DE_4           	: out std_logic;
    	RS485_DE_5           	: out std_logic;
    	RS485_TXD_5          	: out std_logic;
    	RS485_TXD_6          	: out std_logic;
    	RS485_RXD_6          	: in  std_logic;
    	RS485_RXD_7          	: in  std_logic;
    	RS485_DE_6           	: out std_logic;
    	lamp_status_fpga	    : in  std_logic;
    	PH_A_ON_fpga	        : in  std_logic;
    	PH_B_ON_fpga	        : in  std_logic;
    	PH_C_ON_fpga	        : in  std_logic
    );

end condor_pl;

architecture Behavioral of condor_pl is 
  
    signal ps_clk100 : std_logic := '0';
    signal ps_clk100_rst : std_logic;
    signal ps_clk100_rstn : std_logic;
  
    signal REGS_BE  : STD_LOGIC_VECTOR(3 downto 0);
    signal REGS_D   : STD_LOGIC_VECTOR(31 downto 0);
    signal REGS_A   : STD_LOGIC_VECTOR(11 downto 0);
    signal REGS_Q   : STD_LOGIC_VECTOR(31 downto 0);
    signal REGS_WE  : std_logic;

    signal UART_we   : STD_LOGIC;
    signal UART_a    : STD_LOGIC_VECTOR(UART_A_SIZE - 1 downto 0);
    signal UART_d    : STD_LOGIC_VECTOR(31 downto 0);
    signal d_to_UART : STD_LOGIC_VECTOR(31 downto 0); -- @suppress only place holder for now

    signal registers        : reg_array_t;
    signal regs_updating    : reg_slv_array_t;
    signal regs_reading     : reg_slv_array_t;
    signal internal_regs    : reg_array_t;
    signal internal_regs_we : reg_slv_array_t;

    signal ios_2_app  : ios_2_app_t;
    signal app_2_ios  : app_2_ios_t;
    signal sw_reset   : std_logic;
    signal regs_reset : std_logic;
    signal ps_intr : std_logic_vector(PS_INTR_range);

    signal HLS_to_BD  : HLS_axim_to_interconnect_array_t(1 downto 0);
    signal BD_to_HLS  : HLS_axim_from_interconnect_array_t(1 downto 0);
begin
    bd_gen : if sim_on generate
        procedure tick(num_ticks : integer := 1) is
        begin
            if num_ticks > 0 then
                for i in 1 to num_ticks loop
                    wait until rising_edge(ps_clk100);
                    wait for 1 ns;
                end loop;
            end if;
        end procedure tick;
        
        --function reg_address(reg : integer) return std_logic_vector is
        --begin
        --    return std_logic_vector(to_unsigned(reg*4,12));
        --end reg_address;
            
    begin
        -- during simulation we skip the need AXI transactions by directly setting values of registers using text IO vhdl package from file
        ps_clk100      <= not ps_clk100 after 50000 ns; -- using 10 KHZ will give us 10 clocks for each mili sec
        --ps_clk100_rst <= '1', '0' after 333 ns;
        ps_clk100_rstn <= not ps_clk100_rst;
        --regs_a   <= (others => '0');
        --regs_be  <= (others => '0');
        --regs_d   <= (others => '0');
        --v_i: entity work.xpm_v_tb;-- this only fixes a bug in vivado
            
        process
        begin
            REGS_A   <= (others => '0');
            REGS_BE  <= (others => '0');
            REGS_D   <= (others => '0');
            ps_clk100_rst <= '1';
            tick(3);
            ps_clk100_rst <= '0';
            tick(10);
            wait;
        end process;            
        
    else generate
        component design_1 is
        port (
            REGS_A : out STD_LOGIC_VECTOR ( 11 downto 0 );
            REGS_BE : out STD_LOGIC_VECTOR ( 3 downto 0 );
            REGS_D : out STD_LOGIC_VECTOR ( 31 downto 0 );
            REGS_Q : in STD_LOGIC_VECTOR ( 31 downto 0 );
            DDR_cas_n : inout STD_LOGIC;
            DDR_cke : inout STD_LOGIC;
            DDR_ck_n : inout STD_LOGIC;
            DDR_ck_p : inout STD_LOGIC;
            DDR_cs_n : inout STD_LOGIC;
            DDR_reset_n : inout STD_LOGIC;
            DDR_odt : inout STD_LOGIC;
            DDR_ras_n : inout STD_LOGIC;
            DDR_we_n : inout STD_LOGIC;
            DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
            DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
            DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
            DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
            DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
            DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
            FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
            FIXED_IO_ddr_vrn : inout STD_LOGIC;
            FIXED_IO_ddr_vrp : inout STD_LOGIC;
            FIXED_IO_ps_srstb : inout STD_LOGIC;
            FIXED_IO_ps_clk : inout STD_LOGIC;
            FIXED_IO_ps_porb : inout STD_LOGIC;
            ps_clk100 : out STD_LOGIC;
            ps_clk100_rstn : out STD_LOGIC_VECTOR ( 0 to 0 );
            UARTS_AXI_araddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
            UARTS_AXI_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
            UARTS_AXI_arcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
            UARTS_AXI_arlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
            UARTS_AXI_arlock : in STD_LOGIC_VECTOR ( 0 to 0 );
            UARTS_AXI_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
            UARTS_AXI_arqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
            UARTS_AXI_arready : out STD_LOGIC;
            UARTS_AXI_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
            UARTS_AXI_arvalid : in STD_LOGIC;
            UARTS_AXI_awaddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
            UARTS_AXI_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
            UARTS_AXI_awcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
            UARTS_AXI_awlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
            UARTS_AXI_awlock : in STD_LOGIC_VECTOR ( 0 to 0 );
            UARTS_AXI_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
            UARTS_AXI_awqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
            UARTS_AXI_awready : out STD_LOGIC;
            UARTS_AXI_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
            UARTS_AXI_awvalid : in STD_LOGIC;
            UARTS_AXI_bready : in STD_LOGIC;
            UARTS_AXI_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
            UARTS_AXI_bvalid : out STD_LOGIC;
            UARTS_AXI_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
            UARTS_AXI_rlast : out STD_LOGIC;
            UARTS_AXI_rready : in STD_LOGIC;
            UARTS_AXI_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
            UARTS_AXI_rvalid : out STD_LOGIC;
            UARTS_AXI_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
            UARTS_AXI_wlast : in STD_LOGIC;
            UARTS_AXI_wready : out STD_LOGIC;
            UARTS_AXI_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
            UARTS_AXI_wvalid : in STD_LOGIC;
            SPIS_AXI_araddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
            SPIS_AXI_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
            SPIS_AXI_arcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
            SPIS_AXI_arlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
            SPIS_AXI_arlock : in STD_LOGIC_VECTOR ( 0 to 0 );
            SPIS_AXI_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
            SPIS_AXI_arqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
            SPIS_AXI_arready : out STD_LOGIC;
            SPIS_AXI_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
            SPIS_AXI_arvalid : in STD_LOGIC;
            SPIS_AXI_awaddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
            SPIS_AXI_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
            SPIS_AXI_awcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
            SPIS_AXI_awlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
            SPIS_AXI_awlock : in STD_LOGIC_VECTOR ( 0 to 0 );
            SPIS_AXI_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
            SPIS_AXI_awqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
            SPIS_AXI_awready : out STD_LOGIC;
            SPIS_AXI_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
            SPIS_AXI_awvalid : in STD_LOGIC;
            SPIS_AXI_bready : in STD_LOGIC;
            SPIS_AXI_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
            SPIS_AXI_bvalid : out STD_LOGIC;
            SPIS_AXI_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
            SPIS_AXI_rlast : out STD_LOGIC;
            SPIS_AXI_rready : in STD_LOGIC;
            SPIS_AXI_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
            SPIS_AXI_rvalid : out STD_LOGIC;
            SPIS_AXI_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
            SPIS_AXI_wlast : in STD_LOGIC;
            SPIS_AXI_wready : out STD_LOGIC;
            SPIS_AXI_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
            SPIS_AXI_wvalid : in STD_LOGIC;
            UART_0_rxd : in STD_LOGIC;
            UART_0_txd : out STD_LOGIC;
            UART_1_rxd : in STD_LOGIC;
            UART_1_txd : out STD_LOGIC;
            UART_2_rxd : in STD_LOGIC;
            UART_2_txd : out STD_LOGIC;
            UART_3_rxd : in STD_LOGIC;
            UART_3_txd : out STD_LOGIC;
            UART_4_rxd : in STD_LOGIC;
            UART_4_txd : out STD_LOGIC;
            UART_5_rxd : in STD_LOGIC;
            UART_5_txd : out STD_LOGIC;
            UART_6_rxd : in STD_LOGIC;
            UART_6_txd : out STD_LOGIC;
            UART_7_rxd : in STD_LOGIC;
            UART_7_txd : out STD_LOGIC;
            UART_8_rxd : in STD_LOGIC;
            UART_8_txd : out STD_LOGIC;
            ps_clk100_rst : out STD_LOGIC_VECTOR ( 0 to 0 );
            spio0_sck : out STD_LOGIC;
            spi0_cs : out STD_LOGIC_VECTOR ( 0 to 0 );
            spi0_miso : in STD_LOGIC;
            spi0_mosi : out STD_LOGIC;
            spi2_miso : in STD_LOGIC;
            spi2_mosi : out STD_LOGIC;
            spi2_sck : out STD_LOGIC;
            spi2_cs : out STD_LOGIC_VECTOR ( 0 to 0 );
            spi1_miso : in STD_LOGIC;
            spi1_mosi : out STD_LOGIC;
            spi1_sck : out STD_LOGIC;
            spi1_cs : out STD_LOGIC_VECTOR ( 0 to 0 );
            ps_intr : in std_logic_vector(PS_INTR_range)
        );
        end component design_1;
    begin
        design_1_i: component design_1
        port map (
          DDR_addr(14 downto 0) => DDR_addr(14 downto 0),
          DDR_ba(2 downto 0) => DDR_ba(2 downto 0),
          DDR_cas_n => DDR_cas_n,
          DDR_ck_n => DDR_ck_n,
          DDR_ck_p => DDR_ck_p,
          DDR_cke => DDR_cke,
          DDR_cs_n => DDR_cs_n,
          DDR_dm(3 downto 0) => DDR_dm(3 downto 0),
          DDR_dq(31 downto 0) => DDR_dq(31 downto 0),
          DDR_dqs_n(3 downto 0) => DDR_dqs_n(3 downto 0),
          DDR_dqs_p(3 downto 0) => DDR_dqs_p(3 downto 0),
          DDR_odt => DDR_odt,
          DDR_ras_n => DDR_ras_n,
          DDR_reset_n => DDR_reset_n,
          DDR_we_n => DDR_we_n,
          FIXED_IO_ddr_vrn => FIXED_IO_ddr_vrn,
          FIXED_IO_ddr_vrp => FIXED_IO_ddr_vrp,
          FIXED_IO_mio(53 downto 0) => FIXED_IO_mio(53 downto 0),
          FIXED_IO_ps_clk => FIXED_IO_ps_clk,
          FIXED_IO_ps_porb => FIXED_IO_ps_porb,
          FIXED_IO_ps_srstb => FIXED_IO_ps_srstb,
          UARTS_AXI_araddr  => HLS_to_BD(0).araddr ,                                   --: in STD_LOGIC_VECTOR ( 31 downto 0 );
          UARTS_AXI_arburst => HLS_to_BD(0).arburst,                                   --: in STD_LOGIC_VECTOR ( 1 downto 0 );
          UARTS_AXI_arcache => HLS_to_BD(0).arcache,                                   --: in STD_LOGIC_VECTOR ( 3 downto 0 );
          UARTS_AXI_arlen   => HLS_to_BD(0).arlen  ,                                   --: in STD_LOGIC_VECTOR ( 7 downto 0 );
          UARTS_AXI_arlock(0)  => HLS_to_BD(0).arlock(0) ,                                   --: in STD_LOGIC_VECTOR ( 0 to 0 );
          UARTS_AXI_arprot  => HLS_to_BD(0).arprot ,                                   --: in STD_LOGIC_VECTOR ( 2 downto 0 );
          UARTS_AXI_arqos   => HLS_to_BD(0).arqos  ,                                   --: in STD_LOGIC_VECTOR ( 3 downto 0 );
          UARTS_AXI_arready => BD_to_HLS(0).arready,                                   --: out STD_LOGIC;
          UARTS_AXI_arsize  => HLS_to_BD(0).arsize ,                                   --: in STD_LOGIC_VECTOR ( 2 downto 0 );
          UARTS_AXI_arvalid => HLS_to_BD(0).arvalid,                                   --: in STD_LOGIC;
          UARTS_AXI_awaddr  => HLS_to_BD(0).awaddr ,                                   --: in STD_LOGIC_VECTOR ( 31 downto 0 );
          UARTS_AXI_awburst => HLS_to_BD(0).awburst,                                   --: in STD_LOGIC_VECTOR ( 1 downto 0 );
          UARTS_AXI_awcache => HLS_to_BD(0).awcache,                                   --: in STD_LOGIC_VECTOR ( 3 downto 0 );
          UARTS_AXI_awlen   => HLS_to_BD(0).awlen  ,                                   --: in STD_LOGIC_VECTOR ( 7 downto 0 );
          UARTS_AXI_awlock(0)  => HLS_to_BD(0).awlock(0) ,                                   --: in STD_LOGIC_VECTOR ( 0 to 0 );
          UARTS_AXI_awprot  => HLS_to_BD(0).awprot ,                                   --: in STD_LOGIC_VECTOR ( 2 downto 0 );
          UARTS_AXI_awqos   => HLS_to_BD(0).awqos  ,                                   --: in STD_LOGIC_VECTOR ( 3 downto 0 );
          UARTS_AXI_awready => BD_to_HLS(0).awready,                                   --: out STD_LOGIC;
          UARTS_AXI_awsize  => HLS_to_BD(0).awsize ,                                   --: in STD_LOGIC_VECTOR ( 2 downto 0 );
          UARTS_AXI_awvalid => HLS_to_BD(0).awvalid,                                   --: in STD_LOGIC;
          UARTS_AXI_bready  => HLS_to_BD(0).bready ,                                   --: in STD_LOGIC;
          UARTS_AXI_bresp   => BD_to_HLS(0).bresp  ,                                  --: out STD_LOGIC_VECTOR ( 1 downto 0 );
          UARTS_AXI_bvalid  => BD_to_HLS(0).bvalid ,                                  --: out STD_LOGIC;
          UARTS_AXI_rdata   => BD_to_HLS(0).rdata  ,                                  --: out STD_LOGIC_VECTOR ( 31 downto 0 );
          UARTS_AXI_rlast   => BD_to_HLS(0).rlast  ,                                  --: out STD_LOGIC;
          UARTS_AXI_rready  => HLS_to_BD(0).rready ,                                   --: in STD_LOGIC;
          UARTS_AXI_rresp   => BD_to_HLS(0).rresp  ,                                   --: out STD_LOGIC_VECTOR ( 1 downto 0 );
          UARTS_AXI_rvalid  => BD_to_HLS(0).rvalid ,                                   --: out STD_LOGIC;
          UARTS_AXI_wdata   => HLS_to_BD(0).wdata  ,                                   --: in STD_LOGIC_VECTOR ( 31 downto 0 );
          UARTS_AXI_wlast   => HLS_to_BD(0).wlast  ,                                   --: in STD_LOGIC;
          UARTS_AXI_wready  => BD_to_HLS(0).wready ,                                   --: out STD_LOGIC;
          UARTS_AXI_wstrb   => HLS_to_BD(0).wstrb  ,                                   --: in STD_LOGIC_VECTOR ( 3 downto 0 );
          UARTS_AXI_wvalid  => HLS_to_BD(0).wvalid ,                                   --: in STD_LOGIC;

          SPIS_AXI_araddr  => HLS_to_BD(1).araddr ,                                   --: in STD_LOGIC_VECTOR ( 31 downto 0 );
          SPIS_AXI_arburst => HLS_to_BD(1).arburst,                                   --: in STD_LOGIC_VECTOR ( 1 downto 0 );
          SPIS_AXI_arcache => HLS_to_BD(1).arcache,                                   --: in STD_LOGIC_VECTOR ( 3 downto 0 );
          SPIS_AXI_arlen   => HLS_to_BD(1).arlen  ,                                   --: in STD_LOGIC_VECTOR ( 7 downto 0 );
          SPIS_AXI_arlock(0)  => HLS_to_BD(1).arlock(0) ,                                   --: in STD_LOGIC_VECTOR ( 0 to 0 );
          SPIS_AXI_arprot  => HLS_to_BD(1).arprot ,                                   --: in STD_LOGIC_VECTOR ( 2 downto 0 );
          SPIS_AXI_arqos   => HLS_to_BD(1).arqos  ,                                   --: in STD_LOGIC_VECTOR ( 3 downto 0 );
          SPIS_AXI_arready => BD_to_HLS(1).arready,                                   --: out STD_LOGIC;
          SPIS_AXI_arsize  => HLS_to_BD(1).arsize ,                                   --: in STD_LOGIC_VECTOR ( 2 downto 0 );
          SPIS_AXI_arvalid => HLS_to_BD(1).arvalid,                                   --: in STD_LOGIC;
          SPIS_AXI_awaddr  => HLS_to_BD(1).awaddr ,                                   --: in STD_LOGIC_VECTOR ( 31 downto 0 );
          SPIS_AXI_awburst => HLS_to_BD(1).awburst,                                   --: in STD_LOGIC_VECTOR ( 1 downto 0 );
          SPIS_AXI_awcache => HLS_to_BD(1).awcache,                                   --: in STD_LOGIC_VECTOR ( 3 downto 0 );
          SPIS_AXI_awlen   => HLS_to_BD(1).awlen  ,                                   --: in STD_LOGIC_VECTOR ( 7 downto 0 );
          SPIS_AXI_awlock(0)  => HLS_to_BD(1).awlock(0) ,                                   --: in STD_LOGIC_VECTOR ( 0 to 0 );
          SPIS_AXI_awprot  => HLS_to_BD(1).awprot ,                                   --: in STD_LOGIC_VECTOR ( 2 downto 0 );
          SPIS_AXI_awqos   => HLS_to_BD(1).awqos  ,                                   --: in STD_LOGIC_VECTOR ( 3 downto 0 );
          SPIS_AXI_awready => BD_to_HLS(1).awready,                                   --: out STD_LOGIC;
          SPIS_AXI_awsize  => HLS_to_BD(1).awsize ,                                   --: in STD_LOGIC_VECTOR ( 2 downto 0 );
          SPIS_AXI_awvalid => HLS_to_BD(1).awvalid,                                   --: in STD_LOGIC;
          SPIS_AXI_bready  => HLS_to_BD(1).bready ,                                   --: in STD_LOGIC;
          SPIS_AXI_bresp   => BD_to_HLS(1).bresp  ,                                  --: out STD_LOGIC_VECTOR ( 1 downto 0 );
          SPIS_AXI_bvalid  => BD_to_HLS(1).bvalid ,                                  --: out STD_LOGIC;
          SPIS_AXI_rdata   => BD_to_HLS(1).rdata  ,                                  --: out STD_LOGIC_VECTOR ( 31 downto 0 );
          SPIS_AXI_rlast   => BD_to_HLS(1).rlast  ,                                  --: out STD_LOGIC;
          SPIS_AXI_rready  => HLS_to_BD(1).rready ,                                   --: in STD_LOGIC;
          SPIS_AXI_rresp   => BD_to_HLS(1).rresp  ,                                   --: out STD_LOGIC_VECTOR ( 1 downto 0 );
          SPIS_AXI_rvalid  => BD_to_HLS(1).rvalid ,                                   --: out STD_LOGIC;
          SPIS_AXI_wdata   => HLS_to_BD(1).wdata  ,                                   --: in STD_LOGIC_VECTOR ( 31 downto 0 );
          SPIS_AXI_wlast   => HLS_to_BD(1).wlast  ,                                   --: in STD_LOGIC;
          SPIS_AXI_wready  => BD_to_HLS(1).wready ,                                   --: out STD_LOGIC;
          SPIS_AXI_wstrb   => HLS_to_BD(1).wstrb  ,                                   --: in STD_LOGIC_VECTOR ( 3 downto 0 );
          SPIS_AXI_wvalid  => HLS_to_BD(1).wvalid ,                                   --: in STD_LOGIC;
          UART_0_rxd => RS485_RXD_1, -- this order of uarts is taken from spec
          UART_0_txd => RS485_TXD_1, -- |
          UART_1_rxd => RS485_RXD_9, -- |
          UART_1_txd => RS485_TXD_9, -- |
          UART_2_rxd => RS485_RXD_2, -- |
          UART_2_txd => RS485_TXD_2, -- |
          UART_3_rxd => RS485_RXD_3, -- |
          UART_3_txd => RS485_TXD_3, -- |
          UART_4_rxd => RS485_RXD_4, -- |
          UART_4_txd => RS485_TXD_4, -- |
          UART_5_rxd => RS485_RXD_5, -- |
          UART_5_txd => RS485_TXD_5, -- |
          UART_6_rxd => RS485_RXD_6, -- |
          UART_6_txd => RS485_TXD_6, -- |
          UART_7_rxd => RS485_RXD_7, -- |
          UART_7_txd => RS485_TXD_7, -- |
          UART_8_rxd => RS485_RXD_8, -- |
          UART_8_txd => RS485_TXD_8, -- \/
          ps_clk100 => ps_clk100,
          ps_clk100_rst(0) => ps_clk100_rst,
          ps_clk100_rstn(0) => ps_clk100_rstn,
          spi0_cs(0) => I_SNS_ADC_CS_FPGA,
          spi0_miso => I_SNS_ADC_SDO_FPGA,
          spi0_mosi => I_SNS_ADC_SDI_FPGA,
          spi1_cs(0) => ZCR_SNS_ADC_CS_FPGA,
          spi1_miso => ZCR_SNS_ADC_SDO_FPGA,
          spi1_mosi => ZCR_SNS_ADC_SDI_FPGA,
          spi1_sck => ZCR_SNS_ADC_SCLK_FPGA,
          spi2_cs(0) => HV_ADC_CS_FPGA,
          spi2_miso => HV_ADC_SDO_FPGA,
          spi2_mosi => HV_ADC_SDI_FPGA,
          spi2_sck => HV_ADC_SCLK_FPGA,
          spio0_sck => I_SNS_ADC_SCLK_FPGA,
          REGS_A => REGS_A,
          REGS_BE => REGS_BE,
          REGS_D => REGS_D,
          REGS_Q => REGS_Q,
          ps_intr => ps_intr
        );
    end generate bd_gen;

    ios_2_app.POWERON_FPGA     <= POWERON_FPGA    ;  
    ios_2_app.FAN_PG1_FPGA     <= FAN_PG1_FPGA    ;     
    ios_2_app.FAN_HALL1_FPGA   <= FAN_HALL1_FPGA  ;     
    ios_2_app.FAN_PG3_FPGA     <= FAN_PG3_FPGA    ;     
    ios_2_app.FAN_HALL3_FPGA   <= FAN_HALL3_FPGA  ;     
    ios_2_app.FAN_PG2_FPGA     <= FAN_PG2_FPGA    ;     
    ios_2_app.FAN_HALL2_FPGA   <= FAN_HALL2_FPGA  ;     
    ios_2_app.PG_BUCK_FB       <= PG_BUCK_FB      ;     
    ios_2_app.PG_PSU_1_FB      <= PG_PSU_1_FB     ;     
    ios_2_app.PG_PSU_2_FB      <= PG_PSU_2_FB     ;     
    ios_2_app.PG_PSU_5_FB      <= PG_PSU_5_FB     ;     
    ios_2_app.PG_PSU_6_FB      <= PG_PSU_6_FB     ;     
    ios_2_app.PG_PSU_7_FB      <= PG_PSU_7_FB     ;     
    ios_2_app.PG_PSU_8_FB      <= PG_PSU_8_FB     ;     
    ios_2_app.PG_PSU_9_FB      <= PG_PSU_9_FB     ;     
    ios_2_app.PG_PSU_10_FB     <= PG_PSU_10_FB    ;     
    ios_2_app.lamp_status_fpga <= lamp_status_fpga;     
    ios_2_app.PH_A_ON_fpga     <= PH_A_ON_fpga    ;      
    ios_2_app.PH_B_ON_fpga     <= PH_B_ON_fpga    ;      
    ios_2_app.PH_C_ON_fpga     <= PH_C_ON_fpga    ; 
    
    FAN_EN1_FPGA       <= app_2_ios.FAN_EN1_FPGA      ;
    FAN_CTRL1_FPGA     <= app_2_ios.FAN_CTRL1_FPGA    ;
    P_IN_STATUS_FPGA   <= app_2_ios.P_IN_STATUS_FPGA  ;
    POD_STATUS_FPGA    <= app_2_ios.POD_STATUS_FPGA   ;
    ECTCU_INH_FPGA     <= app_2_ios.ECTCU_INH_FPGA    ;
    P_OUT_STATUS_FPGA  <= app_2_ios.P_OUT_STATUS_FPGA ;
    CCTCU_INH_FPGA     <= app_2_ios.CCTCU_INH_FPGA    ;
    SHUTDOWN_OUT_FPGA  <= app_2_ios.SHUTDOWN_OUT_FPGA ;
    RESET_OUT_FPGA     <= app_2_ios.RESET_OUT_FPGA    ;
    SPARE_OUT_FPGA     <= app_2_ios.SPARE_OUT_FPGA    ;
    ESHUTDOWN_OUT_FPGA <= app_2_ios.ESHUTDOWN_OUT_FPGA;
    RELAY_1PH_FPGA     <= app_2_ios.RELAY_1PH_FPGA    ;
    RELAY_3PH_FPGA     <= app_2_ios.RELAY_3PH_FPGA    ;
    FAN_EN3_FPGA       <= app_2_ios.FAN_EN3_FPGA      ;
    FAN_CTRL3_FPGA     <= app_2_ios.FAN_CTRL3_FPGA    ;
    FAN_EN2_FPGA       <= app_2_ios.FAN_EN2_FPGA      ;
    FAN_CTRL2_FPGA     <= app_2_ios.FAN_CTRL2_FPGA    ;
    EN_PFC_FB          <= app_2_ios.EN_PFC_FB         ;
    EN_PSU_1_FB        <= app_2_ios.EN_PSU_1_FB       ;
    EN_PSU_2_FB        <= app_2_ios.EN_PSU_2_FB       ;
    EN_PSU_5_FB        <= app_2_ios.EN_PSU_5_FB       ;
    EN_PSU_6_FB        <= app_2_ios.EN_PSU_6_FB       ;
    EN_PSU_7_FB        <= app_2_ios.EN_PSU_7_FB       ;
    EN_PSU_8_FB        <= app_2_ios.EN_PSU_8_FB       ;
    EN_PSU_9_FB        <= app_2_ios.EN_PSU_9_FB       ;
    EN_PSU_10_FB       <= app_2_ios.EN_PSU_10_FB      ;
    RS485_DE_7         <= app_2_ios.RS485_DE_7        ; 
    RS485_DE_8         <= app_2_ios.RS485_DE_8        ;    
    RS485_DE_9         <= app_2_ios.RS485_DE_9        ;    
    RS485_DE_1         <= app_2_ios.RS485_DE_1        ;    
    RS485_DE_2         <= app_2_ios.RS485_DE_2        ;    
    RS485_DE_3         <= app_2_ios.RS485_DE_3        ;    
    RS485_DE_4         <= app_2_ios.RS485_DE_4        ;    
    RS485_DE_5         <= app_2_ios.RS485_DE_5        ;    
    RS485_DE_6         <= app_2_ios.RS485_DE_6        ;    

    REGS_WE <= REGS_BE(3) or REGS_BE(2) or REGS_BE(1) or REGS_BE(0);
    process(ps_clk100)
    begin
        if rising_edge(ps_clk100) then
            regs_reset <= ps_clk100_rst or sw_reset;
        end if;
    end process;

    regs_uart_inst : entity work.uart_if
    generic map(
        UART_A_SIZE => UART_A_SIZE
    )
    port map(
        CLK         => ps_clk100,
        ASYNC_RST   => ps_clk100_rst,
        USB_UART_RX => UART_RXD_PL,
        USB_UART_TX => UART_TXD_PL,
        UART_WE     => UART_we,
        UART_A      => UART_a,
        UART_D      => UART_d,
        D_TO_UART   => d_to_UART
    );

    regs_i: entity work.regs
    generic map(
        AXI_ADDR_SIZE        => AXI_A_SIZE,
        UART_ADDR_SIZE       => UART_A_SIZE,
        SYNTHESIS_TIME       => SYNTHESIS_TIME,
        FPGA_VERSION_C       => FPGA_VERSION_CONST,
        SIM_INPUT_FILE_NAME  => SIM_INPUT_FILE_NAME,
        SIM_OUTPUT_FILE_NAME => SIM_OUTPUT_FILE_NAME
    )
    port map(
        clk              => ps_clk100,
        sync_rst         => regs_reset,
        AXI_we           => REGS_WE,
        AXI_a            => REGS_A,
        AXI_d            => REGS_D,
        d_to_AXI         => REGS_Q,
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
    
    app_inst: entity work.app
    generic map(HLS_EN => HLS_EN)
    port map(
        clk              => ps_clk100,
        sync_rst         => ps_clk100_rst,
        sw_reset         => sw_reset,
        registers        => registers,
        regs_updating    => regs_updating,
        regs_reading     => regs_reading,
        internal_regs    => internal_regs,
        internal_regs_we => internal_regs_we,
        ios_2_app        => ios_2_app,
        app_2_ios        => app_2_ios,
        ps_intr          => ps_intr,
        BD_to_HLS        => BD_to_HLS,
        HLS_to_BD        => HLS_to_BD
    );

end Behavioral;
--check why ios are disapiring (not connected) after synthesis while they exist in the rtl design