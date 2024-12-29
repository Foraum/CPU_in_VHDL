library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity IITB_CPU is
    port (
        clk, reset: in std_logic;
		  R1o,R2o,R3o,R4o,R5o,R6o,R7o,R8o :  out std_logic_vector(15 downto 0);
		  mux_out : out std_logic_vector(19 downto 0);
		  PC_out,IR_out,CCR_out: out std_logic_vector(15 downto 0);
		  oper_out: out std_logic_vector(3 downto 0)
		  );
end entity;

architecture rtl of IITB_CPU is

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

component SE9 is
	port(
		inp 	: in std_logic_vector(8 downto 0);
		outp	: out std_logic_vector(15 downto 0));
end component;

component SE6 is
	port(
		inp 	: in std_logic_vector(5 downto 0);
		outp	: out std_logic_vector(15 downto 0));
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

type state is (Error, rst, S1, S1choose, S2, S2p, S3add, S3sub, S3mul, S3ora, S3and, S3imp, S4, S5, S6, S7, S8, S9, S10, S10p, S11, S12, S13, S14, S15,S16);

signal curr_state,next_state : state := rst;
signal IR,PC,T1,T2,T3,M1,M5,M6,M7,M8,M9,MZ,D1_out,D2_out : std_logic_vector(15 downto 0);
signal M2,M3,M4 : std_logic_vector(2 downto 0);
signal oper,ALU_mode: std_logic_vector(3 downto 0);
signal CCR,nullZ,PC_incr,SE9_sig,SE9_LS1,SE6_sig,SE6_LS1,rZE,lZE,ALU_C,Mem_Data : std_logic_vector(15 downto 0);
signal PC_en,Mem_rd,Mem_wr,IR_en,T1_en,T2_en,T3_en,RF_wr,Z,Cout: std_logic:='0';
signal Mux_sig,mux_sig_temp : std_logic_vector(19 downto 0) := (others => '0');
signal mux1_sig,mux5_sig,mux8_sig,mux9_sig,muxz_sig : std_logic_vector(2 downto 0);

begin

PC_incr <= "0000000000000010"; 		--PC incrementing number, here its +2
nullZ <= (others => 'Z');				--null Value
oper <= IR(15 downto 12);				--Operation Code

--Extenders and shifters--------------
lZE <= "00000000" & IR(7 downto 0);
rZE <= IR(7 downto 0) & "00000000";
SE6_LS1 <= SE6_sig(14 downto 0) & "0";
SE9_LS1 <= SE9_sig(14 downto 0) & "0";
se9_inst: SE9 port map(IR(8 downto 0),SE9_sig);
se6_inst: SE6 port map(IR(5 downto 0),SE6_sig);

--ALU Unit----------------------------
ALUD_inst: ALUD port map(M5,M6,ALU_mode,ALU_C,Z,Cout);

--Register file and Memory------------
reg_file_inst: register_file port map(reset,clk,RF_wr,M2,M3,M4,M7,D1_out,D2_out,R1o,R2o,R3o,R4o,R5o,R6o,R7o,R8o);
mem_unit_inst: memory_unit port map(clk,reset,Mem_wr,M1(5 downto 1),T2,Mem_Data);

--Registers---------------------------
Instruction_reg: register_16bit port map(reset,clk,IR_en,Mem_Data,IR);
temporary1_reg: register_16bit port map(reset,clk,T1_en,D1_out,T1);
temporary2_reg: register_16bit port map(reset,clk,T2_en,D2_out,T2);
temporary3_reg: register_16bit port map(reset,clk,T3_en,M8,T3);
program_counter: register_16bit port map(reset,clk,PC_en,M9,PC);

--Muxes-------------------------------
mux1_sig <= "0" & mux_sig(19 downto 18);
mux5_sig <= "0" & mux_sig(11 downto 10);
mux8_sig <= "0" & mux_sig(3 downto 2);
mux9_sig <= "0" & mux_sig(1 downto 0);
muxz_sig <= "00"& CCR(0);
mux1: MUX_16BIT port map(mux1_sig,nullZ,PC,T3,Outp => M1);
mux2: MUX_3BIT port map(mux_sig(17 downto 16),(others=>'Z'),IR(11 downto 9),IR(8 downto 6),Outp => M2);
mux3: MUX_3BIT port map(mux_sig(15 downto 14),(others=>'Z'),IR(11 downto 9),IR(8 downto 6),Outp => M3);
mux4: MUX_3BIT port map(mux_sig(13 downto 12),(others=>'Z'),IR(5 downto 3),IR(11 downto 9),IR(8 downto 6),Outp => M4);
mux5: MUX_16BIT port map(mux5_sig,nullZ,PC,T1,Outp => M5);
mux6: MUX_16BIT port map(mux_sig(9 downto 7),nullZ,PC_incr,T2,SE9_LS1,SE6_sig,SE6_LS1,Outp => M6);
mux7: MUX_16BIT port map(mux_sig(6 downto 4),nullZ,PC,rZE,lZE,T3,Outp => M7);
mux8: MUX_16BIT port map(mux8_sig,nullZ,ALU_C,Mem_Data,Outp => M8);
mux9: MUX_16BIT port map(mux9_sig,nullZ,MZ,T2,ALU_C,Outp => M9);
muxZ: MUX_16BIT port map(muxz_sig,PC,ALU_C,Outp => MZ);


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

