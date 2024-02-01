library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all; -- @suppress "Deprecated package"
use STD.TEXTIO.all;
use ieee.std_logic_textio.all;

use work.regs_pkg.all;
 
entity regs32_fileio is
generic	(
	IN_FILE_NAME : string;
	OUT_FILE_NAME : string;
	PRINT_TIME : boolean := true;
	PRINT_CSV : boolean := false;
	WAIT_AFTER_EDGE : time := 1000 ps;
	PRINT_COMMAND : boolean := true
);
port (
    clk           : in  STD_LOGIC;
    rst	          : in  STD_LOGIC;
	regs_in  	  : in  reg_array_t;
	regs_out      : out reg_array_t;
	regs_we		  : out reg_slv_array_t;
	reading	  	  : out reg_slv_array_t
);
end regs32_fileio;

architecture arc of regs32_fileio is						 
-- regs32_fileio takes an input file and and generates stimulus to register, it also saves register reads into file
-- this is a simulation only block put inside an if generate block
-- input file format:
-- # = commnet line
-- > = command line
-- XXX = value line (can have multiple values in one line)
-- simulation will parse file and output next value on each clock edge + WAIT_AFTER_EDGE
-- available commands:
-- >exit = stop reading file
-- >wait for time = wait amount of time specified in 'time'	variable and then syncronize to clock edge
-- >wait on X = wait until trig(X) = 1 and then syncronize to clock edge
-- >freeze = next writes will not advance time (allow many writes in one clock cycle
-- >continue = stops freeze mode and advances one clock cycle
-- >stop = stops the simulation even if other stuff is still going on
-- w <address> <data> <optioanl more data> etc. = write command auto incrementing the addresses
-- wni <address> <data> <optinal more data> Write No Increment, all data will be written to same address
-- r <address> <cnt> at the moment only the reading port is affected, this is useful for COR (ClearOnRead) and fifo_rd auto increment, cnt is optional for re-reading the same address cnt times.

-- file example:

-- # this is the file header 
--
-- # privious line was skipped as it had no text
-- # this is the 3rd line of comments
-- 12345678
-- >wait for 10 ns
-- 7890abcd 00110011 a5A5a5A5
-- >wait on 1
-- 00000000 11111111 22222222 33333333
-- >exit
-- 44444444 55555555 66666666 77777777
-- # previous line and this line are not exicuted
-- # if next line is used simulation will stop regardless of other stuff going on in simulation
-- >stop
	signal current_cmd: string(1 to 1024 * 4) := (others =>' '); --@suppress it used for simulation to know what is the command

	function is_hex(s: string) return boolean is
	   variable ok : boolean;
	begin
	   for i in s'range loop
	       ok := false;
	       if s(i) >= '0' and s(i) <= '9' then
	           ok := true;
	       end if;
	       if s(i) >= 'A' and s(i) <= 'F' then
	           ok := true;
	       end if;
	       if s(i) >= 'a' and s(i) <= 'f' then
               ok := true;
           end if;
           if i > s'left and s(i) = '_' and i < s'right then
               ok := true;
           end if;
           if not ok then
               return false;
           end if;
	   end loop;
	   if s'length > 0 then
	       return true;
	   end if;
	end;
	
	procedure sread(l : inout line; value : out string; strlen : out natural) is
	   variable c : character;
	begin
        for i in value'range loop
            value(i) := ' ';
        end loop;
        strlen := 0;
	    while l'length >  0 loop
	       if strlen = 0 and (l(1) = ' ' or l(1) = HT) then
	           read(l,c);
           elsif strlen > 0 and (l(1) = ' ' or l(1) = HT) then
               exit;
	       else
	           read(l,c);
               strlen := strlen + 1;
	           value(strlen) := c;
	       end if;
	    end loop;
	end;
	
begin
	process
   		FILE input_file 	: text;-- open read_mode is IN_FILE_NAME;
	   	FILE output_file 	: text; --open write_mode is OUT_FILE_NAME;
   		variable w_l 		: line;
   		variable r_l 		: line;
		variable good 		: boolean;
		variable command    : string(1 to 5);
		variable command2   : string(1 to 3);
		variable c          : character;
		variable val        : std_logic_vector(full_reg_range);
		variable a			: std_logic_vector(full_reg_range);
		variable d			: std_logic_vector(full_reg_range);
		variable wait_val   : time;
		variable freeze	    : boolean;
		variable fstatus	: FILE_OPEN_STATUS;
		variable cnt        : integer;
		variable to_file_on	: boolean := false;
		variable out_file_name_csv : string(1 to OUT_FILE_NAME'length + 4);
		variable write_no_increment : boolean := false;
		variable reg_name : regs_names_t;
		variable reg_name_string : string(1 to 31) ;
		variable reg_name_size: integer; -- @suppress "variable reg_name_size is never read"
		variable reg_name_valid : boolean;
	begin
		-- initalize output
		regs_out <= (others => (others => '0'));
		regs_we <= (others => '0');
		reading <= (others => '0');
		-- try to open files
		
		--write(w_l,string'("testtttt\\n"));
		--writeline(output_file,w_l);
		FILE_OPEN(fstatus, input_file, IN_FILE_NAME, READ_MODE);
		if fstatus /= OPEN_OK then
			report "can't open input file" & IN_FILE_NAME;
			wait; -- stop simulation from file
		end if;
		
		if PRINT_CSV then
			out_file_name_csv := OUT_FILE_NAME & ".csv";
		else
			out_file_name_csv := OUT_FILE_NAME;
		end if;
		FILE_OPEN(fstatus, output_file, out_file_name_csv, WRITE_MODE);
		if fstatus /= OPEN_OK then
			report "can't open output file" & OUT_FILE_NAME;
		else 
			to_file_on := true;
		end if;
		
		-- wait for reset
		if rst /= '0' then
			wait until rst = '0';
		end if;
		wait until rising_edge(clk);
		wait for WAIT_AFTER_EDGE;
        
        -- parse file
	    while not endfile (input_file) loop
			-- execute line from file
			readline(input_file,r_l);
        	next when r_l'length = 0;--skip empty line
			current_cmd <= (others => ' ');
			current_cmd(1 to r_l'length) <= r_l.all;
			if PRINT_COMMAND then
				report "regs fileio:" & r_l.all;
			end if;
			next when (r_l(1) = '#');--skip comment line
			if (r_l(1) = '>') then   
				--read command line
				read(r_l,command ,good);
    	    	next when not good;
				-- exit command
				exit when (command(2) = 'e' and command(3) = 'x' and 
				    command(4) = 'i' and command(5) = 't');
				if (command(2) = 's' and command(3) = 't' and 
					command(4) = 'o' and command(5) = 'p') then
					assert false report "regs32_fileio is requesting to stop simulation, THIS IS NOT AN ERROR" severity failure;
				end if;
				-- wait command
				if (command(2) = 'w' and command(3) = 'a' and 
				    command(4) = 'i' and command(5) = 't') then
					read(r_l,command2,good);
					next when not good;
					-- wait for command
					if(command2(1) = ' ' and command2(2) = 'f' and command2(3) = 'o') then
						read(r_l,c,good);
						next when not good;
						if (c /= 'r') then
							next;
						end if;
						read(r_l,wait_val,good);
						next when not good;
						-- finish this cycle first and then wait
						wait until rising_edge(clk);
						wait for WAIT_AFTER_EDGE;
						wait for wait_val;
						wait until rising_edge(clk);
						wait for WAIT_AFTER_EDGE;
					end if;
					next;
				end if;
				if (command(2) = 'f' and command(3) = 'r' and command(4) = 'e' and 
					command(5) = 'e' 
					--and command(6) = 'z' and command(7) = 'e'
					) then
					freeze := true;
				end if;
				if (command(2) = 'c' and command(3) = 'o' and command(4) = 'n' and 
					command(5) = 't' 
					--and command(6) = 'i' and command(7) = 'n' and
					--command(8) = 'u' and command(9) = 'e'
					) then
					freeze := false;
					wait until rising_edge(clk);
					wait for WAIT_AFTER_EDGE;
					regs_we <= (others => '0');
					regs_out <= (others => (others => '0'));
					reading <= (others => '0');
				end if;
				next;
        	elsif (r_l(1) = 'w') then   
				read(r_l,c,good);
				next when not good;
				write_no_increment := false;
				if (r_l(1) = 'n' and r_l(2) = 'i') then
					write_no_increment := true;
					read(r_l,c,good);
					read(r_l,c,good);
				end if;	
				-- read address
                -- first check if a is given by name or value, first tring to read hex for address.
				if is_hex(r_l(1 to 8)) then
                    hread(r_l,a,good);
                    reg_name_valid := false;
                    reg_name := regs_a(to_integer(unsigned(a))/4);
                else
                    --read(r_l,reg_name_string);
                    sread(r_l,reg_name_string, reg_name_size);
                    reg_name := regs_names_t'value(reg_name_string(1 to reg_name_size));
                    --a := std_logic_vector(to_unsigned((regs_a(reg_name) * 4),32));
                    --report "register " & regs_names_t'image(reg_name);
                    reg_name_valid := true;
                end if;
                next when not good;
                cnt := 0;
                loop
					hread(r_l,val,good);
					exit when not good;
                    if not write_no_increment and reg_name_valid and cnt > 0 then
                        report "regs32_fileio: W auto increment is only supported for address access and not for name access (yet!!!)"; 
                        exit;                     
                    end if;

					regs_we(reg_name) <= '1';
					regs_out(reg_name) <= val;
					-- syncronize to clock
					if not freeze then
						wait until rising_edge(clk);
						wait for WAIT_AFTER_EDGE;
						regs_we <= (others => '0');
						regs_out <= (others => (others => '0'));
					end if;
					cnt := cnt + 1;
					if not write_no_increment then
						if not reg_name_valid then
						    a := a + 4;
						    reg_name := regs_a(to_integer(unsigned(a))/4);
					    end if;
					end if;
				end loop;
			elsif (r_l(1) = 'r') then
				read(r_l,c,good);
				next when not good;
				-- read one space
				read(r_l,c,good);
				next when not good;
				-- read address
				-- first check if a is given by name or value, first tring to read hex for address.
				--report "rl 1 to 8: " & r_l(1 to 8);
				if is_hex(r_l(1 to 8)) then
				    hread(r_l,a,good);
				    reg_name_valid := false;
				    reg_name := regs_a(to_integer(unsigned(a))/4);
				else
				    --read(r_l,reg_name_string);
				    sread(r_l,reg_name_string, reg_name_size);
				    reg_name := regs_names_t'value(reg_name_string(1 to reg_name_size));
				    --a := std_logic_vector(to_unsigned((regs_a(reg_name) * 4),32));
				    --report "register " & regs_names_t'image(reg_name);
				    reg_name_valid := true;
				end if;
				next when not good;
				
				-- read counter
				read(r_l,cnt,good);
				if not good then -- cnt was not provided reading only once
					cnt := 1;
				elsif reg_name_valid then
				    report "regs32_fileio: R auto increment is only supported for address access and not for name access (yet!!!), only one register will be read";
				    cnt := 1;
				end if;
				for read_cnt in 1 to cnt loop
					reading(reg_name) <= '1';
					if not freeze then
						wait until rising_edge(clk);
						wait for WAIT_AFTER_EDGE;
						reading <= (others => '0');
						wait until rising_edge(clk);
	                    wait for WAIT_AFTER_EDGE;
						if to_file_on then
							wait until rising_edge(clk);
		                    wait for WAIT_AFTER_EDGE;
							if PRINT_TIME then
								write(w_l,now);
								if PRINT_CSV then
									write(w_l,string'(","));
								else
									write(w_l,string'(" "));
								end if;
							end if;
                            if reg_name_valid then
                                write(w_l,string'("("));
                                write(w_l,regs_names_t'IMAGE(reg_name));
                                write(w_l,string'(")"));
							else
							    hwrite(w_l,a);
                            end if;
							if PRINT_CSV then
								write(w_l,string'(","));
							else
								write(w_l,string'(" = "));
							end if;
							d := regs_in(reg_name);
							hwrite(w_l,d);
							writeline(output_file,w_l);
                            if not reg_name_valid then
                                a := a + 4;
                                reg_name := regs_a(to_integer(unsigned(a))/4);
                            end if;
						end if;
					end if;
				end loop;
			end if;
		end loop;	 
		wait until rising_edge(clk);
		wait for WAIT_AFTER_EDGE;
		regs_we <= (others => '0');
		regs_out <= (others => (others => '0'));
		-- wait forever
		wait; 
	end process;
end arc;