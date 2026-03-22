library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity CPU_pipeline is
    port (
        clk, reset: in std_logic;
		  R1o,R2o,R3o,R4o,R5o,R6o,R7o,R8o :  out std_logic_vector(15 downto 0);
		  mux_out : out std_logic_vector(3 downto 0);
		  PC_out,IR_out,mem_out: out std_logic_vector(15 downto 0);
		  oper_out: out std_logic_vector(3 downto 0)
		  );
end entity;

architecture rtl of CPU_pipeline is

component MUX_3BIT is
    port (
		S: 	in std_logic_vector(1 downto 0);
		I0:	in std_logic_vector(2 downto 0) :=(others=>'Z');
		I1: 	in std_logic_vector(2 downto 0) :=(others=>'Z');
		I2: 	in std_logic_vector(2 downto 0) :=(others=>'Z');
		I3: 	in std_logic_vector(2 downto 0) :=(others=>'Z');
		Outp:	out std_logic_vector(2 downto 0));
end component;

component MUX_16BIT is
    port (
		S: 	in std_logic_vector(2 downto 0);
		I0:	in std_logic_vector(15 downto 0) :=(others=>'Z');
		I1: 	in std_logic_vector(15 downto 0) :=(others=>'Z');
		I2: 	in std_logic_vector(15 downto 0) :=(others=>'Z');
		I3: 	in std_logic_vector(15 downto 0) :=(others=>'Z');
		I4: 	in std_logic_vector(15 downto 0) :=(others=>'Z');
		I5: 	in std_logic_vector(15 downto 0) :=(others=>'Z');
		Outp:	out std_logic_vector(15 downto 0));
end component;

component register_16bit is
	port(
		reset		: in std_logic;
		clk		: in std_logic;
		en			: in std_logic;
		data_in	: in std_logic_vector(15 downto 0);
		data_out : out std_logic_vector(15 downto 0));
end component;

component register_file is
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
end component;

component memory_unit is
    Port ( clk     : in  STD_LOGIC;        -- Clock signal
           reset   : in  STD_LOGIC;        -- Reset signal
           we      : in  STD_LOGIC;        -- Write enable
           addr    : in  STD_LOGIC_VECTOR(4 downto 0); -- 4-bit address for 16 locations
           data_in : in  STD_LOGIC_VECTOR(15 downto 0); -- Data input (16 bits)
           data_out: out STD_LOGIC_VECTOR(15 downto 0)  -- Data output (16 bits)
			  );
end component;

component ALUD is
    port(
        A, B    : in std_logic_vector(15 downto 0);
        Oper    : in std_logic_vector(3 downto 0);
        C       : out std_logic_vector(15 downto 0);
        Z       : out std_logic;
        Carry   : out std_logic);
end component;

component ring_buffer is

  generic (
    -- 16 bit data
    RAM_WIDTH : integer := 16;
    RAM_DEPTH : integer := 32
  );
  port (
    clk : in std_logic;
    rst : in std_logic;
  
    -- Write port
    wr_en : in std_logic;
    wr_data : in std_logic_vector(RAM_WIDTH - 1 downto 0);
  
    -- Read port
    rd_en : in std_logic;
    rd_valid : out std_logic;
    rd_data : out std_logic_vector(RAM_WIDTH - 1 downto 0);
  
    -- Flags
    empty : out std_logic;
    empty_next : out std_logic;
    full : out std_logic;
    full_next : out std_logic;
  
    -- The number of elements in the FIFO
    fill_count : out integer range RAM_DEPTH - 1 downto 0
  );
end component;

component next_addr is
    Port (
        input  : in  std_logic_vector(15 downto 0);
        output : out std_logic_vector(15 downto 0)
    );
end component;

component register_3bit is
	port(
		reset		: in std_logic;
		clk		: in std_logic;
		en			: in std_logic;
		data_in	: in std_logic_vector(2 downto 0);
		data_out : out std_logic_vector(2 downto 0));
end component;

component register_4bit is
	port(
		reset		: in std_logic;
		clk		: in std_logic;
		en			: in std_logic;
		data_in	: in std_logic_vector(3 downto 0);
		data_out : out std_logic_vector(3 downto 0));
end component;

type state is (Error, rst, fetch, decode, mem_load,wb_load,mem_store, ex_arith,ex_imm,ex_jump);

