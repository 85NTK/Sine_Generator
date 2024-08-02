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
- Mathemattical equations: u(t) = A * sin(2πft + θ)
## Design features
|Parameters|LUT combined with DDS|CORDIC| 
|-------------------|--------------|-------------|
|Frequency|5MHz(variable)|500kHz(fixed)|
|Clock Frequency|500MHz|100MHz| 
|Amplitude|-32768 $\to$ 32767|-1 $\to$ 1| 
|Kích thước ROM|10bit|Not use|
|Resoluttion|16bit|16bit|
|Phase Resoluttion| $0.3^o$ |Unlimited|
|Fcw(Frequency Control Word)|24bit|Not use|
|Dimensions Accu|24bit|Not use|
|Phase|0 $\to$ $360^o$|-π $\to$ π|
## Design based on LUT combined with DDS
The direct look-up table method (LUT) is a simple algorithm, based on reading memorized sine patterns from a table. The memorized patterns represent the values of the sine function for N evenly spaced angles around the ring in the unit, in the range 0 - 360° (0 - 2π).
The Direct Digital Synthesizer technique (DDS) is a method of generating sine waves based on the principle of:
- Phase Accumulation: based on the desired frequency, a phase value in continously accumulated over time
- Sampling the look-up table: The cumulative phase value is used as an index for a predefined sine value look-up table (usually stored in ROM memory). We can easily create a value look-up table using an [online sine generator](https://www.daycounter.com/Calculators/Sine-Generator-Calculator.phtml) and then paste it into a .mem file
![Sine_LUT_generate_online](/FLOWCHART/Sine_LUT_generate_online.png)
![sine_mem](/FLOWCHART/sine_mem.png)
### Flowchart
![DDS_flowchart](/FLOWCHART/DDS_block.png)
### RTL Code
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

