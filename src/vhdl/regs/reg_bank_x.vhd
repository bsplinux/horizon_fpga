library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.sim_pkg.all;
use work.regs_pkg.all;

use std.textio;
use ieee.std_logic_textio;

entity reg_bank_x is
generic	(
	NUM_REG_SETS : integer := 4;
	-- constant value for value of registers at reset
	REGS_INIT     		: in  reg_array_t;
	-- constant value for logic minimization
	WRITABLE      		: in  reg_array_t;
	-- for each register set what registers can be written
	REG_SET_WRITABLE	: in reg_slv_arrays_t(NUM_REG_SETS - 1 downto 0);  
	SIM_IN_FILE_NAME : string := "no_file";
	SIM_OUT_FILE_NAME : string := "no_file"
);
port (
    clk           : in  STD_LOGIC;
    async_rstn    : in  STD_LOGIC := '1';
	sync_rst      : in  STD_LOGIC := '0';
	regs_out      : out reg_array_t;
	regs_in       : in  reg_arrays_t(NUM_REG_SETS -1 downto 0);
	regs_we       : in  reg_slv_arrays_t(NUM_REG_SETS - 1 downto 0);
	updating      : out reg_slv_array_t;
	sim_reading	  : out reg_slv_array_t
);
end reg_bank_x;

architecture arc of reg_bank_x is
	constant reg0 : std_logic_vector(full_reg_range) := (others => '0');
	signal regs_we_sig  : reg_slv_array_t;
	signal regs_in_int : reg_array_t;
	signal regs_we_active : reg_slv_arrays_t(NUM_REG_SETS - 1 downto 0);
	signal sim_regs_we 			: reg_slv_array_t;
	signal sim_regs				: reg_array_t;
	signal regs_out_sig			: reg_array_t;
begin
	regs_we_active <= regs_we and REG_SET_WRITABLE;
	
	regs_in_pr: process(regs_in, regs_we_active, sim_regs, sim_regs_we)
	begin
		regs_in_int <= (others => reg0);
		for i in regs_names_t loop
			for k in 0 to NUM_REG_SETS - 1 loop
				if regs_we_active(k)(i) = '1' then
					regs_in_int(i) <= regs_in(k)(i);
				end if;
			end loop;
			if sim_on then
				if sim_regs_we(i) = '1' then
					regs_in_int(i) <= sim_regs(i);
				end if;
			end if;
		end loop;
    end process;
    
	-- OR between register sets for WE
	regs_we_pr: process(regs_we_active, sim_regs_we)
		variable regs_we_var : reg_slv_array_t;
    begin
        regs_we_var := (others => '0');
        for k in regs_we_active'range loop
			regs_we_var := regs_we_var or regs_we_active(k);
		end loop;
		if sim_on then
			regs_we_var := regs_we_var or sim_regs_we;
		end if;
		regs_we_sig <= regs_we_var;
    end process;
	
	reg_write_pr: process(clk, async_rstn)
	begin		
		if async_rstn = '0' then
			for i in REGS_INIT'range loop
				regs_out_sig(i) <= REGS_INIT(i);
			end loop;
			updating <= (others => '0');
		elsif rising_edge(clk) then	   
			if sync_rst = '1' then
				for i in REGS_INIT'range loop
					regs_out_sig(i) <= REGS_INIT(i);
				end loop;
				updating <= (others => '0');
			else
				updating <= (others => '0');
				for i in regs_we_sig'range loop
					if regs_we_sig(i) = '1' then
						for j in full_reg_range loop
							if WRITABLE(i)(j) = '1' then
								regs_out_sig(i)(j) <= regs_in_int(i)(j);
							end if;
						end loop;
						if WRITABLE(i) /= reg0 then
							updating(i) <= '1';
						end if;
					end if;										  
				end loop;
			end if;
		end if;
	end process;
	regs_out <= regs_out_sig;
	
	sim_gen: if sim_on generate
		regs_fileio_inst: entity work.regs32_fileio 
			generic map(-- @suppress "Generic map uses default values. Missing optional actuals: WAIT_AFTER_EDGE"
				IN_FILE_NAME    => SIM_IN_FILE_NAME,
				OUT_FILE_NAME   => SIM_OUT_FILE_NAME,
				PRINT_TIME		=> true,
				PRINT_CSV		=> false
			)
			port map(
				clk      => clk,
				rst      => sync_rst,
				regs_in  => regs_out_sig,
				regs_out => sim_regs,
				regs_we  => sim_regs_we,
				reading  => sim_reading
			);
	else generate 	
		sim_reading <= (others => '0');
	end generate sim_gen;
		  
end arc;