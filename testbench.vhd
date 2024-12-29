library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_IITB_CPU is
end tb_IITB_CPU;

architecture sim of tb_IITB_CPU is

    -- Component Declaration for DUT (Device Under Test)
    component IITB_CPU is
        port (
            clk, reset: in std_logic;
            R1o, R2o, R3o, R4o, R5o, R6o, R7o, R8o: out std_logic_vector(15 downto 0);
            mux_out: out std_logic_vector(19 downto 0);
            PC_out, IR_out, CCR_out: out std_logic_vector(15 downto 0);
            oper_out: out std_logic_vector(3 downto 0)
        );
    end component;

    -- Signals for driving DUT
    signal clk: std_logic := '0';
    signal reset: std_logic := '0';
    signal R1o, R2o, R3o, R4o, R5o, R6o, R7o, R8o: std_logic_vector(15 downto 0);
    signal mux_out: std_logic_vector(19 downto 0);
    signal PC_out, IR_out, CCR_out: std_logic_vector(15 downto 0);
    signal oper_out: std_logic_vector(3 downto 0);

    -- Clock period definition
    constant clk_period: time := 10 ns;

begin

    -- DUT Instantiation
    uut: IITB_CPU
        port map (
            clk => clk,
            reset => reset,
            R1o => R1o,
            R2o => R2o,
            R3o => R3o,
            R4o => R4o,
            R5o => R5o,
            R6o => R6o,
            R7o => R7o,
            R8o => R8o,
            mux_out => mux_out,
            PC_out => PC_out,
            IR_out => IR_out,
            CCR_out => CCR_out,
            oper_out => oper_out
        );

    -- Clock Generation
    clk_process: process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Stimulus Process
    stimulus_process: process
    begin
        -- Scenario 1: Reset Test
        report "Test 1: Reset Behavior";
        reset <= '1';
        wait for 20 ns;
        reset <= '0';
        wait for 20 ns;

        assert (PC_out = "0000000000000000") report "PC not reset correctly" severity failure;
        assert (R1o = (others => '0')) report "Register R1 not reset correctly" severity failure;

        -- Scenario 2: Load Instruction
        report "Test 2: LOAD Instruction";
        -- Simulate a LOAD instruction; update IR with appropriate opcode and address
        wait for 20 ns;

        -- Check outputs
        assert (R1o = "0000000000001010") report "LOAD instruction failed" severity failure;

        -- Scenario 3: Arithmetic Operation (ADD)
        report "Test 3: ADD Instruction";
        -- Simulate an ADD instruction
        wait for 20 ns;

        -- Check outputs
        assert (R1o = R2o + R3o) report "ADD operation failed" severity failure;

        -- Scenario 4: Branch Operation (JUMP)
        report "Test 4: JUMP Instruction";
        -- Simulate a JUMP instruction
        wait for 20 ns;

        -- Check outputs
        assert (PC_out = "0000000000001111") report "JUMP instruction failed" severity failure;

        -- Scenario 5: Conditional Branch (BEQ)
        report "Test 5: BEQ Instruction";
        -- Simulate a BEQ instruction
        wait for 20 ns;

        -- Check outputs
        if (CCR_out = "0001") then
            assert (PC_out = "0000000000010000") report "BEQ instruction failed when condition met" severity failure;
        else
            assert (PC_out /= "0000000000010000") report "BEQ instruction failed when condition not met" severity failure;
        end if;

        -- Scenario 6: Memory Interaction
        report "Test 6: Memory Interaction";
        -- Simulate memory read/write
        wait for 20 ns;

        -- Check outputs
        assert (mux_out = "0000000000010101") report "Memory interaction failed" severity failure;

        -- Add more scenarios as needed for testing all functionality

        -- End of tests
        report "All tests completed successfully" severity note;
        wait;
    end process;

end sim;
