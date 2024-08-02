# Sine_Generator
Design and simulation of fixed and variable frequency sine wave generators using the Verilog language
---
***
## Problems posed
- Specifications
- Methodologys
- Design
- Simulation
- Assess
## Theoretical basis
- A signal is a physical qunatity that carries information or data that can travel far and separate information
- A sine signal is a type of analog signal signal that continously changes over time and has a sine modulated oscillation
![Sine](/FLOWCHART/Sine.jpg)
- Mathemattical equations: u(t) = A * sin(2πft + θ)

## Design features
|Parameters|LUT combined with DDS|CORDIC| 
|-------------------|--------------|-------------|
|Frequency|5MHz(variable)|500kHz(fixed)|
|Clock Frequency|500MHz|100MHz| 
|Amplitude|-32768 $\to$ 32767|-1 $\to$ 1| 
|Dimensions ROM|10bit|Not use|
|Resoluttion|16bit|16bit|
|Phase Resoluttion| $0.3^o$ |Unlimited|
|Fcw(Frequency accumulator|24bit|Not use|
|Dimensions Accu|24bit|Not use|
|Phase|0 $\to$ $360^o$|-π $\to$ π|
## Design based on LUT combined with DDS
### LUT
### DDS
### Flowchart
![DDS_block](/FLOWCHART/DDS_block.png)
### RTL code
```verilog
module sine_dds(
    input clk ,
    input reset,
    input [23:0] fcw,
    output [15:0] dds_sin
    );
    
    reg [15:0] rom_memory [1023:0];
        
    initial begin
        $readmemh("sine.mem", rom_memory);
    end
        
    reg [23:0] accu;
    reg [1:0] fdiv_cnt;
    wire accu_en;
    wire [9:0] lut_index;
              
    //process for frequency divider
    always@( posedge clk)
        begin
            if(reset == 1'b1)
                fdiv_cnt <= 0; //synchronous reset
            else if(accu_en == 1'b1)
                fdiv_cnt <= 0; 
            else    
                fdiv_cnt <= fdiv_cnt +1;    
        end
        
    //logic for accu enable signal, resets also the frequency divider counter
    assign accu_en = (fdiv_cnt == 2'd2) ? 1'b1 : 1'b0;
        
    //process for phase accumulator
    always@(posedge clk)
        begin
            if(reset == 1'b1)         
                accu <= 0; //synchronous reset
            else if(accu_en == 1'b1)
                accu <= accu + fcw;
        end
        
    //10 msb's of the phase accumulator are used to index the sinewave lookup-table
    assign lut_index = accu[23:14];
            
    //16-bit sine value from lookup table
    assign dds_sin = rom_memory[lut_index];
        
endmodule
```
### Testbench
```verilog
`timescale 1ns / 1ps
module sine_dds_tb;

    // Inputs
    reg clk;
    reg reset;
    reg [23:0] fcw;
    
    // Outputs
    wire [15:0] dds_sin;
        
    // Instantiate sine_dds module
    sine_dds dut (
        .clk(clk),
        .reset(reset),
        .fcw(fcw),
        .dds_sin(dds_sin)
    );
    
    // Clock generation (500 MHz)
    always #1 clk = ~clk;
    
    // Stimulus generation
    initial begin
        clk = 0;
        reset = 1'b1;
        #2;
                
        reset = 1'b0;
        #2;
                
        // Set fcw for 5 MHz (8000 ns = 8 ms)
        fcw = 24'b0000_0111_1010_1110_0001_0100;
        #8000;
            
        
        fcw = 24'b0000_0001_0000_0000_0000_0000;
        #5000;
            
        
        fcw = 24'b0000_0100_0000_0000_0000_0000;
        #3000;
        $finish;
      end
  
endmodule
```
### Schematic
![DDS_schematic](/FLOWCHART/DDS_schematic.png)
### Simulation
- Sine wave with variable frequency
![DDS_sinewave](/VERIFICATION/DDS_sinewave.png)
### Result
|Parameters|Specifications|Simulation|Deviation|
|----------|--------------|----------|---------|
|Frequency|5MHz(variable)|4.9MHz(variable)|2%|
|Amplitude|-32768 $\to$ 32767|-32768 $\to$ 36779|0.03%| 
|Dimensions ROM|10bit|10bit|0%|
|Resoluttion|16bit|16bit|0%|
|Phase Resoluttion| $0.3^o$ |$0.3^o$|0%|
|Fcw(Frequency Control Word)|24bit|24bit|0%|
|Dimensions Accu|24bit|24bit|0%|
|Phase|0 $\to$ $360^o$|0 $\to$ $360^o$|0%|
## Design based on CORDIC IP
### CORDIC
Coordinate Rotation Digital Computer (CORDIC), invented by J.E.Volder in 1959, is an algorithm that can be used to perform trigonometry-related calculations. The CORDIC algorithm is derived from tthe rotation of vectors according to Cartesian coordinates.
### Flowchart
![CORDIC_block](/FLOWCHART/CORDIC_block.png)
### Schematic
![CORDIC_schematic](/FLOWCHART/CORDIC_schematic.png)
### Simulation
![CORDIC_block](/FLOWCHART/CORDIC_block.png)


