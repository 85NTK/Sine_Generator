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
- The direct look-up table (LUT) method is a simple algorithm, based on reading memorized sine patterns from a table. The memorizedverilog
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



