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
    -- rpm calculation should be done about once a second
    -- so for simplicity we devide 60 seconds by 64 and calculate how many ticks in 1min/64 and then multiply by 64
    --constant MINUTE : unsigned(32 downto 0) := '1' & X"65A0BC00"; -- 60 seconds @ 100MHz = 6,000,000,000 need 33 bits
    constant SEC : integer := 93_750_000; -- 60 seconds / 64 @ 100MHz = 6,000,000,000/64 =  93,750,000
begin
    
    process(clk)
        variable cnt : integer range 0 to SEC;
        variable rpm_cnt : integer range 0 to 2**10 -1;
        variable sig_s : std_logic;
    begin
        if rising_edge(clk) then
            if sync_rst then
                cnt := 0;
                rpm_cnt := 0;
                rpm <= (others => '0');
                sig_s := '0';
            else
                cnt := cnt + 1;
                if cnt = SEC then
                    rpm <= std_logic_vector(to_unsigned(rpm_cnt,10)) & "000000"; -- effectivly rpm_cnt * 64
                    rpm_cnt := 0;
                    cnt := 0;
                end if;
                if sig = '1' and sig_s = '0' then
                    rpm_cnt := rpm_cnt + 1;
                end if;

                sig_s := sig;
            end if;
        end if;
    end process;
    
end architecture RTL;
