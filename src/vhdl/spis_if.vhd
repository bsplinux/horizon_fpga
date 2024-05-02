library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.condor_pl_pkg.all;
use work.sim_pkg.all;
use work.regs_pkg.all;

entity spis_if is
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
        zero_cross       : out std_logic
    );
end entity spis_if;

architecture RTL of spis_if is
    COMPONENT spis_0
    PORT (
        spis_d_0_ap_vld : OUT STD_LOGIC;
        spis_d_1_ap_vld : OUT STD_LOGIC;
        spis_d_2_ap_vld : OUT STD_LOGIC;
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
        spi_en : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        spis_d_0 : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
        spis_d_1 : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
        spis_d_2 : OUT STD_LOGIC_VECTOR(127 DOWNTO 0)
    );
    END COMPONENT;
    
    COMPONENT rms_0
    PORT (
        sample_ap_vld : IN STD_LOGIC;
        d_out_ap_vld : OUT STD_LOGIC;
        ap_clk : IN STD_LOGIC;
        ap_rst : IN STD_LOGIC;
        sample : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
        n : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        zero_cross : IN STD_LOGIC;
        d_out : OUT STD_LOGIC_VECTOR(11 DOWNTO 0) 
    );
    END COMPONENT;

    signal spis_d_0_ap_vld : STD_LOGIC;
    signal spis_d_1_ap_vld : STD_LOGIC;
    signal spis_d_2_ap_vld : STD_LOGIC;
    signal hls_rstn : STD_LOGIC;
    signal ap_start : STD_LOGIC;
    signal ap_done : STD_LOGIC;
    signal ap_idle : STD_LOGIC;
    signal ap_ready : STD_LOGIC;
    signal spis_d_0 : STD_LOGIC_VECTOR(127 DOWNTO 0);
    signal spis_d_1 : STD_LOGIC_VECTOR(127 DOWNTO 0);
    signal spis_d_2 : STD_LOGIC_VECTOR(127 DOWNTO 0);
    signal one100_us_error : std_logic;
    signal one100_us_tick: std_logic;
    
    signal zero_cross_error : std_logic;
    signal n : std_logic_vector(7 downto 0);
    
    signal d_out0_ap_vld : STD_LOGIC;
    signal d_out0 : STD_LOGIC_VECTOR(11 DOWNTO 0);
    signal d_out1_ap_vld : STD_LOGIC;
    signal d_out1 : STD_LOGIC_VECTOR(11 DOWNTO 0);
    signal d_out2_ap_vld : STD_LOGIC;
    signal d_out2 : STD_LOGIC_VECTOR(11 DOWNTO 0);
