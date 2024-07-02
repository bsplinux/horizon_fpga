library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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
    
    signal uarts_d_0_ap_vld : STD_LOGIC;
    signal uarts_d_1_ap_vld : STD_LOGIC;
    signal uarts_d_2_ap_vld : STD_LOGIC;
    signal uarts_d_3_ap_vld : STD_LOGIC;
    signal uarts_d_4_ap_vld : STD_LOGIC;
    signal uarts_d_5_ap_vld : STD_LOGIC;
    signal uarts_d_6_ap_vld : STD_LOGIC;
    signal uarts_d_7_ap_vld : STD_LOGIC;
    signal uarts_d_8_ap_vld : STD_LOGIC;
    signal hls_rstn : STD_LOGIC;
    signal ap_start : STD_LOGIC;
    signal ap_done : STD_LOGIC;
    signal ap_idle : STD_LOGIC;
    signal ap_ready : STD_LOGIC;
    --signal uart_en : STD_LOGIC_VECTOR(8 DOWNTO 0);
    signal uarts_d_0 : STD_LOGIC_VECTOR(63 DOWNTO 0);
    signal uarts_d_1 : STD_LOGIC_VECTOR(63 DOWNTO 0);
    signal uarts_d_2 : STD_LOGIC_VECTOR(63 DOWNTO 0);
    signal uarts_d_3 : STD_LOGIC_VECTOR(63 DOWNTO 0);
    signal uarts_d_4 : STD_LOGIC_VECTOR(63 DOWNTO 0);
    signal uarts_d_5 : STD_LOGIC_VECTOR(63 DOWNTO 0);
    signal uarts_d_6 : STD_LOGIC_VECTOR(63 DOWNTO 0);
    signal uarts_d_7 : STD_LOGIC_VECTOR(63 DOWNTO 0);
    signal uarts_d_8 : STD_LOGIC_VECTOR(63 DOWNTO 0);
    signal uart_de : STD_LOGIC_VECTOR(8 DOWNTO 0);
    signal uart_de_ap_vld : STD_LOGIC;
    signal one_ms_error : std_logic;
    
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
                    if one_ms_interrupt = '1' and allow_hls then
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
                    null;
                when wt_rdy =>
                    ap_start <= '1';
                    if one_ms_interrupt = '1' then
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
        
        internal_regs_we(UART_RAW0_L) <= uarts_d_0_ap_vld;
        internal_regs_we(UART_RAW1_L) <= uarts_d_1_ap_vld;
        internal_regs_we(UART_RAW2_L) <= uarts_d_2_ap_vld;
        internal_regs_we(UART_RAW3_L) <= uarts_d_3_ap_vld;
        internal_regs_we(UART_RAW4_L) <= uarts_d_4_ap_vld;
        internal_regs_we(UART_RAW5_L) <= uarts_d_5_ap_vld;
        internal_regs_we(UART_RAW6_L) <= uarts_d_6_ap_vld;
        internal_regs_we(UART_RAW7_L) <= uarts_d_7_ap_vld;
        internal_regs_we(UART_RAW8_L) <= uarts_d_8_ap_vld;
        internal_regs_we(UART_RAW0_H) <= uarts_d_0_ap_vld;
        internal_regs_we(UART_RAW1_H) <= uarts_d_1_ap_vld;
        internal_regs_we(UART_RAW2_H) <= uarts_d_2_ap_vld;
        internal_regs_we(UART_RAW3_H) <= uarts_d_3_ap_vld;
        internal_regs_we(UART_RAW4_H) <= uarts_d_4_ap_vld;
        internal_regs_we(UART_RAW5_H) <= uarts_d_5_ap_vld;
        internal_regs_we(UART_RAW6_H) <= uarts_d_6_ap_vld;
        internal_regs_we(UART_RAW7_H) <= uarts_d_7_ap_vld;
        internal_regs_we(UART_RAW8_H) <= uarts_d_8_ap_vld;

        internal_regs(UART_RAW0_L) <= uarts_d_0(31 downto 0);
        internal_regs(UART_RAW1_L) <= uarts_d_1(31 downto 0);
        internal_regs(UART_RAW2_L) <= uarts_d_2(31 downto 0);
        internal_regs(UART_RAW3_L) <= uarts_d_3(31 downto 0);
        internal_regs(UART_RAW4_L) <= uarts_d_4(31 downto 0);
        internal_regs(UART_RAW5_L) <= uarts_d_5(31 downto 0);
        internal_regs(UART_RAW6_L) <= uarts_d_6(31 downto 0);
        internal_regs(UART_RAW7_L) <= uarts_d_7(31 downto 0);
        internal_regs(UART_RAW8_L) <= uarts_d_8(31 downto 0);
        internal_regs(UART_RAW0_H) <= uarts_d_0(63 downto 32);
        internal_regs(UART_RAW1_H) <= uarts_d_1(63 downto 32);
        internal_regs(UART_RAW2_H) <= uarts_d_2(63 downto 32);
        internal_regs(UART_RAW3_H) <= uarts_d_3(63 downto 32);
        internal_regs(UART_RAW4_H) <= uarts_d_4(63 downto 32);
        internal_regs(UART_RAW5_H) <= uarts_d_5(63 downto 32);
        internal_regs(UART_RAW6_H) <= uarts_d_6(63 downto 32);
        internal_regs(UART_RAW7_H) <= uarts_d_7(63 downto 32);
        internal_regs(UART_RAW8_H) <= uarts_d_8(63 downto 32);
        
        internal_regs_we(UARTS_STATUS) <= '1';
        internal_regs(UARTS_STATUS)(UARTS_STATUS_BUSY) <= not ap_idle;
        internal_regs(UARTS_STATUS)(UARTS_STATUS_MS1_ERR) <= one_ms_error;
        
    end process;
    
    gen_hls: if HLS_EN generate
    begin
    
        hls_i:  uarts_0
        port map(
            uarts_d_0_ap_vld   => uarts_d_0_ap_vld,
            uarts_d_1_ap_vld   => uarts_d_1_ap_vld,
            uarts_d_2_ap_vld   => uarts_d_2_ap_vld,
            uarts_d_3_ap_vld   => uarts_d_3_ap_vld,
            uarts_d_4_ap_vld   => uarts_d_4_ap_vld,
            uarts_d_5_ap_vld   => uarts_d_5_ap_vld,
            uarts_d_6_ap_vld   => uarts_d_6_ap_vld,
            uarts_d_7_ap_vld   => uarts_d_7_ap_vld,
            uarts_d_8_ap_vld   => uarts_d_8_ap_vld,
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
            uarts_d_0          => uarts_d_0,
            uarts_d_1          => uarts_d_1,
            uarts_d_2          => uarts_d_2,
            uarts_d_3          => uarts_d_3,
            uarts_d_4          => uarts_d_4,
            uarts_d_5          => uarts_d_5,
            uarts_d_6          => uarts_d_6,
            uarts_d_7          => uarts_d_7,
            uarts_d_8          => uarts_d_8,
            uart_de            => uart_de,
            uart_de_ap_vld     => uart_de_ap_vld
        );
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
    
end architecture RTL;
