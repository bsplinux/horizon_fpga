library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.numeric_std_unsigned.all;

use work.condor_pl_pkg.all;
--use work.sim_pkg.all;
use work.regs_pkg.all;

entity rs485_if is
    generic(HLS_EN : boolean);
    port(
        clk              : in  std_logic;
        sync_rst         : in  std_logic;
        registers        : in  reg_array_t;
        regs_updating    : in  reg_slv_array_t;
        --regs_reading     : in  reg_slv_array_t;
        internal_regs    : out reg_array_t;
        internal_regs_we : out reg_slv_array_t;
        HLS_to_BD        : out HLS_axim_to_interconnect_t;
        BD_to_HLS        : in  HLS_axim_from_interconnect_t;
        one_ms_interrupt : in  std_logic;
        de               : out std_logic_vector(8 downto 0)
    );
end entity rs485_if;

architecture RTL of rs485_if is
    COMPONENT uarts_0 is
    PORT (
        uarts_d_0_ap_vld : OUT STD_LOGIC;
        uarts_d_1_ap_vld : OUT STD_LOGIC;
        uarts_d_2_ap_vld : OUT STD_LOGIC;
        uarts_d_3_ap_vld : OUT STD_LOGIC;
        uarts_d_4_ap_vld : OUT STD_LOGIC;
        uarts_d_5_ap_vld : OUT STD_LOGIC;
        uarts_d_6_ap_vld : OUT STD_LOGIC;
        uarts_d_7_ap_vld : OUT STD_LOGIC;
        uarts_d_8_ap_vld : OUT STD_LOGIC;
        ap_clk : IN STD_LOGIC;
        ap_rst_n : IN STD_LOGIC;
        ap_start : IN STD_LOGIC;
        ap_done : OUT STD_LOGIC;
        ap_idle : OUT STD_LOGIC;
        ap_ready : OUT STD_LOGIC;
        m_axi_axi_AWID : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        m_axi_axi_AWADDR : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        m_axi_axi_AWLEN : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        m_axi_axi_AWSIZE : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        m_axi_axi_AWBURST : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        m_axi_axi_AWLOCK : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        m_axi_axi_AWREGION : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        m_axi_axi_AWCACHE : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        m_axi_axi_AWPROT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        m_axi_axi_AWQOS : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        m_axi_axi_AWVALID : OUT STD_LOGIC;
        m_axi_axi_AWREADY : IN STD_LOGIC;
        m_axi_axi_WID : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        m_axi_axi_WDATA : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        m_axi_axi_WSTRB : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        m_axi_axi_WLAST : OUT STD_LOGIC;
        m_axi_axi_WVALID : OUT STD_LOGIC;
        m_axi_axi_WREADY : IN STD_LOGIC;
        m_axi_axi_BID : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        m_axi_axi_BRESP : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        m_axi_axi_BVALID : IN STD_LOGIC;
        m_axi_axi_BREADY : OUT STD_LOGIC;
        m_axi_axi_ARID : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        m_axi_axi_ARADDR : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        m_axi_axi_ARLEN : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        m_axi_axi_ARSIZE : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        m_axi_axi_ARBURST : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        m_axi_axi_ARLOCK : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        m_axi_axi_ARREGION : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        m_axi_axi_ARCACHE : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        m_axi_axi_ARPROT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        m_axi_axi_ARQOS : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        m_axi_axi_ARVALID : OUT STD_LOGIC;
        m_axi_axi_ARREADY : IN STD_LOGIC;
        m_axi_axi_RID : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        m_axi_axi_RDATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        m_axi_axi_RRESP : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        m_axi_axi_RLAST : IN STD_LOGIC;
        m_axi_axi_RVALID : IN STD_LOGIC;
        m_axi_axi_RREADY : OUT STD_LOGIC;
        uart_en : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
        uarts_d_0 : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
        uarts_d_1 : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
        uarts_d_2 : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
        uarts_d_3 : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
        uarts_d_4 : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
        uarts_d_5 : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
        uarts_d_6 : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
        uarts_d_7 : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
        uarts_d_8 : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
        uart_de   : OUT STD_LOGIC_VECTOR(8 DOWNTO 0); 
        uart_de_ap_vld : OUT STD_LOGIC
    );
    end component uarts_0;
    
    signal uarts_d_ap_vld : std_logic_vector(UARTS_RANGE);
    signal uarts_calc_vld : std_logic_vector(UARTS_RANGE);
    signal hls_rstn : STD_LOGIC;
    signal ap_start : STD_LOGIC;
    signal ap_done : STD_LOGIC;
    signal ap_idle : STD_LOGIC;
    signal ap_ready : STD_LOGIC;
    --signal uart_en : STD_LOGIC_VECTOR(8 DOWNTO 0);
    type uarts_d_array_t is array (UARTS_RANGE) of std_logic_vector(63 downto 0);
    signal uarts_d_array  : uarts_d_array_t;
    signal uarts_calc_array : uarts_d_array_t;
    signal uart_de : STD_LOGIC_VECTOR(UARTS_RANGE);
    signal uart_de_ap_vld : STD_LOGIC;
    signal one_ms_error : std_logic;
    
