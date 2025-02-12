library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SE9 is
	port(
		inp 	: in std_logic_vector(8 downto 0);
		outp	: out std_logic_vector(15 downto 0));
end entity;

architecture behav of SE9 is
begin
	process(inp)
	begin
		if inp(8) = '0' then
			outp <= "0000000"&inp;
		elsif inp(8) ='1' then
			outp <= "1111111"&inp;
		else
			outp <= (others => 'U');
		end if;
	end process;
end architecture;