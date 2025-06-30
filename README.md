# Single-Cycle 32-bit MIPS Processor

## Overview
This project implements a single-cycle 32-bit MIPS processor in Verilog that supports a subset of core MIPS instructions. The processor executes each instruction in a single clock cycle using a modular design. It includes support for arithmetic, logical, memory access, control flow, and subroutine instructions.

## Supported Instructions
- **Memory Reference**: `lw`, `sw`
- **Arithmetic-Logical**: `add`,`sub`,`and`,`or`,`slt`
- **Control Transfer**: `beq`, `j`
- **Subroutine**: `jal`

## Modules

### 1. ALU (Arithmetic Logic Unit)
Performs operations based on 3-bit control signal:
- `000`: AND
- `001`: OR
- `010`: ADD
- `110`: SUBTRACT
- `111`: SET LESS THAN

Handles 2’s complement for subtraction and SLT.

### 2. ALU Control Unit
Generates `AluCtrl` signals from `AluOp` and function field:
- `00`: Load/Store → ADD
- `01`: Branch equal → SUBTRACT
- `10`: R-type → Decoded using `FnField`

### 3. Multiplexer
Generic MUX with parameterized bit-width (`DATA_LENGTH`). Selects between two inputs based on a selector.

### 4. Program Counter Logic
Determines next instruction address:
- Resets to 0
- Increments by 1 (default)
- Updates on branch (`beq`) or jump (`j`, `jal`)

### 5. Register File
32 registers (32-bit each):
- Two read ports (`ra`, `rb`) and one write port (`rc`)
- Write on rising clock edge if `regWrite` is enabled
- Register 0 is hardwired to 0

### 6. Sign Extension
Extends 16-bit immediate to 32-bit with sign bit preserved.

### 7. Data Memory
- 64-entry memory (32-bit width)
- Supports `read_enable` and `write_enable`
- Writes occur on clock edge

### 8. Instruction Memory
- Preloaded with test program
- Supports read-only access

### 9. Datapath
Integrates all modules:
- Fetch → Decode → Execute → Memory → Write-back
- Handles operand selection, ALU operation, memory access, and register update

### 10. Control Path
Generates control signals based on opcode:
- R-type: determined by function field
- Memory: load/store control
- Branch/Jump: based on ALU zero flag and opcode

## Testing
The processor was tested by preloading instruction and data memories with a meaningful program that:
- Initialises an array with values 0 to 4
- Computes their sum using a loop
- Stores the result in memory

## Constraints
- Only structural modeling (no behavioral modeling)
- Simulation only (no FPGA or physical hardware required)
