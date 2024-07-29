library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi_power_tb is
end entity;

architecture arc of spi_power_tb is
    signal clk : std_logic := '0';
    signal sync_rst : std_logic;
    signal v1 : signed(15 downto 0);
    signal v2 : signed(15 downto 0);
    signal v3 : signed(15 downto 0);
    signal i1 : signed(15 downto 0);
    signal i2 : signed(15 downto 0);
    signal i3 : signed(15 downto 0);
    signal v_valid1, v_valid2, v_valid3 : std_logic;
    signal i_valid1, i_valid2, i_valid3 : std_logic;
    signal p : std_logic_vector(15 downto 0);
    signal p_valid : std_logic;
    
    signal stop_clk: boolean;
    constant PRD : time := 10 ns;

    procedure tick(n : natural := 1) is
    begin
        for i in 1 to n loop
            wait until rising_edge(clk);
            wait for 1 ns;
        end loop;
    end procedure tick;
    
begin
    clk <= not clk after PRD/2 when not stop_clk else '0';
    sync_rst <= '1', '0' after 500 ns;
    
    uut: entity work.spi_power
    port map(
        clk      => clk,
        sync_rst => sync_rst,
        v1       => std_logic_vector(v1),
        v2       => std_logic_vector(v2),
        v3       => std_logic_vector(v3),
        i1       => std_logic_vector(i1),
        i2       => std_logic_vector(i2),
        i3       => std_logic_vector(i3),
        v_valid  => v_valid1 & v_valid2 & v_valid3,
        i_valid  => i_valid1 & i_valid2 & i_valid3,
        p        => p,
        p_valid  => p_valid
    );
    
    process
    begin
        v_valid1 <= '0';   
        v_valid2 <= '0';   
        v_valid3 <= '0';   
        i_valid1 <= '0';   
        i_valid2 <= '0';   
        i_valid3 <= '0';
        
        if sync_rst /= '1' then
            wait until sync_rst = '1';
        end if;
        wait until sync_rst = '0';
        tick;
       
        for i in 0 to 21 loop
            v_valid1 <= '1';
            tick;
            v_valid1 <= '0';
            tick(18);
            i_valid1 <= '1';
            tick;
            i_valid1 <= '0';
            tick(15);

            v_valid2 <= '1';
            tick;
            v_valid2 <= '0';
            tick(17);
            i_valid2 <= '1';
            tick;
            i_valid2 <= '0';
            tick(11);
            
            v_valid3 <= '1';
            tick;
            v_valid3 <= '0';
            tick(28);
            i_valid3 <= '1';
            tick;
            i_valid3 <= '0';
            tick(5);
            
        end loop;
        
        tick(10);
        
        tick(100);
        stop_clk <= true;
        wait;
    end process;

    v1 <= X"0010";
    v2 <= X"0010";
    v3 <= X"0010";
    i1 <= X"0010";
    i2 <= X"0010";
    i3 <= X"0010";
--    process
--    begin
--        v1 <= to_signed(-100,16);
--        v2 <= to_signed(100,16);
--        v3 <= (others => '0');
--        i1 <= to_signed(-50,16);
--        i2 <= to_signed(50,16);
--        i3 <= (others => '0');
--    
--        for i in 0 to 21 loop
--            tick(100);
--            v1 <= v1 + 17;
--            v2 <= v2 - 13;
--            v3 <= v3 + 11;
--            
--            i1 <= i1 + 5;
--            i2 <= i2 - 5;
--            i3 <= i3 + 2;
--        end loop;
--        
--        tick(100);
--        stop_clk <= true;    
--        wait;
--    end process;
    
end;
