library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--library UNISIM;
--use UNISIM.VComponents.all;

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
	gp_in( 0) <= POWERON_FPGA;  
	gp_in( 1) <= FAN_PG1_FPGA ;  	 
	gp_in( 2) <= FAN_HALL1_FPGA;  	 
	gp_in( 3) <= FAN_PG3_FPGA ;  	 
	gp_in( 4) <= FAN_HALL3_FPGA;  	 
	gp_in( 5) <= UART_RXD_PL	 ;      
	gp_in( 6) <= FAN_PG2_FPGA ;  	 
	gp_in( 7) <= FAN_HALL2_FPGA;  	 
	gp_in( 8) <= PG_BUCK_FB   ;  	 
	gp_in( 9) <= PG_PSU_1_FB  ;  	 
	gp_in(10) <= PG_PSU_2_FB  ;  	 
	gp_in(11) <= PG_PSU_5_FB  ;  	 
	gp_in(12) <= PG_PSU_6_FB  ;  	 
	gp_in(13) <= PG_PSU_7_FB  ;  	 
	gp_in(14) <= PG_PSU_8_FB  ;  	 
	gp_in(15) <= PG_PSU_9_FB  ;  	 
	gp_in(16) <= PG_PSU_10_FB ;  	 
	gp_in(17) <= lamp_status_fpga;     
	gp_in(18) <= PH_A_ON_fpga	;      
	gp_in(19) <= PH_B_ON_fpga	;      
	gp_in(20) <= PH_C_ON_fpga	; 
	gp_in(31 downto 21) <= (others => '0');     

	FAN_EN1_FPGA       <= gp_out( 0);
	FAN_CTRL1_FPGA     <= gp_out( 1);
	P_IN_STATUS_FPGA   <= gp_out( 2);
	POD_STATUS_FPGA    <= gp_out( 3);
	ECTCU_INH_FPGA     <= gp_out( 4);
	P_OUT_STATUS_FPGA  <= gp_out( 5);
	CCTCU_INH_FPGA     <= gp_out( 6);
	SHUTDOWN_OUT_FPGA  <= gp_out( 7);
	RESET_OUT_FPGA     <= gp_out( 8);
	SPARE_OUT_FPGA     <= gp_out( 9);
	ESHUTDOWN_OUT_FPGA <= gp_out(10);
	RELAY_1PH_FPGA     <= gp_out(11);
	RELAY_3PH_FPGA     <= gp_out(12);
	FAN_EN3_FPGA       <= gp_out(13);
	FAN_CTRL3_FPGA     <= gp_out(14);
	FAN_EN2_FPGA       <= gp_out(15);
	FAN_CTRL2_FPGA     <= gp_out(16);
	UART_TXD_PL	       <= gp_out(17);
	EN_PFC_FB          <= gp_out(18);
	EN_PSU_1_FB        <= gp_out(19);
	EN_PSU_2_FB        <= gp_out(20);
	EN_PSU_5_FB        <= gp_out(21);
	EN_PSU_6_FB        <= gp_out(22);
	EN_PSU_7_FB        <= gp_out(23);
	EN_PSU_8_FB        <= gp_out(24);
	EN_PSU_9_FB        <= gp_out(25);
	EN_PSU_10_FB       <= gp_out(26);

	RS485_DE_7         <= gp_out(27); 
	RS485_DE_8         <= gp_out(27);  	
	RS485_DE_9         <= gp_out(27);  	
	RS485_DE_1         <= gp_out(27);  	
	RS485_DE_2         <= gp_out(27);  	
	RS485_DE_3         <= gp_out(27);  	
	RS485_DE_4         <= gp_out(27);  	
	RS485_DE_5         <= gp_out(27);  	
	RS485_DE_6         <= gp_out(27);  	

end Behavioral;
