# CPU_in_VHDL

## Project Description
This project implements a 16-bit RISC CPU using VHDL. The CPU is designed for multi-cycle execution and supports various arithmetic, logical, memory, and control instructions. The aim of this project is to design and implement a simple CPU that performs all essential operations, adhering to the RISC principles.

The design includes a complete set of components such as an Arithmetic Logic Unit (ALU), Register File, Memory Unit, Multiplexers, and Control Logic. It executes instructions in multiple cycles—fetching, decoding, executing, and writing back data.

For more details on the problem statement, refer to the [Project Question Paper PDF](Project_Question_Paper.pdf).

## Features
- **16-bit RISC ISA**: Implements a reduced instruction set, categorized into R-Type, I-Type, and J-Type instructions.
- **Multi-Cycle Execution**: Instruction execution is divided into 3 stages:
  1. Fetching the instruction and required data.
  2. Executing the required operations.
  3. Storing results and updating the Program Counter (PC).
- **Component-Based Design**: Includes an ALU, Register File, Memory Unit, Multiplexers, Sign Extensions, and Control Logic.
- **Fully developed in VHDL**, simulated using ModelSim, and synthesized with Quartus Prime.
- Supports instructions for arithmetic, logical, memory access, and branching operations.

## Repository Structure
The repository is organized as follows:

| File/Folder               | Description                                                              |
|---------------------------|--------------------------------------------------------------------------|
| `aluD.vhd`                | Implementation of the Arithmetic Logic Unit (ALU).                        |
| `register_16bit.vhd`      | VHDL code for a 16-bit register.                                          |
| `Memory_Unit.vhd`         | Implementation of the memory module for data storage.                    |
| `MUX_16BIT.vhd`           | 16-bit multiplexer used for data selection.                               |
| `MUX_3BIT.vhd`            | 3-bit multiplexer used for control signal selection.                      |
| `SE6.vhd`                 | Sign extension module for 6-bit to 16-bit conversion.                     |
| `SE9.vhd`                 | Sign extension module for 9-bit to 16-bit conversion.                     |
| `IITB_CPU.vhd`            | Top-level design file for the CPU.                                       |
| `testbench.vhd`           | Testbench file for simulating and validating the CPU.                     |
| `docs/`                   | Contains documentation files like the problem statement and report.       |
| `README.md`               | Project description and instructions (this file).                        |

## Supported Instructions

### R-Type Instructions
Used for arithmetic and logical operations.

| Instruction | Operation         | Description                           |
|-------------|-------------------|---------------------------------------|
| `ADD`       | `RD = RS + RT`    | Adds two registers.                   |
| `SUB`       | `RD = RS - RT`    | Subtracts one register from another.  |
| `AND`       | `RD = RS AND RT`  | Bitwise AND between two registers.    |
| `OR`        | `RD = RS OR RT`   | Bitwise OR between two registers.     |
| `MUL`       | `RD = RS * RT`    | Multiplies two registers.             |

### I-Type Instructions
Used for immediate operations and memory access.

| Instruction | Operation           | Description                           |
|-------------|---------------------|---------------------------------------|
| `ADDI`      | `RS = RS + IMM`     | Adds an immediate value to a register.|
| `LW`        | `RS = MEM[IMM]`     | Loads data from memory into a register.|
| `SW`        | `MEM[IMM] = RS`     | Stores data from a register into memory.|

### J-Type Instructions
Used for jump and branch operations.

| Instruction | Operation           | Description                           |
|-------------|---------------------|---------------------------------------|
| `J`         | `PC = Address`      | Jumps to a specified address.         |
| `BEQ`       | `if (RS == RT) PC = Address` | Branches if two registers are equal. |

## CPU Workflow
The CPU executes instructions in the following steps:

### Instruction Fetch and Data Preparation
- The Program Counter (PC) fetches the next instruction from memory.
- Decodes the instruction to identify the operation type (R-Type, I-Type, or J-Type).
- Fetches required data (registers, immediate values, or memory) based on the instruction type.

### Execution
- Performs the operation (arithmetic, logical, memory, or branch) as defined by the instruction.
- Utilizes the ALU for arithmetic/logical operations.
- For memory instructions, accesses data memory using calculated addresses.

### Write Back and PC Update
- Stores the result back into the target register or memory location.
- Updates the Program Counter (PC) for the next instruction.

## Software Used
- **ModelSim**: For simulating and testing the VHDL design.
- **Quartus Prime**: For synthesizing and verifying the hardware implementation.

## Documentation
- **[Project Question Paper PDF](Project_Question_Paper.pdf)**: Contains the original problem statement.
- **[Final Report](Final_Report_CPU.pdf)**: Detailed report of the project, including the design methodology and results.
