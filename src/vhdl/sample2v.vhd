library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sample2v is
    port(
        clk          : in  std_logic;
        sync_rst     : in  std_logic;
        sample       : in  std_logic_vector(11 downto 0);
        sample_valid : in  std_logic;
        v            : out std_logic_vector(11 downto 0);
        v_valid      : out std_logic
    );
end entity sample2v;

architecture RTL of sample2v is
    signal sample_s : signed(31 downto 0);
    signal v_int : signed(31 downto 0);
    signal mult : signed(63 downto 0);
    constant A : integer := integer(0.119777 * 2**16);
    constant B : integer := integer(-223.14 * 2**16);
    signal valid : std_logic_vector(3 downto 0);
begin
    process(clk)
        variable v_var : std_logic_vector(31 downto 0);
    begin
        if rising_edge(clk) then
            if sync_rst then
                sample_s <= (others => '0');
                v_int <= (others => '0');
                mult <= (others => '0');
                valid <= (others => '0');
                v <= (others => '0');
            else
                sample_s <= signed(X"00000" & sample);
                mult <= sample_s * A;
                v_int <= mult(31 downto 0) + B;
                v_var := std_logic_vector(v_int);
                v <= v_var(27 downto 16);
                valid <= sample_valid & valid(valid'left downto 1);
                
            end if;
        end if;
    end process;
    v_valid <= valid(0);
    
end architecture RTL;