signal curr_state,next_state : state := rst;
signal IR,PC,Xreg,Yreg,Zreg,regD : std_logic_vector(15 downto 0);
signal opcode,alu_func : std_logic_vector(3 downto 0);
signal mem_write,mem_read,regf_write,IR_write,PC_write : std_logic;
signal regA1,regA2,regA3: std_logic_vector(2 downto 0);
signal mem_data_in,mem_data_out,alu_A,alu_B,alu_C,PC_in,imm6,imm9,PCin,IR_in,PCinc: std_logic_vector(15 downto 0);
signal sig_regf_data,sig_ID_Y,sig_alu_A:std_logic_vector(2 downto 0);
signal sig_regf_A1: std_logic_vector(1 downto 0);
signal ID_X, ID_Y, EM_Z, EM_Dout,ID_Y_in: std_logic_vector(15 downto 0);
signal ID_Ra,EM_Ra: std_logic_vector(2 downto 0);
signal ID_op,EM_op,IR_op: std_logic_vector(3 downto 0);
signal next_PC : std_logic_vector(15 downto 0);

begin

IR_op <= IR(15 downto 12);				--Operation Code

regA3 <= EM_Ra; 
regA2	<=	IR(5 downto 3);
imm6 <= "0000000000" & IR(5 downto 0);
imm9 <= "0000000" & IR(8 downto 0);

PCinc <= "0000000000000010";
Zreg <= alu_C;

alu_A <= ID_X;
alu_B <= ID_Y;

next_Address: next_addr port map(PC,next_PC);
 
reg_file_inst: register_file port map(reset,clk,regf_write,regA1,regA2,regA3,regD,Xreg,Yreg,R1o,R2o,R3o,R4o,R5o,R6o,R7o,R8o);
program_mem: memory_unit port map(clk,reset,'0',PC(5 downto 1),(others => '0'),IR_in);
data_mem: ring_buffer port map(clk,reset,mem_write,ID_X,mem_read,open,mem_data_out);
ALUD_inst: ALUD port map(alu_A,alu_B,alu_func,alu_C,open,open);

program_counter: register_16bit port map(reset,clk,'1',next_PC,PC);
IR_1: register_16bit port map(reset,clk,'1',IR_in,IR);
ID_0: register_4bit port map(reset,clk,'1',IR(15 downto 12),ID_op);
ID_1: register_3bit port map(reset,clk,'1',IR(11 downto 9),ID_Ra);
ID_2: register_16bit port map(reset,clk,'1',Xreg,ID_X);
ID_3: register_16bit port map(reset,clk,'1',ID_Y_in,ID_Y);
EM_0: register_4bit port map(reset,clk,'1',ID_op,EM_op);
EM_1: register_3bit port map(reset,clk,'1',ID_Ra,EM_Ra);
EM_2: register_16bit port map(reset,clk,'1',Zreg,EM_Z);
EM_3: register_16bit port map(reset,clk,'1',mem_data_out,EM_Dout); 

--muxes
mux_regf_A1: MUX_3BIT port map(sig_regf_A1,IR(8 downto 6),IR(11 downto 9),open,Outp => regA1);
mux_regf_data: MUX_16BIT port map(sig_regf_data,EM_Dout,EM_Z,open,Outp => regD);
mux_ID_Y: MUX_16BIT port map(sig_ID_Y,Yreg,imm6,imm9,open,Outp => ID_Y_in);

clock_process: process(clk,reset)
begin
	if rising_edge(clk) then
		if reset ='0' then
			curr_state <= next_state;
		else
			curr_state <= rst;
		end if;
	end if;
end process; --clock process


signal_process: process(clk)
begin
	case IR_op is
		when "0000"|"0001" =>
			sig_regf_A1 <= "01";
			sig_ID_Y <= "000";
			
		when "0010"|"0011"|"0100"|"0110" =>
			sig_regf_A1 <= "00";
			sig_ID_Y <= "000";
			
		when "0101" =>
			sig_regf_A1 <= "00";
			sig_ID_Y <= "001";
			
		when others =>
			sig_regf_A1 <= "00";
			sig_ID_Y <= "000";
	end case;
	
	case ID_op is
		when "0000" =>			--LW
			alu_func<= "0000";
			mem_read <= '1';
			mem_write <= '0';
			
		when "0001" =>			--SW
			alu_func<= "0000";
			mem_read <= '0';
			mem_write <= '1';
			
		when "0010"|"0011"|"0100"|"0110" =>		--Arith
			alu_func<= "0010";
			mem_read <= '0';
			mem_write <= '0';
			
		when "0101" =>				--ADDI
			alu_func<= "0010";
			mem_read <= '0';
			mem_write <= '0';
			
		when others =>
			alu_func<= "0000";
			mem_read <= '0';
			mem_write <= '0';
			
	end case;
	
	case EM_op is
	
		when "0000" =>			--LW
			sig_regf_data <= "000";
			regf_write <= '1';
			
		when "0010"|"0011"|"0100"|"0110"|"0101" =>		--Arith
			sig_regf_data <= "001";
			regf_write <= '1';
			
		when others=>
			sig_regf_data <= "000";
			regf_write <= '0';
	end case;
	
end process;--output proces

oper_out <= IR_op;
PC_out <= PC;
IR_out <= IR;
mem_out <= mem_data_out;

end architecture;