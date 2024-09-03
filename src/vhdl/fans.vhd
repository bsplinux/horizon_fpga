library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.condor_pl_pkg.all;
--use work.sim_pkg.all;
use work.regs_pkg.all;

entity fans is
    port(
        clk              : in  std_logic;
        sync_rst         : in  std_logic;
        registers        : in  reg_array_t;
        --regs_updating    : in  reg_slv_array_t;
        --regs_reading     : in  reg_slv_array_t;
        --internal_regs    : out reg_array_t;
        --internal_regs_we : out reg_slv_array_t;
        fans_en          : in  std_logic;
        fans_ok          : out std_logic;
        fan_pwm          : out std_logic_vector(1 to 3);
        rpm1             : out std_logic_vector(15 downto 0);
        rpm2             : out std_logic_vector(15 downto 0);
        rpm3             : out std_logic_vector(15 downto 0)
        );
end entity fans;

architecture RTL of fans is
    signal fans_in : std_logic_vector(1 to 3);
    signal active, start_high : std_logic_vector(1 to 3);
    signal low1, low2, low3 : std_logic_vector(31 downto 0);
    signal high1, high2, high3 : std_logic_vector(31 downto 0);
    
    constant CONST_LOW  : std_logic_vector(31 downto 0) := X"0000D904"; -- 900 Hz @ 100MHz clock, half a period [10^8/900/2 = 55,556]
    constant CONST_HIGH : std_logic_vector(31 downto 0) := CONST_LOW;
    
    constant FAN_RATING   : std_logic_vector(15 downto 0) := X"55F0"; -- 22,000 
    constant FAN_SET_POINT: std_logic_vector(15 downto 0) := X"44C0"; -- 80% - 17600
    constant HIGH_LIMIT   : std_logic_vector(15 downto 0) := X"490C"; -- 85% - 18700
    constant LOW_LIMIT    : std_logic_vector(15 downto 0) := X"4074"; -- 75% - 16500
    
begin
    fans_in(1) <= registers(IO_IN)(IO_IN_FAN_HALL1_FPGA);
    fans_in(2) <= registers(IO_IN)(IO_IN_FAN_HALL2_FPGA);
    fans_in(3) <= registers(IO_IN)(IO_IN_FAN_HALL3_FPGA);
    
    limit_pr: process(clk)
    begin
        if rising_edge(clk) then
            fans_ok <= '0';
            if rpm1 > LOW_LIMIT  and rpm1 < HIGH_LIMIT and 
               rpm2 > LOW_LIMIT  and rpm2 < HIGH_LIMIT and  
               rpm3 > LOW_LIMIT  and rpm3 < HIGH_LIMIT then
               fans_ok <= '1';
           end if;
           if registers(GENERAL_CONTROL)(GENERAL_CONTROL_FAN_CHECK) = '0' then
               fans_ok <= fans_en;
            end if;
        end if;
    end process;
        
    process(clk)
    begin
        if rising_edge(clk) then
            if sync_rst then
                active <= "000";
                start_high <= "000";
                low1 <= (others => '0');
                low2 <= (others => '0');
                low3 <= (others => '0');
                high1 <= (others => '0');
                high2 <= (others => '0');
                high3 <= (others => '0');
            else
                active(1) <= registers(PWM_CTL)(PWM_CTL_PWM1_ACTIVE) or fans_en;
                active(2) <= registers(PWM_CTL)(PWM_CTL_PWM2_ACTIVE) or fans_en;
                active(3) <= registers(PWM_CTL)(PWM_CTL_PWM3_ACTIVE) or fans_en;
                start_high(1) <= registers(PWM_CTL)(PWM_CTL_PWM1_START_HIGH);
                start_high(2) <= registers(PWM_CTL)(PWM_CTL_PWM2_START_HIGH);
                start_high(3) <= registers(PWM_CTL)(PWM_CTL_PWM3_START_HIGH);
                
                if registers(PWM_CTL)(PWM_CTL_PWM1_ACTIVE) then
                    low1  <= registers(PWM1_LOW);
                    high1 <= registers(PWM1_HIGH);
                else
                    low1 <= CONST_LOW;
                    high1 <= CONST_HIGH;
                end if;
                
                if registers(PWM_CTL)(PWM_CTL_PWM2_ACTIVE) then
                    low2  <= registers(PWM2_LOW);
                    high2 <= registers(PWM2_HIGH);
                else
                    low2 <= CONST_LOW;
                    high2 <= CONST_HIGH;
                end if;
                
                if registers(PWM_CTL)(PWM_CTL_PWM3_ACTIVE) then
                    low3  <= registers(PWM3_LOW);
                    high3 <= registers(PWM3_HIGH);
                else
                    low3 <= CONST_LOW;
                    high3 <= CONST_HIGH;
                end if;
                
            end if;
        end if;
    end process;
    
    -- FAN PWM
    fan1_pwm: entity work.pwm
    generic map(
        SIZE => 32
    )
    port map(
        clk        => clk,
        rst        => sync_rst,
        low        => low1,
        high       => high1,
        start_high => start_high(1),
        active     => active(1),
        pwm        => fan_pwm(1)
    );
    
    fan2_pwm: entity work.pwm
    generic map(
        SIZE => 32
    )
    port map(
        clk        => clk,
        rst        => sync_rst,
        low        => low2, 
        high       => high2,
        start_high => start_high(2),
        active     => active(2),
        pwm        => fan_pwm(2)
    );
    
    fan3_pwm: entity work.pwm
    generic map(
        SIZE => 32
    )
    port map(
        clk        => clk,
        rst        => sync_rst,
        low        => low3, 
        high       => high3,
        start_high => start_high(3),
        active     => active(3),
        pwm        => fan_pwm(3)
    );

    rpm_cnt1: entity work.rpm_cnt
    port map(
        clk      => clk,
        sync_rst => sync_rst,
        sig      => fans_in(1),
        rpm      => rpm1
    );
    
    rpm_cnt2: entity work.rpm_cnt
    port map(
        clk      => clk,
        sync_rst => sync_rst,
        sig      => fans_in(2),
        rpm      => rpm2
    );
    
    rpm_cnt3: entity work.rpm_cnt
    port map(
        clk      => clk,
        sync_rst => sync_rst,
        sig      => fans_in(3),
        rpm      => rpm3
    );
    
end architecture RTL;
