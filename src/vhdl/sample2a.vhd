library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sample2a is
    port(
        clk          : in  std_logic;
        sync_rst     : in  std_logic;
        sample       : in  std_logic_vector(11 downto 0);
        sample_valid : in  std_logic;
        a            : out std_logic_vector(15 downto 0); -- 15:4 whole no. 3:0 fraction
        a_valid      : out std_logic
    );
end entity sample2a;

architecture RTL of sample2a is
    signal sample_s : signed(31 downto 0);
    signal a_int : signed(31 downto 0);
    signal mult : signed(63 downto 0);
    constant K : integer := integer(0.016117 * 2**16);
    constant N : integer := integer(33 * 2**16);
    signal valid : std_logic_vector(3 downto 0);
begin
    process(clk)
        variable a_var : std_logic_vector(31 downto 0);
    begin
        if rising_edge(clk) then
            if sync_rst then
                sample_s <= (others => '0');
                a_int <= (others => '0');
                mult <= (others => '0');
                valid <= (others => '0');
                a <= (others => '0');
            else
                sample_s <= signed("0000" & sample & X"0000");
                mult <= sample_s * K;
                a_int <= mult(31 downto 0) + N;
                a_var := std_logic_vector(a_int);
                a <= a_var(27 downto 12); -- 12bits.4bits
                valid <= sample_valid & valid(valid'left downto 1);
                
            end if;
        end if;
    end process;
    a_valid <= valid(0);
    
end architecture RTL;
