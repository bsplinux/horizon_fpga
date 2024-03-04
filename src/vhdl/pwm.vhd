library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm is
    generic (SIZE : integer := 32);
    port(
        clk : in std_logic;
        rst : in std_logic;
        low : in std_logic_vector(SIZE - 1 downto 0);
        high : in std_logic_vector(SIZE - 1 downto 0);
        start_high : in std_logic;
        active : in std_logic;
        pwm : out std_logic
    );
end entity pwm;

architecture RTL of pwm is
    type state_t is (idle, s_low, s_high);
    signal state : state_t;
    signal cnt : unsigned(SIZE - 1 downto 0);
begin
    process(clk)
        
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state <= idle;
                pwm <= '0';
                cnt <= (0 => '1', others => '0');
            else
                case state is 
                when idle => 
                    pwm <= start_high;
                    cnt <= (0 => '1', others => '0');
                    if active = '1' then
                        if start_high = '1' then
                            state <= s_high;
                        else
                            state <= s_low;
                        end if;
                    end if;
                when s_low =>
                    pwm <= '0';
                    if active = '0' then
                        state <= idle;
                    elsif cnt < unsigned(low) then
                        cnt <= cnt + 1;
                    else
                        cnt <= (0 => '1', others => '0');
                        state <= s_high;
                    end if;
                when s_high =>
                    pwm <= '1';
                    if active = '0' then
                        state <= idle;
                    elsif cnt < unsigned(high) then
                        cnt <= cnt + 1;
                    else
                        cnt <= (0 => '1', others => '0');
                        state <= s_low;
                    end if;
                end case;
            end if;
        end if;
    end process;
    
end architecture RTL;
