Implementation of ARMv3 Processor supporting the following instructions:
- LDR and STR instructions with positive and negative immediate offset
- AND, SUB, ADD, ORR, CMP, CMN instructions with immediate or register shifted by immediate as Src2
- DP instructions can set N, Z, C, V flags used for conditional execution
- B instructions


ARM.v
Datapath Connections 
Components of ARM processor (RegFile, Extend, Decoder, CondLogic, Shifter, ALU, ProgramCounter)


CondLogic.v
Instruction is only executed (CondEx = 1) depending on condition mnemonic (Cond[3:0]) and condition flags (NZCV)
NZCV flags are also updated based on FlagW and CondEx


Decoder.v
Decodes instruction to generate signals which control other components of processor such as ALU, PC, ImmediateExtend 
and datapath connections.


Wrapper.v
Contains Instruction Memory and Data Memory.
Decoding of address for accessing memory and memory-mapped peripherals. 


test_Wrapper.v
Simulation testbench for verifying ARM processor.
Stimuli for Countdown Game

Countdown_Game.s
Assembly program to check the functionality required for Lab 2 processor.
Also includes a CountDown game. 
Counter counts down from 10 to 0. 
Seven Segment only displays counter 10, 9, 8 for the first 3 counts. 
The player who presses their respective Pushbutton closest to 0 wins.
Counter counts back up to 2 after reaching 0 before displaying winner.
Player who presses button after counter reaches 0 will have absolute value of time after 0 recorded.


Lab2Countdown.bit

Simulation Screenshots

Lab 2 Report

