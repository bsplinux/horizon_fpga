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
    signal mult : signed(63 downto 0);
    constant A : integer := integer(0.108881 * 2**16);
    constant B : integer := integer(2047 * 2**16);
    signal valid : std_logic_vector(3 downto 0);
    signal dec : signed(31 downto 0);
begin
    process(clk)
        variable v_var : std_logic_vector(63 downto 0);
    begin
        if rising_edge(clk) then
            if sync_rst then
                sample_s <= (others => '0');
                dec <= (others => '0');
                mult <= (others => '0');
                valid <= (others => '0');
                v <= (others => '0');
            else
                sample_s <= signed(X"0" & sample & X"0000");
                dec <= sample_s - B;
                mult <= dec * A;
                v_var := std_logic_vector(mult);
                v <= v_var(43 downto 32);
                valid <= sample_valid & valid(valid'left downto 1);
                
            end if;
        end if;
    end process;
    v_valid <= valid(0);
    
end architecture RTL;
