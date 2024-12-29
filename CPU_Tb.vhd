library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity CPU_Tb is
end entity;

architecture rtl of CPU_Tb is

component IITB_CPU is
    port (
        clk, reset: in std_logic;
		  R1o,R2o,R3o,R4o,R5o,R6o,R7o,R8o :  out std_logic_vector(15 downto 0);
		  mux_out : out std_logic_vector(19 downto 0);
		  PC_out,IR_out,CCR_out: out std_logic_vector(15 downto 0);
		  oper_out: out std_logic_vector(3 downto 0)
		  );
end component;

signal R1o,R2o,R3o,R4o,R5o,R6o,R7o,R8o : std_logic_vector(15 downto 0);
signal clk,reset : std_logic := '0';
signal mux_out : std_logic_vector(19 downto 0);
signal PC_out,IR_out,CCR_out : std_logic_vector(15 downto 0);
signal oper_out: std_logic_vector(3 downto 0);
begin
 
cpu_inst: IITB_CPU port map (clk,reset,R1o,R2o,R3o,R4o,R5o,R6o,R7o,R8o,mux_out,PC_out,IR_out,CCR_out,oper_out);

clock_proc: process
begin
	wait for 20 ns;
	clk <= not clk;
end process;

end architecture;