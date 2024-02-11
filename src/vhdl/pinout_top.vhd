library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use ieee.numeric_bit.all;

--library UNISIM;
--use UNISIM.VComponents.all;
use work.condor_pl_pkg.all;
use work.sim_pkg.all;
use work.regs_pkg.all;

entity pinout_top is
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
end pinout_top;

architecture Behavioral of pinout_top is
    component design_1 is
    port (
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
        GPIO_IN_tri_i : in STD_LOGIC_VECTOR ( 31 downto 0 );
        GPIO_OUT_tri_o : out STD_LOGIC_VECTOR ( 31 downto 0 );
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
        spi1_cs : out STD_LOGIC_VECTOR ( 0 to 0 )
    );
    end component design_1;
  
    signal REGS_BE  : STD_LOGIC_VECTOR(3 downto 0);
    signal REGS_D   : STD_LOGIC_VECTOR(31 downto 0);
    signal REGS_A   : STD_LOGIC_VECTOR(11 downto 0);
    signal REGS_Q   : STD_LOGIC_VECTOR(31 downto 0);
    signal REGS_WE  : std_logic;

    signal UART_we   : STD_LOGIC;
    signal UART_a    : STD_LOGIC_VECTOR(UART_A_SIZE - 1 downto 0);
    signal UART_d    : STD_LOGIC_VECTOR(31 downto 0);
    signal d_to_UART : STD_LOGIC_VECTOR(31 downto 0); -- @suppress only place holder for now

    --signal registers        : reg32_array(NUM_REGS - 1 downto 0);
    signal regs_updating    : STD_LOGIC_VECTOR(NUM_REGS - 1 downto 0);
    signal regs_reading     : STD_LOGIC_VECTOR(NUM_REGS - 1 downto 0);
    --signal internal_regs    : reg32_array(NUM_REGS - 1 downto 0);
    signal internal_regs_we : STD_LOGIC_VECTOR(NUM_REGS - 1 downto 0);

    signal ios_2_app  : ios_2_app_t;
    signal app_2_ios  : app_2_ios_t;
    signal sw_reset   : std_logic;
    signal regs_reset : std_logic;
 

  signal ps_clk100 : std_logic;
  signal ps_clk100_rst : std_logic;
  signal ps_clk100_rstn : std_logic;
  signal gp_in: std_logic_vector(31 downto 0);
  signal gp_out: std_logic_vector(31 downto 0);

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
        GPIO_IN_tri_i => gp_in,
        GPIO_OUT_tri_o => gp_out,
        UART_0_rxd => RS485_RXD_1,
        UART_0_txd => RS485_TXD_1,
        UART_1_rxd => RS485_RXD_2,
        UART_1_txd => RS485_TXD_2,
        UART_2_rxd => RS485_RXD_3,
        UART_2_txd => RS485_TXD_3,
        UART_3_rxd => RS485_RXD_4,
        UART_3_txd => RS485_TXD_4,
        UART_4_rxd => RS485_RXD_5,
        UART_4_txd => RS485_TXD_5,
        UART_5_rxd => RS485_RXD_6,
        UART_5_txd => RS485_TXD_6,
        UART_6_rxd => RS485_RXD_7,
        UART_6_txd => RS485_TXD_7,
        UART_7_rxd => RS485_RXD_8,
        UART_7_txd => RS485_TXD_8,
        UART_8_rxd => RS485_RXD_9,
        UART_8_txd => RS485_TXD_9,
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
        spio0_sck => I_SNS_ADC_SCLK_FPGA
    );
	
	ios_2_app(POWERON_FPGA    ) <= POWERON_FPGA    ;  
	ios_2_app(FAN_PG1_FPGA    ) <= FAN_PG1_FPGA    ;  	 
	ios_2_app(FAN_HALL1_FPGA  ) <= FAN_HALL1_FPGA  ;  	 
	ios_2_app(FAN_PG3_FPGA    ) <= FAN_PG3_FPGA    ;  	 
	ios_2_app(FAN_HALL3_FPGA  ) <= FAN_HALL3_FPGA  ;  	 
	ios_2_app(UART_RXD_PL     ) <= UART_RXD_PL	   ;      
	ios_2_app(FAN_PG2_FPGA    ) <= FAN_PG2_FPGA    ;  	 
	ios_2_app(FAN_HALL2_FPGA  ) <= FAN_HALL2_FPGA  ;  	 
	ios_2_app(PG_BUCK_FB      ) <= PG_BUCK_FB      ;  	 
	ios_2_app(PG_PSU_1_FB     ) <= PG_PSU_1_FB     ;  	 
	ios_2_app(PG_PSU_2_FB     ) <= PG_PSU_2_FB     ;  	 
	ios_2_app(PG_PSU_5_FB     ) <= PG_PSU_5_FB     ;  	 
	ios_2_app(PG_PSU_6_FB     ) <= PG_PSU_6_FB     ;  	 
	ios_2_app(PG_PSU_7_FB     ) <= PG_PSU_7_FB     ;  	 
	ios_2_app(PG_PSU_8_FB     ) <= PG_PSU_8_FB     ;  	 
	ios_2_app(PG_PSU_9_FB     ) <= PG_PSU_9_FB     ;  	 
	ios_2_app(PG_PSU_10_FB    ) <= PG_PSU_10_FB    ;  	 
	ios_2_app(lamp_status_fpga) <= lamp_status_fpga;     
	ios_2_app(PH_A_ON_fpga    ) <= PH_A_ON_fpga	   ;      
	ios_2_app(PH_B_ON_fpga    ) <= PH_B_ON_fpga	   ;      
	ios_2_app(PH_C_ON_fpga    ) <= PH_C_ON_fpga	   ; 
	
	
	gp_in <= (others => '0');     

	FAN_EN1_FPGA       <= app_2_ios(FAN_EN1_FPGA      );
	FAN_CTRL1_FPGA     <= app_2_ios(FAN_CTRL1_FPGA    );
	P_IN_STATUS_FPGA   <= app_2_ios(P_IN_STATUS_FPGA  );
	POD_STATUS_FPGA    <= app_2_ios(POD_STATUS_FPGA   );
	ECTCU_INH_FPGA     <= app_2_ios(ECTCU_INH_FPGA    );
	P_OUT_STATUS_FPGA  <= app_2_ios(P_OUT_STATUS_FPGA );
	CCTCU_INH_FPGA     <= app_2_ios(CCTCU_INH_FPGA    );
	SHUTDOWN_OUT_FPGA  <= app_2_ios(SHUTDOWN_OUT_FPGA );
	RESET_OUT_FPGA     <= app_2_ios(RESET_OUT_FPGA    );
	SPARE_OUT_FPGA     <= app_2_ios(SPARE_OUT_FPGA    );
	ESHUTDOWN_OUT_FPGA <= app_2_ios(ESHUTDOWN_OUT_FPGA);
	RELAY_1PH_FPGA     <= app_2_ios(RELAY_1PH_FPGA    );
	RELAY_3PH_FPGA     <= app_2_ios(RELAY_3PH_FPGA    );
	FAN_EN3_FPGA       <= app_2_ios(FAN_EN3_FPGA      );
	FAN_CTRL3_FPGA     <= app_2_ios(FAN_CTRL3_FPGA    );
	FAN_EN2_FPGA       <= app_2_ios(FAN_EN2_FPGA      );
	FAN_CTRL2_FPGA     <= app_2_ios(FAN_CTRL2_FPGA    );
	UART_TXD_PL	       <= app_2_ios(UART_TXD_PL       );
	EN_PFC_FB          <= app_2_ios(EN_PFC_FB         );
	EN_PSU_1_FB        <= app_2_ios(EN_PSU_1_FB       );
	EN_PSU_2_FB        <= app_2_ios(EN_PSU_2_FB       );
	EN_PSU_5_FB        <= app_2_ios(EN_PSU_5_FB       );
	EN_PSU_6_FB        <= app_2_ios(EN_PSU_6_FB       );
	EN_PSU_7_FB        <= app_2_ios(EN_PSU_7_FB       );
	EN_PSU_8_FB        <= app_2_ios(EN_PSU_8_FB       );
	EN_PSU_9_FB        <= app_2_ios(EN_PSU_9_FB       );
	EN_PSU_10_FB       <= app_2_ios(EN_PSU_10_FB      );
	RS485_DE_7         <= app_2_ios(RS485_DE_7        ); 
	RS485_DE_8         <= app_2_ios(RS485_DE_8        );  	
	RS485_DE_9         <= app_2_ios(RS485_DE_9        );  	
	RS485_DE_1         <= app_2_ios(RS485_DE_1        );  	
	RS485_DE_2         <= app_2_ios(RS485_DE_2        );  	
	RS485_DE_3         <= app_2_ios(RS485_DE_3        );  	
	RS485_DE_4         <= app_2_ios(RS485_DE_4        );  	
	RS485_DE_5         <= app_2_ios(RS485_DE_5        );  	
	RS485_DE_6         <= app_2_ios(RS485_DE_6        );  	

end Behavioral;
