library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity SE6 is
	port(
		inp 	: in std_logic_vector(5 downto 0);
		outp	: out std_logic_vector(15 downto 0));
end entity;

architecture behav of SE6 is
begin
	process(inp)
	begin
		if inp(5) = '0' then
			outp <= "0000000000"&inp;
		elsif inp(5) ='1' then
			outp <= "1111111111"&inp;
		else
			outp <= (others => 'U');
		end if;
	end process;
end architecture;