state_trans_process: process(curr_state,IR,clk)
begin
	case curr_state is
	
		when rst =>
			next_state <= S1;
			
		when S1 =>
			next_state <= S1choose;
			
		when S1choose =>
			case oper is
				when "1010"|"1011" => next_state <= S2p; --LW SW
				when others => next_state <= S2;  -- otherwise case
			end case;
			
		when S2 =>
			case oper is
				when "0000" => next_state <= S3add;				--ADD
				when "0010" => next_state <= S3sub;				--SUB
				when "0011" => next_state <= S3mul;				--MUL
				when "0100" => next_state <= S3and;				--AND
				when "0101" => next_state <= S3ora;				--ORA
				when "0110" => next_state <= S3imp;				--IMP
				when "0001" => next_state <= S9;					--ADI
				when "1100" => next_state <= S4;					--BEQ
				when "1101"|"1111" => next_state <= S5;		--JAL JLR
				when "1110" => next_state <= S6;					--J
				when "1000" => next_state <= S7;					--LHI
				when "1001" => next_state <= S8;					--LLI
				when others => next_state <= error;				--Error case
			end case;
			
		when S2p =>
			next_state <= S9;
				
		when S3add|S3sub|S3mul|S3and|S3ora|S3imp =>
			next_state <= S10;
		
		when S4 =>
			if CCR(0) = '1' then
				next_state <= S11;
			else
				next_state <= S1;
			end if;
		
		when S5 =>
			case oper is
				when "1101" => next_state <= S6;		--JAL
				when "1111" => next_state <= S12;		--JLR
				when others => next_state <= error;		--Error case
			end case;
		
		when S6 =>			
			next_state <= S16;
			
		
		when S7 =>
			next_state <= S1;
			
		when S8 =>
			next_state <= S1;
			
		when S9 =>
			case oper is
				when "0001" => next_state <= S15;		--ADI
				when "1010" => next_state <= S13;		--LW
				when "1011" => next_state <= S14;		--SW
				when others => next_state <= error;		--Error case
			end case;
		
		when S10|S10p =>
			next_state <= S1;
		
		when S11 =>
			next_state <= S16;
			
		when S12 =>
			next_state <= S1;
			
		when S13 =>
			next_state <= S10p;
			
		when S14 =>
			next_state <= S1;	
		
		when S15 =>
			next_state <= S1;
			
		when S16 =>
			next_state <= S1;
		
		when others =>
			next_state <= error;
	end case;
end process; --State transition proces

