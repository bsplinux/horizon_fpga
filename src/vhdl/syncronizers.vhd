library ieee;
use ieee.std_logic_1164.all;

entity syncronizers is 
	generic(
		SIZE 	: positive;
		NUM_FFS : positive := 2;
		USE_SRL : string := "no"
	);
	port(
		src 		: in  std_logic_vector(SIZE-1 downto 0);
		dst 		: out std_logic_vector(SIZE-1 downto 0);
		dst_clk 	: in  std_logic
	);
end entity syncronizers;

architecture struct of syncronizers is
begin
	loop_gen: for i in src'range generate
		sncrnzr: entity work.syncronizer
		generic map(
		    NUM_FFS => NUM_FFS  ,
		    USE_SRL => USE_SRL
		)
		port map(
			src 	=> src(i) 	,
		    dst 	=> dst(i) 	,
		    dst_clk => dst_clk
		);
	end generate loop_gen;
end architecture struct;