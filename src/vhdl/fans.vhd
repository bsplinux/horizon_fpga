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
        fan_pwm          : out std_logic_vector(1 to 3)
        );
end entity fans;

architecture RTL of fans is
    
begin
    fans_ok <= fans_en;
    
    -- FAN PWM
    fan1_pwm: entity work.pwm
    generic map(
        SIZE => 32
    )
    port map(
        clk        => clk,
        rst        => sync_rst,
        low        => registers(PWM1_LOW),
        high       => registers(PWM1_LOW),
        start_high => registers(PWM_CTL)(PWM_CTL_PWM1_START_HIGH),
        active     => registers(PWM_CTL)(PWM_CTL_PWM1_ACTIVE),
        pwm        => fan_pwm(1)
    );
    
    fan2_pwm: entity work.pwm
    generic map(
        SIZE => 32
    )
    port map(
        clk        => clk,
        rst        => sync_rst,
        low        => registers(PWM2_LOW),
        high       => registers(PWM2_LOW),
        start_high => registers(PWM_CTL)(PWM_CTL_PWM2_START_HIGH),
        active     => registers(PWM_CTL)(PWM_CTL_PWM2_ACTIVE),
        pwm        => fan_pwm(2)
    );
    
    fan3_pwm: entity work.pwm
    generic map(
        SIZE => 32
    )
    port map(
        clk        => clk,
        rst        => sync_rst,
        low        => registers(PWM3_LOW),
        high       => registers(PWM3_LOW),
        start_high => registers(PWM_CTL)(PWM_CTL_PWM3_START_HIGH),
        active     => registers(PWM_CTL)(PWM_CTL_PWM3_ACTIVE),
        pwm        => fan_pwm(3)
    );

end architecture RTL;