output_process: process(curr_state,clk)
begin
	case curr_state is
		when S1 =>
			mux_sig_temp 	<= "01000000010010000011";
			PC_en 	<= '1';
			Mem_rd 	<= '1';
			Mem_wr	<= '0';
			RF_wr		<= '0';
			IR_en 	<= '1';
			T1_en 	<= '0';
			T2_en 	<= '0';
			T3_en		<= '0';
			ALU_mode <= "0000";
			CCR <= (others => '0');
			if Cout = '1' then CCR(1) <= '1';
			else CCR(1) <= '0';
			end if;
			--ALU ADD;
			
		when S2 =>
			mux_sig_temp <= "00011000000000000000";
			PC_en 	<= '0';
			Mem_rd 	<= '0';
			Mem_wr	<= '0';
			RF_wr		<= '0';
			IR_en 	<= '0';
			T1_en 	<= '1';
			T2_en 	<= '1';
			T3_en		<= '0';
			ALU_mode <= "ZZZZ";
			--ALU;
			
		when S2p =>
			mux_sig_temp <= "00100100000000000000";
			PC_en 	<= '0';
			Mem_rd 	<= '0';
			Mem_wr	<= '0';
			RF_wr		<= '0';
			IR_en 	<= '0';
			T1_en 	<= '1';
			T2_en 	<= '1';
			T3_en		<= '0';
			ALU_mode <= "ZZZZ";
			--ALU;
		
		when S4 =>
			mux_sig_temp <= "00000000100100000000";
			PC_en 	<= '0';
			Mem_rd 	<= '0';
			Mem_wr	<= '0';
			RF_wr		<= '0';
			IR_en 	<= '0';
			T1_en 	<= '0';
			T2_en 	<= '0';
			T3_en		<= '0';
			ALU_mode <= "0010";
			if Z = '1' then CCR(0) <= '1';
			else CCR(0) <= '0';
			end if;
			if Cout = '1' then CCR(1) <= '1';
			else CCR(1) <= '0';
			end if;
			--ALU SUB;
			
		when S5 =>
			mux_sig_temp <= "00000010000000010000";
			PC_en 	<= '0';
			Mem_rd 	<= '0';
			Mem_wr	<= '0';
			RF_wr		<= '1';
			IR_en 	<= '0';
			T1_en 	<= '0';
			T2_en 	<= '0';
			T3_en		<= '0';
			ALU_mode <= "ZZZZ";
			--ALU;
			
		when S6 =>
		mux_sig_temp <= "00000000010110000011";
			PC_en 	<= '1';
			Mem_rd 	<= '0';
			Mem_wr	<= '0';
			RF_wr		<= '0';
			IR_en 	<= '0';
			T1_en 	<= '0';
			T2_en 	<= '0';
			T3_en		<= '0';
			ALU_mode <= "0000";
			if Cout = '1' then CCR(1) <= '1';
			else CCR(1) <= '0';
			end if;	
			--ALU ADD;
			
		when S7 =>
			mux_sig_temp <= "00000010000000100000";
			PC_en 	<= '0';
			Mem_rd 	<= '0';
			Mem_wr	<= '0';
			RF_wr		<= '1';
			IR_en 	<= '0';
			T1_en 	<= '0';
			T2_en 	<= '0';
			T3_en		<= '0';
			ALU_mode <= "ZZZZ";
			--ALU;

		when S8 =>
			mux_sig_temp <= "00000010000000110000";
			PC_en 	<= '0';
			Mem_rd 	<= '0';
			Mem_wr	<= '0';
			RF_wr		<= '1';
			IR_en 	<= '0';
			T1_en 	<= '0';
			T2_en 	<= '0';
			T3_en		<= '0';
			ALU_mode <= "ZZZZ";
			--ALU;
			
		when S9 =>
			mux_sig_temp <= "00000000101000000100";
			PC_en 	<= '0';
			Mem_rd 	<= '0';
			Mem_wr	<= '0';
			RF_wr		<= '0';
			IR_en 	<= '0';
			T1_en 	<= '0';
			T2_en 	<= '0';
			T3_en		<= '1';
			ALU_mode <= "0000";
			if Cout = '1' then CCR(1) <= '1';
			else CCR(1) <= '0';
			end if;
			--ALU ADD;
			
		when S10 =>
			mux_sig_temp <= "00000001000001000000";
			PC_en 	<= '0';
			Mem_rd 	<= '0';
			Mem_wr	<= '0';
			RF_wr		<= '1';
			IR_en 	<= '0';
			T1_en 	<= '0';
			T2_en 	<= '0';
			T3_en		<= '0';
			ALU_mode <= "ZZZZ";
			--ALU;
		
		when S10p =>
			mux_sig_temp <= "00000010000001000000";
			PC_en 	<= '0';
			Mem_rd 	<= '0';
			Mem_wr	<= '0';
			RF_wr		<= '1';
			IR_en 	<= '0';
			T1_en 	<= '0';
			T2_en 	<= '0';
			T3_en		<= '0';
			ALU_mode <= "ZZZZ";
			--ALU;
		
		when S11 =>
			mux_sig_temp <= "00000000011010000001";
			PC_en 	<= '1';
			Mem_rd 	<= '0';
			Mem_wr	<= '0';
			RF_wr		<= '0';
			IR_en 	<= '0';
			T1_en 	<= '0';
			T2_en 	<= '0';
			T3_en		<= '0';
			ALU_mode <= "0000";
			if Cout = '1' then CCR(1) <= '1';
			else CCR(1) <= '0';
			end if;
			--ALU ADD;
			
		when S12 =>
			mux_sig_temp <= "00000000000000000010";
			PC_en 	<= '1';
			Mem_rd 	<= '0';
			Mem_wr	<= '0';
			RF_wr		<= '0';
			IR_en 	<= '0';
			T1_en 	<= '0';
			T2_en 	<= '0';
			T3_en		<= '0';
			ALU_mode <= "ZZZZ";
			--ALU;
		
		when S13 =>
			mux_sig_temp <= "10000000000000001000";
			PC_en 	<= '0';
			Mem_rd 	<= '1';
			Mem_wr	<= '0';
			RF_wr		<= '0';
			IR_en 	<= '0';
			T1_en 	<= '0';
			T2_en 	<= '0';
			T3_en		<= '1';
			ALU_mode <= "ZZZZ";
			--ALU;
		
		when S14 =>
			mux_sig_temp <= "10000000000000000000";
			PC_en 	<= '0';
			Mem_rd 	<= '0';
			Mem_wr	<= '1';
			RF_wr		<= '0';
			IR_en 	<= '0';
			T1_en 	<= '0';
			T2_en 	<= '0';
			T3_en		<= '0';
			ALU_mode <= "ZZZZ";
			--ALU;
			
		when S15 =>
			mux_sig_temp <= "00000011000001000000";
			PC_en 	<= '0';
			Mem_rd 	<= '0'; 
			Mem_wr	<= '0';
			RF_wr		<= '1';
			IR_en 	<= '0';
			T1_en 	<= '0';
			T2_en 	<= '0';
			T3_en		<= '0';
			ALU_mode <= "ZZZZ";
			--ALU;
			
		when S3add =>
			mux_sig_temp <= "00000000100100000100";
			PC_en 	<= '0';
			Mem_rd 	<= '0';
			Mem_wr	<= '0';
			RF_wr		<= '0';
			IR_en 	<= '0';
			T1_en 	<= '0';
			T2_en 	<= '0';
			T3_en		<= '1';
			ALU_mode <= "0000";
			if Cout = '1' then CCR(1) <= '1';
			else CCR(1) <= '0';
			end if;
			--ALU ADD;
			
		when S3sub =>
			mux_sig_temp <= "00000000100100000100";
			PC_en 	<= '0';
			Mem_rd 	<= '0';
			Mem_wr	<= '0';
			RF_wr		<= '0';
			IR_en 	<= '0';
			T1_en 	<= '0';
			T2_en 	<= '0';
			T3_en		<= '1';
			ALU_mode <= "0010";
			if Cout = '1' then CCR(1) <= '1';
			else CCR(1) <= '0';
			end if;
			--ALU SUB;
			
		when S3mul =>
			mux_sig_temp <= "00000000100100000100";
			PC_en 	<= '0';
			Mem_rd 	<= '0';
			Mem_wr	<= '0';
			RF_wr		<= '0';
			IR_en 	<= '0';
			T1_en 	<= '0';
			T2_en 	<= '0';
			T3_en		<= '1';
			ALU_mode <= "0011";
			if Cout = '1' then CCR(1) <= '1';
			else CCR(1) <= '0';
			end if;
			--ALU MUL;
			
		when S3ora =>
			mux_sig_temp <= "00000000100100000100";
			PC_en 	<= '0';
			Mem_rd 	<= '0';
			Mem_wr	<= '0';
			RF_wr		<= '0';
			IR_en 	<= '0';
			T1_en 	<= '0';
			T2_en 	<= '0';
			T3_en		<= '1';
			ALU_mode <= "0101";
			--ALU OR;
			
		when S3and =>
			mux_sig_temp <= "00000000100100000100";
			PC_en 	<= '0';
			Mem_rd 	<= '0';
			Mem_wr	<= '0';
			RF_wr		<= '0';
			IR_en 	<= '0';
			T1_en 	<= '0';
			T2_en 	<= '0';
			T3_en		<= '1';
			ALU_mode <= "0100";
			--ALU AND;
		
		when S3imp =>
			mux_sig_temp <= "00000000100100000100";
			PC_en 	<= '0';
			Mem_rd 	<= '0';
			Mem_wr	<= '0';
			RF_wr		<= '0';
			IR_en 	<= '0';
			T1_en 	<= '0';
			T2_en 	<= '0';
			T3_en		<= '1';
			ALU_mode <= "0110";
			--ALU IMP;
			
		when S16 =>
			mux_sig_temp <= "01000000010010000011";
			PC_en 	<= '1';
			Mem_rd 	<= '0';
			Mem_wr	<= '0';
			RF_wr		<= '0';
			IR_en 	<= '0';
			T1_en 	<= '0';
			T2_en 	<= '0';
			T3_en		<= '0';
			ALU_mode <= "0010";
			if Cout = '1' then CCR(1) <= '1';
			else CCR(1) <= '0';
			end if;	
			--ALU SUB;
			
			
		when others =>
			mux_sig_temp <= "00000000000000000000";
			PC_en 	<= '0';
			Mem_rd 	<= '0';
			Mem_wr	<= '0';
			RF_wr		<= '0';
			IR_en 	<= '0';
			T1_en 	<= '0';
			T2_en 	<= '0';
			T3_en		<= '0';
			--ALU;
			
	end case;
end process;--output proces

mux_out <= mux_sig_temp;
mux_sig <= mux_sig_temp;
PC_out <= PC;
IR_out <= IR;
oper_out <= oper;
CCR_out <= CCR;
end architecture;