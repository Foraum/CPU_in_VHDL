library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MUX_16BIT is
    port (
		S: 	in std_logic_vector(2 downto 0);
		I0:	in std_logic_vector(15 downto 0) :=(others=>'Z');
		I1: 	in std_logic_vector(15 downto 0) :=(others=>'Z');
		I2: 	in std_logic_vector(15 downto 0) :=(others=>'Z');
		I3: 	in std_logic_vector(15 downto 0) :=(others=>'Z');
		I4: 	in std_logic_vector(15 downto 0) :=(others=>'Z');
		I5: 	in std_logic_vector(15 downto 0) :=(others=>'Z');
		Outp:	out std_logic_vector(15 downto 0));
end entity;

architecture rtl of MUX_16BIT is
begin

process(S,I0,I1,I2,I3,I4,I5)
begin
	case S is
		when "000" => Outp <= I0;
		when "001" => Outp <= I1;
		when "010" => Outp <= I2;
		when "011" => Outp <= I3;
		when "100" => Outp <= I4;
		when "101" => Outp <= I5;
		when others => Outp <= (others => 'U');
	end case;
end process;
end architecture;