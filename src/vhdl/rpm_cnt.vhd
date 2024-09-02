library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rpm_cnt is
    port(
        clk      : in  std_logic;
        sync_rst : in  std_logic;
        sig      : in  std_logic;
        rpm      : out std_logic_vector(15 downto 0)
    );
end entity rpm_cnt;

architecture RTL of rpm_cnt is
    constant MINUTE : unsigned(32 downto 0) := '1' & X"65A0BC00"; -- 60 seconds @ 100MHz = 6,000,000,000 need 33 bits
begin
    process(clk)
        variable cnt : unsigned(32 downto 0);
        variable rpm_cnt : integer range 0 to 2**16 -1;
        variable sig_s : std_logic;
    begin
        if rising_edge(clk) then
            if sync_rst then
                cnt := (others => '0');
                rpm_cnt := 0;
                rpm <= (others => '0');
                sig_s := '0';
            else
                cnt := cnt + 1;
                if sig = '1' and sig_s = '0' then
                    rpm_cnt := rpm_cnt + 1;
                end if;

                if cnt = MINUTE then
                    rpm <= std_logic_vector(to_unsigned(rpm_cnt,16));
                    rpm_cnt := 0;
                    cnt := (others => '0');
                end if;
                sig_s := sig;
            end if;
        end if;
    end process;
    
end architecture RTL;