--    function swap_bytes(vec: std_logic_vector) return std_logic_vector is
--        variable swapped : std_logic_vector := (others => '0');
--        variable num_bytes : integer := (vec'length / 8);
--    begin
--        for i in 0 to num_bytes - 1 loop
--            swapped(8*i + 7 downto 8*i) := vec(7 + (num_bytes-1)*8 - (8*i) downto (num_bytes - 1)*8 - (8*i));
--        end loop;
--        return swapped;
--    end;
    
    
begin
    sm_pr: process(clk)
        type state_t is (idle,wt_rdy, wt_done);
        variable state : state_t := idle; 
        variable allow_hls : boolean := false;
    begin
        if rising_edge(clk) then
            if sync_rst then
                state := idle;
                ap_start <= '0';
                allow_hls := false;
                one_ms_error <= '0';
            else
                allow_hls := false;
                if registers(UARTS_CONTROL)(UARTS_CONTROL_EN_RANGE) /= "000000000" then
                    allow_hls := true;
                end if;
                
                --next state logic
                case state is 
                when idle =>
                    if one_ms_interrupt = '1' and allow_hls and ap_idle = '1' then
                        state := wt_rdy;
                    end if;
                when wt_rdy =>
                    if ap_done or one_ms_interrupt then
                        state := idle;
                    elsif ap_ready then
                        state := wt_done;
                    end if;
                when wt_done =>
                    if ap_done or one_ms_interrupt then
                        state := idle;
                    end if;
                end case;

                -- output logic
                ap_start <= '0';
                case state is 
                when idle =>
                    if one_ms_interrupt = '1' and allow_hls and ap_idle = '0' and hls_rstn = '1' then
                        one_ms_error <= '1';
                    end if;
                when wt_rdy =>
                    ap_start <= '1';
                    if one_ms_interrupt = '1' and ap_start = '1' then
                        one_ms_error <= '1';
                    end if;
                when wt_done =>
                    if one_ms_interrupt = '1' then
                        one_ms_error <= '1';
                    end if;
                end case;
                
                if registers(UARTS_CONTROL)(UARTS_CONTROL_MS1_ERR_CLR) and regs_updating(UARTS_CONTROL) then
                    one_ms_error <= '0';
                end if;
            
            end if;
        end if;
    end process;

    rst_pr: process(clk)
        variable one_ms_error_s : std_logic;
    begin
        if rising_edge(clk) then
            if sync_rst then
                hls_rstn <= '0';
                one_ms_error_s := '0';
            else
                hls_rstn <= '1';
                if (one_ms_error_s = '0' and one_ms_error = '1') or sync_rst = '1' or 
                    (registers(UARTS_CONTROL)(UARTS_CONTROL_RST) = '1' and regs_updating(UARTS_CONTROL) = '1') then
                        hls_rstn <= '0';
                end if;                
                one_ms_error_s := one_ms_error;
            end if;
        end if;
    end process;
    
    rgs_wr_pr: process(all)
    begin
        internal_regs_we <= (others => '0');
        internal_regs <= (others => X"00000000");
        
        internal_regs_we(UART_RAW0_L) <= uarts_d_ap_vld(0);
        internal_regs_we(UART_RAW1_L) <= uarts_d_ap_vld(1);
        internal_regs_we(UART_RAW2_L) <= uarts_d_ap_vld(2);
        internal_regs_we(UART_RAW3_L) <= uarts_d_ap_vld(3);
        internal_regs_we(UART_RAW4_L) <= uarts_d_ap_vld(4);
        internal_regs_we(UART_RAW5_L) <= uarts_d_ap_vld(5);
        internal_regs_we(UART_RAW6_L) <= uarts_d_ap_vld(6);
        internal_regs_we(UART_RAW7_L) <= uarts_d_ap_vld(7);
        internal_regs_we(UART_RAW8_L) <= uarts_d_ap_vld(8);
        internal_regs_we(UART_RAW0_H) <= uarts_d_ap_vld(0);
        internal_regs_we(UART_RAW1_H) <= uarts_d_ap_vld(1);
        internal_regs_we(UART_RAW2_H) <= uarts_d_ap_vld(2);
        internal_regs_we(UART_RAW3_H) <= uarts_d_ap_vld(3);
        internal_regs_we(UART_RAW4_H) <= uarts_d_ap_vld(4);
        internal_regs_we(UART_RAW5_H) <= uarts_d_ap_vld(5);
        internal_regs_we(UART_RAW6_H) <= uarts_d_ap_vld(6);
        internal_regs_we(UART_RAW7_H) <= uarts_d_ap_vld(7);
        internal_regs_we(UART_RAW8_H) <= uarts_d_ap_vld(8);

        internal_regs(UART_RAW0_L) <= uarts_d_array(0)(31 downto 0);
        internal_regs(UART_RAW1_L) <= uarts_d_array(1)(31 downto 0);
        internal_regs(UART_RAW2_L) <= uarts_d_array(2)(31 downto 0);
        internal_regs(UART_RAW3_L) <= uarts_d_array(3)(31 downto 0);
        internal_regs(UART_RAW4_L) <= uarts_d_array(4)(31 downto 0);
        internal_regs(UART_RAW5_L) <= uarts_d_array(5)(31 downto 0);
        internal_regs(UART_RAW6_L) <= uarts_d_array(6)(31 downto 0);
        internal_regs(UART_RAW7_L) <= uarts_d_array(7)(31 downto 0);
        internal_regs(UART_RAW8_L) <= uarts_d_array(8)(31 downto 0);
        internal_regs(UART_RAW0_H) <= uarts_d_array(0)(63 downto 32);
        internal_regs(UART_RAW1_H) <= uarts_d_array(1)(63 downto 32);
        internal_regs(UART_RAW2_H) <= uarts_d_array(2)(63 downto 32);
        internal_regs(UART_RAW3_H) <= uarts_d_array(3)(63 downto 32);
        internal_regs(UART_RAW4_H) <= uarts_d_array(4)(63 downto 32);
        internal_regs(UART_RAW5_H) <= uarts_d_array(5)(63 downto 32);
        internal_regs(UART_RAW6_H) <= uarts_d_array(6)(63 downto 32);
        internal_regs(UART_RAW7_H) <= uarts_d_array(7)(63 downto 32);
        internal_regs(UART_RAW8_H) <= uarts_d_array(8)(63 downto 32);
        
        internal_regs_we(UARTS_STATUS) <= '1';
        internal_regs(UARTS_STATUS)(UARTS_STATUS_BUSY) <= not ap_idle;
        internal_regs(UARTS_STATUS)(UARTS_STATUS_MS1_ERR) <= one_ms_error;
        
        internal_regs_we(UART_CALC0_L) <= uarts_calc_vld(0);
        internal_regs_we(UART_CALC1_L) <= uarts_calc_vld(1);
        internal_regs_we(UART_CALC2_L) <= uarts_calc_vld(2);
        internal_regs_we(UART_CALC3_L) <= uarts_calc_vld(3);
        internal_regs_we(UART_CALC4_L) <= uarts_calc_vld(4);
        internal_regs_we(UART_CALC5_L) <= uarts_calc_vld(5);
        internal_regs_we(UART_CALC6_L) <= uarts_calc_vld(6);
        internal_regs_we(UART_CALC7_L) <= uarts_calc_vld(7);
        internal_regs_we(UART_CALC8_L) <= uarts_calc_vld(8);
        internal_regs_we(UART_CALC0_H) <= uarts_calc_vld(0);
        internal_regs_we(UART_CALC1_H) <= uarts_calc_vld(1);
        internal_regs_we(UART_CALC2_H) <= uarts_calc_vld(2);
        internal_regs_we(UART_CALC3_H) <= uarts_calc_vld(3);
        internal_regs_we(UART_CALC4_H) <= uarts_calc_vld(4);
        internal_regs_we(UART_CALC5_H) <= uarts_calc_vld(5);
        internal_regs_we(UART_CALC6_H) <= uarts_calc_vld(6);
        internal_regs_we(UART_CALC7_H) <= uarts_calc_vld(7);
        internal_regs_we(UART_CALC8_H) <= uarts_calc_vld(8);

        internal_regs(UART_CALC0_L) <= uarts_calc_array(0)(31 downto 0);
        internal_regs(UART_CALC1_L) <= uarts_calc_array(1)(31 downto 0);
        internal_regs(UART_CALC2_L) <= uarts_calc_array(2)(31 downto 0);
        internal_regs(UART_CALC3_L) <= uarts_calc_array(3)(31 downto 0);
        internal_regs(UART_CALC4_L) <= uarts_calc_array(4)(31 downto 0);
        internal_regs(UART_CALC5_L) <= uarts_calc_array(5)(31 downto 0);
        internal_regs(UART_CALC6_L) <= uarts_calc_array(6)(31 downto 0);
        internal_regs(UART_CALC7_L) <= uarts_calc_array(7)(31 downto 0);
        internal_regs(UART_CALC8_L) <= uarts_calc_array(8)(31 downto 0);
        internal_regs(UART_CALC0_H) <= uarts_calc_array(0)(63 downto 32);
        internal_regs(UART_CALC1_H) <= uarts_calc_array(1)(63 downto 32);
        internal_regs(UART_CALC2_H) <= uarts_calc_array(2)(63 downto 32);
        internal_regs(UART_CALC3_H) <= uarts_calc_array(3)(63 downto 32);
        internal_regs(UART_CALC4_H) <= uarts_calc_array(4)(63 downto 32);
        internal_regs(UART_CALC5_H) <= uarts_calc_array(5)(63 downto 32);
        internal_regs(UART_CALC6_H) <= uarts_calc_array(6)(63 downto 32);
        internal_regs(UART_CALC7_H) <= uarts_calc_array(7)(63 downto 32);
        internal_regs(UART_CALC8_H) <= uarts_calc_array(8)(63 downto 32);
        
    end process;
    
    gen_hls: if HLS_EN generate
    begin
    
        hls_i:  uarts_0
        port map(
            uarts_d_0_ap_vld   => uarts_d_ap_vld(0),
            uarts_d_1_ap_vld   => uarts_d_ap_vld(1),
            uarts_d_2_ap_vld   => uarts_d_ap_vld(2),
            uarts_d_3_ap_vld   => uarts_d_ap_vld(3),
            uarts_d_4_ap_vld   => uarts_d_ap_vld(4),
            uarts_d_5_ap_vld   => uarts_d_ap_vld(5),
            uarts_d_6_ap_vld   => uarts_d_ap_vld(6),
            uarts_d_7_ap_vld   => uarts_d_ap_vld(7),
            uarts_d_8_ap_vld   => uarts_d_ap_vld(8),
            ap_clk             => clk,
            ap_rst_n           => hls_rstn,
            ap_start           => ap_start,
            ap_done            => ap_done,
            ap_idle            => ap_idle,
            ap_ready           => ap_ready,
            m_axi_axi_AWID     => open,
            m_axi_axi_AWADDR   => HLS_to_BD.AWADDR,
            m_axi_axi_AWLEN    => HLS_to_BD.AWLEN,
            m_axi_axi_AWSIZE   => HLS_to_BD.AWSIZE,
            m_axi_axi_AWBURST  => HLS_to_BD.AWBURST,
            m_axi_axi_AWLOCK   => HLS_to_BD.AWLOCK,
            m_axi_axi_AWREGION => HLS_to_BD.AWREGION,
            m_axi_axi_AWCACHE  => HLS_to_BD.AWCACHE,
            m_axi_axi_AWPROT   => HLS_to_BD.AWPROT,
            m_axi_axi_AWQOS    => HLS_to_BD.AWQOS,
            m_axi_axi_AWVALID  => HLS_to_BD.AWVALID,
            m_axi_axi_AWREADY  => BD_to_HLS.AWREADY,
            m_axi_axi_WID      => open,
            m_axi_axi_WDATA    => HLS_to_BD.WDATA,
            m_axi_axi_WSTRB    => HLS_to_BD.WSTRB,
            m_axi_axi_WLAST    => HLS_to_BD.WLAST,
            m_axi_axi_WVALID   => HLS_to_BD.WVALID,
            m_axi_axi_WREADY   => BD_to_HLS.WREADY,
            m_axi_axi_BID      => "0",
            m_axi_axi_BRESP    => BD_to_HLS.BRESP,
            m_axi_axi_BVALID   => BD_to_HLS.BVALID,
            m_axi_axi_BREADY   => HLS_to_BD.BREADY,
            m_axi_axi_ARID     => open,
            m_axi_axi_ARADDR   => HLS_to_BD.ARADDR,
            m_axi_axi_ARLEN    => HLS_to_BD.ARLEN,
            m_axi_axi_ARSIZE   => HLS_to_BD.ARSIZE,
            m_axi_axi_ARBURST  => HLS_to_BD.ARBURST,
            m_axi_axi_ARLOCK   => HLS_to_BD.ARLOCK,
            m_axi_axi_ARREGION => HLS_to_BD.ARREGION,
            m_axi_axi_ARCACHE  => HLS_to_BD.ARCACHE,
            m_axi_axi_ARPROT   => HLS_to_BD.ARPROT,
            m_axi_axi_ARQOS    => HLS_to_BD.ARQOS,
            m_axi_axi_ARVALID  => HLS_to_BD.ARVALID,
            m_axi_axi_ARREADY  => BD_to_HLS.ARREADY,
            m_axi_axi_RID      => "0",
            m_axi_axi_RDATA    => BD_to_HLS.RDATA,
            m_axi_axi_RRESP    => BD_to_HLS.RRESP,
            m_axi_axi_RLAST    => BD_to_HLS.RLAST,
            m_axi_axi_RVALID   => BD_to_HLS.RVALID,
            m_axi_axi_RREADY   => HLS_to_BD.RREADY,
            uart_en            => registers(UARTS_CONTROL)(UARTS_CONTROL_EN_RANGE),
            uarts_d_0          => uarts_d_array(0),
            uarts_d_1          => uarts_d_array(1),
            uarts_d_2          => uarts_d_array(2),
            uarts_d_3          => uarts_d_array(3),
            uarts_d_4          => uarts_d_array(4),
            uarts_d_5          => uarts_d_array(5),
            uarts_d_6          => uarts_d_array(6),
            uarts_d_7          => uarts_d_array(7),
            uarts_d_8          => uarts_d_array(8),
            uart_de            => uart_de,
            uart_de_ap_vld     => uart_de_ap_vld
        );
        
--        process(all)
--        begin
--            for uart in uarts_d_array'range loop
--                uarts_d_array(uart) <= swap_bytes(uarts_tmp_array(uart));
--            end loop;
--        end process;
        
    else generate
        
    end generate gen_hls;
    
    sample_de_pr: process(clk)
    begin
        if rising_edge(clk) then
            if sync_rst then
                de <= (others => '0');
            else
                if uart_de_ap_vld then
                    de <= uart_de;
                end if;
            end if;
        end if;
    end process;
    
    gen_calc: for uart in UARTS_RANGE generate
        constant NORM_TEMP : integer := 60;
        constant NORM_VIN  : signed(27 downto 0) := to_signed(integer(0.028    * 2**16),28);
        constant NORM_VOUT : signed(27 downto 0) := to_signed(integer(0.014    * 2**16),28);
        constant NORM_I    : signed(27 downto 0) := to_signed(integer(0.016117 * 2**16),28);

        subtype UART_TEMP_RANGE   is integer range 7 downto 0;
        subtype UART_VIN_L_RANGE  is integer range 23 downto 16;
        subtype UART_VIN_H_RANGE  is integer range 15 downto 12;
        subtype UART_VOUT_RANGE   is integer range 35 downto 24;
        subtype UART_IIN_L_RANGE  is integer range 47 downto 40;
        subtype UART_IIN_H_RANGE  is integer range 39 downto 36;
        subtype UART_IOUT_RANGE   is integer range 59 downto 48;
        constant UART_OVP         : integer := 63;
        constant UART_OCP         : integer := 62;
        constant UART_OTP         : integer := 61;
        constant UART_VINP        : integer := 60;
    begin    
        main_board_gen : if uart = 8 generate
            calc_main_board_pr: process(clk)
                subtype UART_IPHA_L_RANGE  is integer range 23 downto 16;
                subtype UART_IPHA_H_RANGE  is integer range 15 downto 12;
                subtype UART_IPHB_RANGE    is integer range 35 downto 24;
                subtype UART_IPHC_L_RANGE  is integer range 47 downto 40;
                subtype UART_IPHC_H_RANGE  is integer range 39 downto 36;
                constant MAIN_BORD_CAP_EOL     : integer := 48;
                constant MAIN_BORD_OVP         : integer := 55;
                constant MAIN_BORD_OCP         : integer := 54;
                constant MAIN_BORD_OTP         : integer := 53;
                constant MAIN_BORD_VINP        : integer := 52;
                
                variable ipha_var  : signed(11 downto 0);
                variable iphc_var  : signed(11 downto 0);
                variable ipha_tmp  : signed(39 downto 0);
                variable iphb_tmp : signed(39 downto 0);
                variable iphc_tmp  : signed(39 downto 0);
                
            begin
                if rising_edge(clk) then
                    if sync_rst then
                        ipha_var := (others => '0');
                        iphc_var := (others => '0');
                    else
                        ipha_var := signed(uarts_d_array(uart)(UART_IPHA_H_RANGE)) & signed(uarts_d_array(uart)(UART_IPHA_L_RANGE));
                        iphc_var := signed(uarts_d_array(uart)(UART_IPHC_H_RANGE)) & signed(uarts_d_array(uart)(UART_IPHC_L_RANGE));
                        if uarts_d_ap_vld(uart) then
                            ipha_tmp   := ipha_var * NORM_I;
                            iphb_tmp  := signed(uarts_d_array(uart)(UART_IPHB_RANGE)) * NORM_I;
                            iphc_tmp   := iphc_var * NORM_I;
                            
                            uarts_calc_array(uart) <= (others => '0');
                            uarts_calc_array(uart)(UART_TEMP_RANGE)  <=  uarts_d_array(uart)(UART_TEMP_RANGE) - NORM_TEMP;
                            uarts_calc_array(uart)(UART_IPHA_L_RANGE) <= std_logic_vector(ipha_tmp(23 downto 16)); 
                            uarts_calc_array(uart)(UART_IPHA_H_RANGE) <= std_logic_vector(ipha_tmp(27 downto 24)); 
                            uarts_calc_array(uart)(UART_IPHB_RANGE  ) <= std_logic_vector(iphb_tmp(27 downto 16)); 
                            uarts_calc_array(uart)(UART_IPHC_L_RANGE) <= std_logic_vector(iphc_tmp(23 downto 16));
                            uarts_calc_array(uart)(UART_IPHC_H_RANGE) <= std_logic_vector(iphc_tmp(27 downto 24));
                            uarts_calc_array(uart)(MAIN_BORD_CAP_EOL) <= uarts_d_array(uart)(MAIN_BORD_CAP_EOL);
                            uarts_calc_array(uart)(MAIN_BORD_OVP    ) <= uarts_d_array(uart)(MAIN_BORD_OVP    );
                            uarts_calc_array(uart)(MAIN_BORD_OCP    ) <= uarts_d_array(uart)(MAIN_BORD_OCP    );
                            uarts_calc_array(uart)(MAIN_BORD_OTP    ) <= uarts_d_array(uart)(MAIN_BORD_OTP    );
                            uarts_calc_array(uart)(MAIN_BORD_VINP   ) <= uarts_d_array(uart)(MAIN_BORD_VINP   );
                        end if;
                        uarts_calc_vld(uart) <= uarts_d_ap_vld(uart);
                    end if;
                end if;
            end process;
            
        else generate -- all other uarts (0 to 7) are from DC/DC boards 
        
            calc_uarts_pr: process(clk)
                variable vin_var  : signed(11 downto 0);
                variable iin_var  : signed(11 downto 0);
                variable vin_tmp  : signed(39 downto 0);
                variable vout_tmp : signed(39 downto 0);
                variable iin_tmp  : signed(39 downto 0);
                variable iout_tmp : signed(39 downto 0);
                
            begin
                if rising_edge(clk) then
                    if sync_rst then
                        vin_var := (others => '0');
                        iin_var := (others => '0');
                    else
                        vin_var := signed(uarts_d_array(uart)(UART_VIN_H_RANGE)) & signed(uarts_d_array(uart)(UART_VIN_L_RANGE));
                        iin_var := signed(uarts_d_array(uart)(UART_IIN_H_RANGE)) & signed(uarts_d_array(uart)(UART_IIN_L_RANGE));
                        if uarts_d_ap_vld(uart) then
                            vin_tmp   := vin_var * NORM_VIN;
                            vout_tmp  := signed(uarts_d_array(uart)(UART_VOUT_RANGE)) * NORM_VOUT;
                            iin_tmp   := iin_var * NORM_I;
                            iout_tmp  := signed(uarts_d_array(uart)(UART_IOUT_RANGE)) * NORM_I;
                            
                            uarts_calc_array(uart) <= (others => '0');
                            uarts_calc_array(uart)(UART_TEMP_RANGE)  <=  uarts_d_array(uart)(UART_TEMP_RANGE) - NORM_TEMP;
                            uarts_calc_array(uart)(UART_VIN_L_RANGE) <= std_logic_vector(vin_tmp(23 downto 16)); 
                            uarts_calc_array(uart)(UART_VIN_H_RANGE) <= std_logic_vector(vin_tmp(27 downto 24)); 
                            uarts_calc_array(uart)(UART_VOUT_RANGE)  <= std_logic_vector(vout_tmp(27 downto 16)); 
                            uarts_calc_array(uart)(UART_IIN_L_RANGE) <= std_logic_vector(iin_tmp(23 downto 16));
                            uarts_calc_array(uart)(UART_IIN_H_RANGE) <= std_logic_vector(iin_tmp(27 downto 24));
                            uarts_calc_array(uart)(UART_IOUT_RANGE)  <= std_logic_vector(iout_tmp(27 downto 16));
                            uarts_calc_array(uart)(UART_OVP ) <= uarts_d_array(uart)(UART_OVP );
                            uarts_calc_array(uart)(UART_OCP ) <= uarts_d_array(uart)(UART_OCP );
                            uarts_calc_array(uart)(UART_OTP ) <= uarts_d_array(uart)(UART_OTP );
                            uarts_calc_array(uart)(UART_VINP) <= uarts_d_array(uart)(UART_VINP);
                        end if;
                        uarts_calc_vld(uart) <= uarts_d_ap_vld(uart);
                    end if;
                end if;
            end process;
        end generate main_board_gen;        
    end generate gen_calc;
    
end architecture RTL;
