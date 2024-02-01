library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

use work.regs_pkg.all;

entity adr_decode is
	generic	(
		A_SIZE : integer := 8;
		-- constant values for logic minimization
		readable      : in  reg_slv_array_t; 
		writable      : in  reg_slv_array_t  
	);
	port (
		-- bus side ports
		d_val         : out STD_LOGIC;
	    d_out         : out STD_LOGIC_VECTOR(REG_WIDTH - 1 downto 0);
	    re            : in  STD_LOGIC := '1';
	    we            : in  STD_LOGIC_VECTOR(3 downto 0);  -- if byte_enables are not used, you can use only bit 0 and leave other bits const 0.
	    d_in          : in  STD_LOGIC_VECTOR(REG_WIDTH - 1 downto 0);
	    a             : in  STD_LOGIC_VECTOR(A_SIZE - 1 downto 0);
	    -- reg side ports
		regs_out      : out reg_array_t;
		regs_in       : in  reg_array_t;
		regs_we       : out reg_slv_array_t;
		regs_we_be	  : out STD_LOGIC_VECTOR(3 downto 0);  -- if byte_enables are not used, can leave this unconnected
		reading		  : out reg_slv_array_t -- indication that a valid read transaction is taking place (can be used for auto increment read trasactions from fifos or COR[ClearOnRead])
	);
end adr_decode;

architecture arc of adr_decode is
	constant zero : std_logic_vector := "0000";
	signal reg : regs_names_t;
begin
	--assert (to_integer(unsigned(a)) < REGS_SPACE_SIZE) report "Error Address out of scope" severity error;
	reg <= regs_a(to_integer(unsigned(a))) when to_integer(unsigned(a)) < REGS_SPACE_SIZE else NO_REG;
	
	regs_out_process: process(we, d_in, reg)
	begin		
		regs_out <= (others => (others => '0'));
		regs_we <= (others => '0');
		regs_we_be <= (others => '0');
		if (we /= zero  and  (writable(reg) = '1')) then
			regs_out(reg) <= d_in;
			regs_we(reg) <= '1';
			regs_we_be <= we;			
		end if;
	end process;	   

	d_val <= re;	
	d_out <= regs_in(reg) when readable(reg) = '1' else (others => '-');
	
	reading_sig_pr: process(reg, we) 
	begin
		reading <= (others => '0');
		if we = zero and readable(reg) = '1' then
			reading(reg) <= '1';
		end if;
	end process;
		
end arc;