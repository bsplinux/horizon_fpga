library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity sample2v_tb is
end entity sample2v_tb;

architecture RTL of sample2v_tb is
    signal clk: std_logic := '0';
    signal sync_rst : std_logic;
    
    signal sample_v : std_logic_vector(11 downto 0);
    signal sample_v_valid : std_logic;
    signal v : std_logic_vector(11 downto 0);
    signal v_valid : std_logic;
    signal sample_a : std_logic_vector(11 downto 0);
    signal sample_a_valid : std_logic;
    signal a : std_logic_vector(15 downto 0);
    signal a_valid : std_logic;
    signal sample : std_logic_vector(11 downto 0);
    signal sample_valid: std_logic;
        
    procedure tick(ticks: integer := 1) is
    begin
        for i in 1 to ticks loop
            wait until rising_edge(clk);        
        end loop;
        wait for 1 ns;
    end;
    COMPONENT rms_0
    PORT (
        sample_ap_vld : IN STD_LOGIC;
        d_out_ap_vld : OUT STD_LOGIC;
        ap_clk : IN STD_LOGIC;
        ap_rst : IN STD_LOGIC;
        sample : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        n : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        zero_cross : IN STD_LOGIC;
        zero_cross_ap_ack : out std_logic;
        zero_cross_ap_vld : in std_logic;
        d_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) 
    );
    END COMPONENT;

    signal d_out_ap_vld : STD_LOGIC;
    signal n : STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal zero_cross : STD_LOGIC;
    signal d_out : STD_LOGIC_VECTOR(15 DOWNTO 0);
    signal zero_cross_error : std_logic;
    signal stop_clk : boolean;
    signal zero_cross_ap_ack : std_logic;
    signal zero_cross_ap_vld : std_logic;
    signal z_cross : std_logic;
begin
    sync_rst <= '1', '0' after 300 ns;
    clk <= not clk after 5 ns when not stop_clk;
    
    sample2v_uut: entity work.sample2v
    port map(
        clk          => clk,
        sync_rst     => sync_rst,
        sample       => sample_v,
        sample_valid => sample_v_valid,
        v            => v,
        v_valid      => v_valid
    );
    
    sample2a_uut: entity work.sample2a
    port map(
        clk          => clk,
        sync_rst     => sync_rst,
        sample       => sample_a,
        sample_valid => sample_a_valid,
        a            => a,
        a_valid      => a_valid
    );
    
    sample_a <= sample;
    sample_v <= sample;
    sample_a_valid <= sample_valid;
    sample_v_valid <= sample_valid;

    process
    begin
        sample <= X"FFF";    
        sample_valid <= '0';
        
        if sync_rst /= '0' then
            wait until sync_rst = '0';
        end if;
        
        /*for i in 0 to 10 loop
            tick(10);
            sample <= sample + 1;    
            sample_valid <= '1';
            tick;
            sample_valid <= '0';
        end loop;*/            
        
        -- 10 cycles of 25 samples each going up and down crossing zero
        for x in 0 to 10 loop
            sample <= X"700";    
            for i in 0 to 12 loop
                tick(10);
                sample <= sample + 35;    
                sample_valid <= '1';
                tick;
                sample_valid <= '0';
            end loop;            
            
            for i in 0 to 12 loop
                tick(10);
                sample <= sample - 35;    
                sample_valid <= '1';
                tick;
                sample_valid <= '0';
            end loop;            
        end loop;
        
        tick(100);
        stop_clk <= true;
        wait;
    end process;
    
    rms_a_uut: rms_0
    port map(
        sample_ap_vld => v_valid,
        d_out_ap_vld  => d_out_ap_vld,
        ap_clk        => clk,
        ap_rst        => sync_rst,
        sample        => X"0" & v,
        n             => n,
        zero_cross    => zero_cross,
        zero_cross_ap_ack => zero_cross_ap_ack,
        zero_cross_ap_vld => zero_cross_ap_vld,
        d_out         => d_out
    );
    
    zero_cross_inst : entity work.zero_cross
    port map(
        clk              => clk,
        sync_rst         => sync_rst,
        d                => v,
        d_valid          => v_valid,
        zero_cross       => z_cross,
        zero_cross_error => zero_cross_error,
        n                => n
    );
    process(clk)
        variable z_cross_s: std_logic;
    begin
        if rising_edge(clk) then
            if sync_rst then
                zero_cross <= '0';
                z_cross_s := '0';
                zero_cross_ap_vld <= '0';
            else
                if z_cross and not z_cross_s then
                    zero_cross <= '1';
                    zero_cross_ap_vld <= '1';
                elsif zero_cross_ap_ack then
                    zero_cross <= '0';
                end if;
                z_cross_s := z_cross;    
            end if;
        end if;                
    end process;
    
    
end architecture RTL;
