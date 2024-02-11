library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--use work.reg_array_pkg.all;
--use work.AXI_regs_pkg.all;

entity uart_if is
	generic (
		UART_A_SIZE : integer := 10
	);
	port (
		CLK			: in  std_logic;
		ASYNC_RST	: in  std_logic;
		USB_UART_RX		: in  std_logic;
		USB_UART_TX		: out std_logic;
		UART_WE          : out STD_LOGIC;
		UART_A           : out STD_LOGIC_VECTOR(UART_A_SIZE - 1 downto 0);--byte access - low 2 bits are always 0
		UART_D           : out STD_LOGIC_VECTOR(31 downto 0);
		D_TO_UART        : in  STD_LOGIC_VECTOR(31 downto 0)
		
	);
end entity uart_if;

architecture rtl of uart_if is
	signal intRdData    : STD_LOGIC_VECTOR (7 downto 0);      -- data read from register file
	signal intAddress   : STD_LOGIC_VECTOR (UART_A_SIZE - 1 downto 0); -- address bus to register file
	signal intWrData    : STD_LOGIC_VECTOR (7 downto 0);      -- write data to register file
	signal intWrite     : STD_LOGIC;                          -- write control to register file
	signal intRead      : STD_LOGIC;                         -- read control to register file
	signal uart_aw		: std_logic_vector(UART_A_SIZE - 1 downto 0);
	signal uart_ar		: std_logic_vector(UART_A_SIZE - 1 downto 0);
	signal d_to_uart_saved : STD_LOGIC_VECTOR(31 downto 0);
	signal UART_WE_sig  : STD_LOGIC;
	constant ZERO : std_logic_vector(UART_A_SIZE - 1 downto 0) := std_logic_vector(to_unsigned(0,UART_A_SIZE));
	
--	attribute mark_debug : string;
--	attribute mark_debug of UART_WE : signal is "true";
--	attribute mark_debug of UART_A : signal is "true";
--	attribute mark_debug of UART_D : signal is "true";
--	attribute mark_debug of D_TO_UART : signal is "true";
--	attribute mark_debug of uart_aw : signal is "true";
--	attribute mark_debug of uart_ar : signal is "true";
--	attribute mark_debug of intRdData : signal is "true";
--	attribute mark_debug of intAddress : signal is "true";
--	attribute mark_debug of intWrData : signal is "true";
--	attribute mark_debug of intWrite : signal is "true";
--	attribute mark_debug of intRead : signal is "true";
--	attribute mark_debug of d_to_uart_saved : signal is "true";

begin
	uart2bus_inst: entity work.uart2BusTop
		generic map(
			AW => UART_A_SIZE
		)
		port map(
			clr          => ASYNC_RST,
			clk          => CLK,
			serIn        => USB_UART_RX,
			serOut       => USB_UART_TX,
			intAccessReq => open,
			intAccessGnt => '1',
			intRdData    => intRdData,
			intAddress   => intAddress,
			intWrData    => intWrData,
			intWrite     => intWrite,
			intRead      => intRead
		);
		
	process(CLK)
	begin
		if rising_edge(CLK) then
			UART_WE_sig <= '0';
			if intWrite = '1' then
				case intAddress(1 downto 0) is
				when "00" =>
					UART_D( 7 downto 0) <= intWrData;
				when "01" =>
					UART_D(15 downto 8) <= intWrData;
				when "10" =>
					UART_D(23 downto 16) <= intWrData;
				when "11" =>
					UART_D(31 downto 24) <= intWrData;
					UART_WE_sig <= '1';
					uart_aw <= intAddress(UART_A_SIZE - 1 downto 2) & "00";
				when others => null;
				end case;
			end if;
		end if;	
	end process;	
	UART_A <= uart_aw when UART_WE_sig = '1' else uart_ar;
	UART_WE <= UART_WE_sig;
	
	process(intAddress, D_TO_UART, d_to_uart_saved)
	begin
		intRdData <= (others => '0');
		case intAddress(1 downto 0) is
		when "00" =>
			intRdData <= D_TO_UART(7 downto 0);
		when "01" =>
			intRdData <= d_to_uart_saved(15 downto 8);
		when "10" =>
			intRdData <= d_to_uart_saved(23 downto 16);
		when "11" =>
			intRdData <= d_to_uart_saved(31 downto 24);
		when others => null;
		end case;
	end process;
	
	-- logic to prevent more than one 32 bit read from regs, for the 4 8bit reads from uart
	-- Note: the outside controller when reading byte by byte a 32 bit register must first read byte 0 then 1,2,3
	process(CLK)
	begin
		if rising_edge(CLK) then
			if intRead = '1' then
				if intAddress(1 downto 0) = "00" then
					d_to_uart_saved <= D_TO_UART;
				end if;
			end if;		
		end if;	
	end process;
	uart_ar <= intAddress when intAddress(1 downto 0) = "00" else ZERO;
		
end;
	