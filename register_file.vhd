library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity register_file is
	port(
		reset	: in std_logic;
		clk	: in std_logic;
		en		: in std_logic;
		A1		: in std_logic_vector(2 downto 0);
		A2		: in std_logic_vector(2 downto 0);
		A3		: in std_logic_vector(2 downto 0);
		D3		: in std_logic_vector(15 downto 0);
		D1		: out std_logic_vector(15 downto 0);
		D2		: out std_logic_vector(15 downto 0);
		R1o,R2o,R3o,R4o,R5o,R6o,R7o,R8o : out std_logic_vector(15 downto 0));
end entity;

architecture rtl of register_file is
signal R1,R2,R3,R4,R5,R6,R7,R8,Rex : std_logic_vector(15 downto 0);
begin

readA1_proc: process(A1,clk)
begin
	case A1 is
		when "000" => D1<=R1;
		when "001" => D1<=R2;
		when "010" => D1<=R3;
		when "011" => D1<=R4;
		when "100" => D1<=R5;
		when "101" => D1<=R6;
		when "110" => D1<=R7;
		when "111" => D1<=R8;
		when others =>D1<=(others => 'U');
	end case;	
end process;

readA2_proc: process(A2,clk)
begin
	case A2 is
		when "000" => D2<=R1;
		when "001" => D2<=R2;
		when "010" => D2<=R3;
		when "011" => D2<=R4;
		when "100" => D2<=R5;
		when "101" => D2<=R6;
		when "110" => D2<=R7;
		when "111" => D2<=R8;
		when others =>D2<=(others => 'U');
	end case;	
end process;


write_proc: process(clk)
begin
	if reset = '1' then
		R1 <=(others => '0');
		R2 <=(others => '0');
		R3 <=(others => '0');
		R4 <=(others => '0');
		R5 <=(others => '0');
		R6 <=(others => '0');
		R7 <=(others => '0');
		R8 <=(others => '0');
		Rex <=(others => '0');
	elsif rising_edge(clk) then
		if en = '1' then
			case A3 is
				when "000" => R1<=D3;
				when "001" => R2<=D3;
				when "010" => R3<=D3;
				when "011" => R4<=D3;
				when "100" => R5<=D3;
				when "101" => R6<=D3;
				when "110" => R7<=D3;
				when "111" => R8<=D3;
				when others =>Rex<=D3; --R_excess for debugging
			end case;
		end if;
	end if;
end process;

R1o <= R1;
R2o <= R2;
R3o <= R3;
R4o <= R4;
R5o <= R5;
R6o <= R6;
R7o <= R7;
R8o <= R8;
end architecture;