library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity register_16bit is
	port(
		reset		: in std_logic;
		clk		: in std_logic;
		en			: in std_logic;
		data_in	: in std_logic_vector(15 downto 0);
		data_out : out std_logic_vector(15 downto 0));
end entity;

architecture rtl of register_16bit is
signal data_temp : std_logic_vector(15 downto 0):=(others => '0');
begin

data_out <= data_temp;

input_proc: process(clk)
begin
	if	reset ='1' then
		data_temp <= (others => '0');
	elsif rising_edge(clk) then
		if en ='1' then
			data_temp <= data_in;
		end if;
	end if;
end process;

end architecture;