library ieee;
use ieee.std_logic_1164.all;

entity syncronizer is 
	generic(
		NUM_FFS : positive := 2;
		USE_SRL : string := "no"
	);
	port(
		src 		: in  std_logic;
		dst 		: out std_logic;
		dst_clk 	: in  std_logic
	);
end entity syncronizer;

architecture struct of syncronizer is
	signal cdc_ffs : std_logic_vector(NUM_FFS - 1 downto 0);

	-- for Vivado attribute documentation look in ug901
	attribute ASYNC_REG : string;
	attribute ASYNC_REG of cdc_ffs : signal is "true";--this prevents optimization (like retiming etc)

	attribute SHREG_EXTRACT : string;
	attribute SHREG_EXTRACT of cdc_ffs : signal is USE_SRL;--there is no official guide of what is better, regular FFS or SRL FFS.
	-- the srl_style attribute only apples if SHREG_EXTRACT=yes else ignored
	attribute srl_style : string;
	attribute srl_style of cdc_ffs : signal is "srl";-- "srl" = all ffs are in srl and not using regular FFs
	--NOTE: to allow maximum settling time for metastability, override create_clock with set_max_delay between these FFs. 
	-- something like:
	--           set_max_delay -from [get_cells -hier *cdc_ffs_reg[*]] -to [get_cells -hier *cdc_ffs_reg[*]] 0.5
begin
	sync_pr: process(dst_clk) is
	begin
		if rising_edge(dst_clk) then
			cdc_ffs <= src & cdc_ffs(cdc_ffs'left downto 1);
		end if;
	end process;
	dst <= cdc_ffs(0);
end architecture struct;