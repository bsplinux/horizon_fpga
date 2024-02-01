library ieee;
use ieee.std_logic_1164.all;

package sim_pkg is
	function sim_on return boolean;
	function set_const(val1 : integer; val2 : integer; first : boolean) return integer;
	function set_const(val1 : std_logic_vector; val2 : std_logic_vector; first : boolean) return std_logic_vector;
	function set_const(val1 : string; val2 : string; first : boolean) return string;
	function set_const(val1 : boolean; val2 : boolean; first : boolean) return boolean;
end;

package body sim_pkg is
	function sim_on return boolean is
		variable sim : boolean := false;--this is the default any how
	begin
		-- synopsys translate_off
		sim := true;
		-- synopsys translate_on
		return sim;
	end;
	
	function set_const(val1 : integer; val2 : integer; first : boolean) return integer is
	begin
		if first then
			return val1;
		else
			return val2;
		end if;
	end;

	function set_const(val1 : std_logic_vector; val2 : std_logic_vector; first : boolean) return std_logic_vector is
	begin
		if first then
			return val1;
		else
			return val2;
		end if;
	end;

	function set_const(val1 : string; val2 : string; first : boolean) return string is
	begin
		if first then
			return val1;
		else
			return val2;
		end if;
	end;

	function set_const(val1 : boolean; val2 : boolean; first : boolean) return boolean is
	begin
		if first then
			return val1;
		else
			return val2;
		end if;
	end;

end;