begin
    us100_tick_pr: process(clk)
        constant CLKS_IN_100US : integer := set_const(2,10000,sim_on);-- 2 clocks for simulation using 100 khz clock and 10,000 clocks 100 us for real world using 100MHz clock
        variable cnt : integer range 0 to CLKS_IN_100US := 1;
        variable tick : std_logic;
    begin
        if rising_edge(clk) then
            if sync_rst = '1' then
                cnt := CLKS_IN_100US;
                tick := '0';
                one100_us_tick <= '0';
            else
                tick := '0';
                cnt := cnt - 1;
                if cnt = 0 then
                    cnt := CLKS_IN_100US;
                    tick := '1';
                end if;
                
                one100_us_tick <= tick;
            end if;
        end if;
    end process;

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
                one100_us_error <= '0';
            else
                allow_hls := false;
                if registers(SPIS_CONTROL)(SPIS_CONTROL_EN_RANGE) /= "000" then
                    allow_hls := true;
                end if;
                
                --next state logic
                case state is 
                when idle =>
                    if one100_us_tick = '1' and allow_hls then
                        state := wt_rdy;
                    end if;
                when wt_rdy =>
                    if ap_done or one100_us_tick then
                        state := idle;
                    elsif ap_ready then
                        state := wt_done;
                    end if;
                when wt_done =>
                    if ap_done or one100_us_tick then
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
                    if one100_us_tick = '1' then
                        one100_us_error <= '1';
                    end if;
                when wt_done =>
                    if one100_us_tick = '1' then
                        one100_us_error <= '1';
                    end if;
                end case;
                
                if registers(SPIS_CONTROL)(SPIS_CONTROL_100US_ERR_CLR) and regs_updating(SPIS_CONTROL) then
                    one100_us_error <= '0';
                end if;
            
            end if;
        end if;
    end process;

    rst_pr: process(clk)
    begin
        if rising_edge(clk) then
            if sync_rst then
                hls_rstn <= '0';
            else
                hls_rstn <= '1';
                if sync_rst = '1' or (registers(SPIS_CONTROL)(SPIS_CONTROL_RST) = '1' and regs_updating(SPIS_CONTROL) = '1') then
                    hls_rstn <= '0';
                end if;                
            end if;
        end if;
    end process;
    
    rgs_wr_pr: process(all)
    begin
        internal_regs_we <= (others => '0');
        internal_regs <= (others => X"00000000");
        
        internal_regs_we(SPI_RAW0_BA) <= spis_d_0_ap_vld;
        internal_regs_we(SPI_RAW0_DC) <= spis_d_0_ap_vld;
        internal_regs_we(SPI_RAW1_BA) <= spis_d_1_ap_vld;
        internal_regs_we(SPI_RAW1_DC) <= spis_d_1_ap_vld;
        internal_regs_we(SPI_RAW2_BA) <= spis_d_2_ap_vld;
        internal_regs_we(SPI_RAW2_DC) <= spis_d_2_ap_vld;
        internal_regs_we(SPI_RAW2_FE) <= spis_d_2_ap_vld;
        internal_regs_we(SPI_RAW2_HG) <= spis_d_2_ap_vld;

        internal_regs(SPI_RAW0_BA) <= spis_d_0( 31 downto  0);
        internal_regs(SPI_RAW0_DC) <= spis_d_0( 63 downto 32);
        internal_regs(SPI_RAW1_BA) <= spis_d_1( 31 downto  0);
        internal_regs(SPI_RAW1_DC) <= spis_d_1( 63 downto 32);
        internal_regs(SPI_RAW2_BA) <= spis_d_2( 31 downto  0);
        internal_regs(SPI_RAW2_DC) <= spis_d_2( 63 downto 32);
        internal_regs(SPI_RAW2_FE) <= spis_d_2( 95 downto 64);
        internal_regs(SPI_RAW2_HG) <= spis_d_2(127 downto 96);
        
        internal_regs_we(SPIS_STATUS) <= '1';
        internal_regs(SPIS_STATUS)(SPIS_STATUS_BUSY) <= not ap_idle;
        internal_regs(SPIS_STATUS)(SPIS_STATUS_100US_ERR) <= one100_us_error;
        
        internal_regs_we(VSNS_PH1) <= d_out0_ap_vld;
        internal_regs_we(VSNS_PH2) <= d_out1_ap_vld;
        internal_regs_we(VSNS_PH3) <= d_out2_ap_vld;
        internal_regs(VSNS_PH1)(VSNS_PH_V) <= d_out0;
        internal_regs(VSNS_PH2)(VSNS_PH_V) <= d_out1;
        internal_regs(VSNS_PH3)(VSNS_PH_V) <= d_out2;
        
    end process;
    
    gen_hls: if HLS_EN generate
    begin
    
        hls_i:  spis_0
        port map(
            spis_d_0_ap_vld    => spis_d_0_ap_vld,
            spis_d_1_ap_vld    => spis_d_1_ap_vld,
            spis_d_2_ap_vld    => spis_d_2_ap_vld,
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
            spi_en             => registers(SPIS_CONTROL)(SPIS_CONTROL_EN_RANGE),
            spis_d_0           => spis_d_0, -- has 4 chans
            spis_d_1           => spis_d_1, -- has 4 chans
            spis_d_2           => spis_d_2  -- has 8 chans
        );
    
        zero_cross_i: entity work.zero_cross
        port map(
            clk              => clk,
            sync_rst         => sync_rst,
            d                => spis_d_2(27 downto 16),
            d_valid          => spis_d_2_ap_vld,
            zero_cross       => zero_cross,
            zero_cross_error => zero_cross_error,
            n                => n
        );
        
        rms_i0: rms_0
        port map(
            sample_ap_vld => spis_d_2_ap_vld,
            d_out_ap_vld  => d_out0_ap_vld,
            ap_clk        => clk,
            ap_rst        => sync_rst,
            sample        => spis_d_2(27 downto 16),
            n             => n,
            zero_cross    => zero_cross,
            d_out         => d_out0
        );
        
        rms_i1: rms_0
        port map(
            sample_ap_vld => spis_d_2_ap_vld,
            d_out_ap_vld  => d_out1_ap_vld,
            ap_clk        => clk,
            ap_rst        => sync_rst,
            sample        => spis_d_2(43 downto 32),
            n             => n,
            zero_cross    => zero_cross,
            d_out         => d_out1
        );
        
        rms_i2: rms_0
        port map(
            sample_ap_vld => spis_d_2_ap_vld,
            d_out_ap_vld  => d_out2_ap_vld,
            ap_clk        => clk,
            ap_rst        => sync_rst,
            sample        => spis_d_2(59 downto 48),
            n             => n,
            zero_cross    => zero_cross,
            d_out         => d_out2
        );
        
        
            
    else generate
        
    end generate gen_hls;
    
end architecture RTL;
