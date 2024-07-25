library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi_power is
    port(
        clk          : in  std_logic;
        sync_rst     : in  std_logic;
        v1,v2,v3     : in  std_logic_vector(15 downto 0);
        i1,i2,i3     : in  std_logic_vector(15 downto 0);
        v_valid      : in std_logic_vector(1 to 3);
        i_valid      : in std_logic_vector(1 to 3);
        p            : out std_logic_vector(15 downto 0); -- 15:4 whole no. 3:0 fraction
        p_valid      : out std_logic
    );
end entity spi_power;

architecture RTL of spi_power is
    type state_t is (wt1, wt2, wt3,inc,div);
    signal i_valid_s, v_valid_s : std_logic_vector(1 to 3);
    signal v1_s,v2_s,v3_s     : signed(15 downto 0);
    signal i1_s,i2_s,i3_s     : signed(15 downto 0);
    signal clr                : std_logic_vector(1 to 3);
    signal state : state_t := wt1;
    signal p1, p2, p3: signed(31 downto 0);
    
begin
    process(clk)
        variable cnt : integer range 0 to 10;
        variable p_var : signed(63 downto 0);
        constant DIV2000 : integer := integer((1.0/(10.0*20.0*10.0)) * 2**16);
    begin
        if rising_edge(clk) then
            if sync_rst then
                state <= wt1;
                clr <= (others => '0');
                cnt := 0;
                p1 <= (others => '0');
                p2 <= (others => '0');
                p3 <= (others => '0');
                p <= (others => '0');
                p_valid <= '0';
                p_var := (others => '0');
            else
                -- next state logic
                clr <= (others => '0');
                p_valid <= '0';
                case state is 
                    when wt1 =>
                        if i_valid_s(1) and v_valid_s(1) then
                            state <= wt2;
                            clr(1) <= '1';
                            p1 <= p1 + (i1_s * v1_s);
                        end if;
                    when wt2 =>
                        if i_valid_s(2) and v_valid_s(2) then
                            state <= wt3;
                            clr(2) <= '1';
                            p2 <= p2 + (i2_s * v2_s);
                        end if;
                    when wt3 =>
                        if i_valid_s(3) and v_valid_s(3) then
                            state <= inc;
                            clr(3) <= '1';
                            p3 <= p3 + (i3_s * v3_s);
                        end if;
                    when inc =>
                        cnt := cnt + 1;
                        if cnt = 10 then
                            state <= div;
                        else
                            state <= wt1;
                        end if;
                    when div =>
                        cnt := 0;
                        p1 <= (others => '0');
                        p2 <= (others => '0');
                        p3 <= (others => '0');
                        state <= wt1;
                        p_valid <= '1';
                        p_var := resize(p1,64) + p2 + p3;
                        p_var := p_var(31 downto 0) * DIV2000;
                        p <= std_logic_vector(p_var(31 downto 16));
                end case;

            end if;
        end if;
    end process;
    
    process(clk)
    begin
        if rising_edge(clk) then
            if sync_rst = '1' then
                v1_s <= (others => '0');
                v2_s <= (others => '0');
                v3_s <= (others => '0');
                i1_s <= (others => '0');
                i2_s <= (others => '0');
                i3_s <= (others => '0');
                i_valid_s <= (others => '0');
                v_valid_s <= (others => '0');
            else
                if v_valid(1) then
                    v1_s <= signed(v1);
                    v_valid_s(1) <= '1';
                elsif clr(1) then
                    v_valid_s(1) <= '0';
                end if;
                
                if v_valid(2) then
                    v2_s <= signed(v2);
                    v_valid_s(2) <= '1';
                elsif clr(2) then
                    v_valid_s(2) <= '0';
                end if;
                
                if v_valid(3) then
                    v3_s <= signed(v3);
                    v_valid_s(3) <= '1';
                elsif clr(3) then
                    v_valid_s(3) <= '0';
                end if;
                
                if i_valid(1) then
                    i1_s <= signed(i1);
                    i_valid_s(1) <= '1';
                elsif clr(1) then
                    i_valid_s(1) <= '0';
                end if;
                
                if i_valid(2) then
                    i2_s <= signed(i2);
                    i_valid_s(2) <= '1';
                elsif clr(2) then
                    i_valid_s(2) <= '0';
                end if;
                
                if i_valid(3) then
                    i3_s <= signed(i3);
                    i_valid_s(3) <= '1';
                elsif clr(3) then
                    i_valid_s(3) <= '0';
                end if;
                
            end if;
        end if;
    end process;
    
end architecture RTL;
