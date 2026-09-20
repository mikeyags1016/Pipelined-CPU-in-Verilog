# Pipelined-CPU-in-Verilog

- Implement an OOP Pipelined RB32I RISC-V CPU:
    - 32 Bit integer arithmetic
    - Single-issue (one instruction fetch at a time) single core
    - Best CPI = 1
    - 5 Stage RISC Pipeline (inorder for now, OO later)
    - 37 base instructions
    - R, I, S, B, U, J instructions types
    - 32 general purpose registers
    - Includes instruction assembler
    - Separate bus interface for Instruction and Data mem access
    - Baremetal Apps
    - Little endian memory space