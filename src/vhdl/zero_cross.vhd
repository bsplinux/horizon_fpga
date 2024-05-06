library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.numeric_std_unsigned.all;

entity zero_cross is
    generic(
        D_SIZE : integer := 12;  
        N_SIZE : integer := 8;
        MID  : std_logic_vector(D_SIZE - 1 downto 0) := (D_SIZE-1 => '1', others => '0')
    );
    port(
        clk              : in  std_logic;
        sync_rst         : in  std_logic;
        d                : in  std_logic_vector(D_SIZE - 1 downto 0);
        d_valid          : in  std_logic;
        zero_cross       : out std_logic;
        zero_cross_error : out std_logic;
        n                : out std_logic_vector(N_SIZE - 1 downto 0)
    );
end entity zero_cross;

architecture RTL of zero_cross is
begin
        zero_cross_sm_pr: process(clk)
            type zc_sm is (idle, wt_pos, positive, zc, zc_err);
            variable state : zc_sm;
            variable v : std_logic_vector(D_SIZE - 1 downto 0);
            variable cnt : integer range 0 to 2**N_SIZE - 1 := 0;
            constant CNT_MIN : integer := 17;
            constant CNT_MAX : integer := 30;
        begin
            if rising_edge(clk) then
                if sync_rst then
                    zero_cross <= '0';
                    zero_cross_error <= '0';
                    state := idle;
                    cnt := 0;
                    n <= (others => '0');
                else
                    if d_valid = '1' then  -- sm operates every time we have a new sample
                        v := d; 
                        
                        -- next state logic
                        case state is 
                            when idle =>
                                state := wt_pos;
                            when wt_pos =>
                                if cnt >= CNT_MIN - 1 and v > MID then
                                    state := positive;
                                elsif cnt >= CNT_MAX - 1 then
                                    state := zc_err;
                                end if;
                            when positive =>
                                if v <= MID then
                                    state := zc;
                                elsif CNT >= CNT_MAX - 1 then
                                    state := zc_err;
                                end if;
                            when zc =>
                                state := idle;
                            when zc_err =>
                                state := idle;
                        end case;
                        
                        -- output logic
                        zero_cross <= '0';
                        zero_cross_error <= '0';
                        cnt := cnt + 1;
                        case state is 
                            when idle =>
                                cnt := 0;
                            when zc =>
                                zero_cross <= '1';
                                n <= std_logic_vector(to_unsigned(cnt,n'length));
                            when zc_err =>
                                zero_cross <= '1';
                                zero_cross_error <= '1';
                                n <= std_logic_vector(to_unsigned(cnt,n'length));
                            when others =>
                                null;
                        end case;
                    end if;
                end if;
            end if;
        end process;
            
end architecture RTL;
