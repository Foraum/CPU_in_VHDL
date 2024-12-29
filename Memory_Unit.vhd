library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;  -- This is required for to_integer

entity memory_unit is
    Port ( clk     : in  STD_LOGIC;
           reset   : in  STD_LOGIC;
           we      : in  STD_LOGIC; --write enable
           addr    : in  STD_LOGIC_VECTOR(4 downto 0); --address
           data_in : in  STD_LOGIC_VECTOR(15 downto 0);
           data_out: out STD_LOGIC_VECTOR(15 downto 0));
end memory_unit;

architecture Behavioral of memory_unit is
    type memory_array is array (0 to 15) of STD_LOGIC_VECTOR(15 downto 0);
    signal mem 	: memory_array := (others => (others => '0'));
	 signal pmem	: memory_array := (others => (others => '0'));

begin

	 write_proc:process(clk, reset)
    begin
        if reset = '1' then
            mem <= (others => (others => '0'));
        elsif rising_edge(clk) then
            if we = '1' and (to_integer(unsigned(addr))>15) then
                mem(to_integer(unsigned(addr))-16) <= data_in;
            end if;
        end if;
    end process;
	 
	 read_proc:process(addr,clk)
	 begin			
		if (to_integer(unsigned(addr))>15) then
			data_out <= mem(to_integer(unsigned(addr))-16);
		else
			data_out <= pmem(to_integer(unsigned(addr)));
		end if;
	 end process;
	 
	 --write the program here
	 
	 pmem(0) <= "1001000010001000";	-- LLI 000 10001000
	 pmem(1) <= "1000001010111001";	-- LHI 001 10111001
	 pmem(2) <= "0000000001010000";	-- ADD 000 001 010
	 pmem(3) <= "0010001000011000";	-- SUB 001 000 011
	 pmem(4) <= "1101100000000011";	-- JAL 100 000000011
	 pmem(5) <= "1001000010101010";	-- LLI 000 10101010
	 pmem(6) <= "1000001010001011";	-- LHI 001 10001011
	 pmem(7) <= "0000000001101000";	-- ADD 000 001 101
	 pmem(8) <= "1100010101111111";	-- BEQ 010 101 111111
	 pmem(9) <= "1001111010001000";	-- LLI 111 10001000
	 pmem(10) <= "1011101100011111";	-- SW  101 100 010000
	 pmem(11) <= "1010110100011111";	-- LW  110 100 010000
	 pmem(12) <= "0001100100000001";	-- ADI 100 100 000001
	--pmem(13) <= "1000001010001011";	-- LHI 001 10001011
	--pmem(13) <= "1000001010001011";	-- LHI 001 10001011
	--pmem(13) <= "0011000000000111"; -- MUL 000 000 000 
	--pmem(13) <= "0100001010011000"; -- AND 001 010 011
	--pmem(14) <= "0101001010011000"; -- OR  001 010 011
	--pmem(15) <= "0110000000000000"; --IMP 000 000 000
	 pmem(13) <= "1111001010000000"; -- JLR 001 010 
	--pmem(13) <= "1110000111111110";	-- J   000 111111110
end Behavioral;
