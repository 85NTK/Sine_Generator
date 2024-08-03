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
- The direct look-up table (LUT) method is a simple algorithm, based on reading memorized sine patterns from a table. The memorized patterns represent the values of sine function for N evenly spaced around the ring in the unit, in the range 0 - 360° (0 - 2π)
![LUT](/FLOWCHART/LUT.png)
- We can easily create a value look-up table using the [online sine generator tool](https://www.daycounter.com/Calculators/Sine-Generator-Calculator.phtml) and then paste the values into a .mem file
![Sine_LUT_generate_online](/FLOWCHART/Sine_LUT_generate_online.png)
![sine_mem](/FLOWCHART/sine_mem.png)
### DDS
Direct Digital Synthesizer (DDS) technique is a method of generating sine waves based on the principle of:
- Phase Accumulation: based on the desired frequency, a phase value is continously accumulated over time
- Look-up table sampling: the cumulative phase value is used as an index for a predetermined sine value look-up table (usually stored in ROM memory)
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
- The formula for the contact between fcw and the output sine frequency: $fcw=(2^n*f_{out})/f_{sampling}$ with n is the nuumber of bits of the phase accumulator
- The module is designed to sample every 3 clock cycles. With clock frequency equal to 500MHz and a required output frequency of 5 MHz $\to$ $fcw = 24'b0000 0111 1010 1110 0001 0100$
- The maximum frequency that a module can produce follows Nyquist's theorem: $f_{max}≤f_{sampling}/2⇒f_{max}=83,3MHz$
- The minimum frequency that the module produces is based on the smallest boost of fcw: $f_{min}=(fcw×f_{sampling})/2^n =(1×500MHz/3)/2^24 =9,93Hz$
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
#### Sine wave with variable frequency
![DDS_sinewave](/VERIFICATION/DDS_sinewave.png)
#### Sine wave with frequency 5MHz
![DDS_sinewave5MHz](/VERIFICATION/DDS_sinewave5MHz.png)
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
### RTL code
```verilog
/*
 * Sine/cosine generator using CORDIC algorithm IP
 * Verilog + AMD Xilinx Vivado
 */

module sincos(
    input clk,                  // Input clock
    input [15:0] phase,         // Phase input, fixed-point 1,2,13
    input phase_tvalid,         // phase valid strobe

    output [15:0] cos,
    output [15:0] sin,
    output sincos_tvalid       // Sine/cosine valid strobe
    );

    // Instantiate IP
    cordic_0 cordic_0_inst(
        .aclk                   (clk),
        .s_axis_phase_tvalid    (phase_tvalid),
        .s_axis_phase_tdata     (phase),
        .m_axis_dout_tvalid     (sincos_tvalid),
        .m_axis_dout_tdata      ({sin, cos})
    );

endmodule
```
### Testbench
-  The formula for the relationship between the output sine wave frequency and the PHASE_INC value with clock frequency equal to 100MHz and output frequency is 500kHz: $f_{out}=1/(2×25736/(PHASE_{INC})×10ns)=500kHz⇒PHASE_{INC}≈257$
- The maximum frequency that a module can produce follows Nyquist's theorem: $f_{max}≤f_{sampling}/2⇒f_{max}=50MHz$
- The minimum frequency that the module produces is based on the smallest boost of PHASE_{INC}: $f_{min}=1/(2×25736/1×10ns)=1.943kHz$
```verilog
/*
 * Testbench for sine/cosine generator
 * Verilog + AMD Xilinx Vivado
 */

`timescale 1 ns / 10 ps
module sincos_tb();

    localparam CLK_PERIOD = 10;             // To create 100MHz clock
    localparam signed [15:0] PI_POS = 16'b 0110_0100_1000_1000;     // +pi in fixed-point 1,2,13
    localparam signed [15:0] PI_NEG = 16'b 1001_1011_0111_1000;     // -pi in fixed-point 1,2,13
    localparam PHASE_INC = 256;           // Phase sweep value
    
    reg clk = 1'b0;
    reg rst = 1'b1;
    
    reg signed [15:0] phase = 0;
    reg phase_tvalid = 1'b0;
    wire signed [15:0] cos, sin;
    wire sincos_tvalid;
    
    // Instantiate sine/cosine generator module
    sincos sincos_inst(
        .clk            (clk),
        .phase          (phase),
        .phase_tvalid   (phase_tvalid),
        .cos            (cos),
        .sin            (sin),
        .sincos_tvalid  (sincos_tvalid)
    );
    
    // Drive clock and reset
    initial begin
        clk = 1'b0;
        rst = 1'b1;
        rst = #(CLK_PERIOD*10) 1'b0;
    end
    
    always begin
        clk = #(CLK_PERIOD/2) ~clk;
    end
    
    //Drive phase input
    always @(posedge clk)
    begin
        if (rst) begin
            phase <= 0;
            phase_tvalid <= 1'b0;
        end else begin
            phase_tvalid <= 1'b1;
            // Sweep the phase around the unit circle
            if (phase+PHASE_INC < PI_POS) begin
                phase <= phase + PHASE_INC;
            end else begin
                phase <= PI_NEG;
            end
        end
    end

endmodule
```
### Schematic
![CORDIC_schematic](/FLOWCHART/CORDIC_schematic.png)
### Simulation
#### Sine wave 5kHz with CORDIC IP
![CORDIC_block](/VERIFICATION/CORDIC_sinewave.png)
#### Sine wave are skewed when the PHASE_{INC} is too high
![CORDIC_sinewave_distortion](/VERIFICATION/CORDIC_sinewave_distortion.png)
### Result
|Parameters|Specifications|Simulation|Deviation|
|----------|--------------|----------|---------|
|Frequency|500kHz(fixed)|497.5kHz(fixed)|0.005%|
|Amplitude|-1 $\to$ 1|-1 $\to$ 0.|0.01%| 
|Phase|-π $\to$ π|-π $\to$ π|0%|
## Conclude
| Criteria | LUT combined with DDS | CORDIC Algorithm |
|---|---|---|
| Accuracy | Can achieve high accuracy if the table is stored with sufficient resolution | Accuracy depends on the number of iterations used |
| Speed | Faster than CORDIC, especially for low accuracy | Slower than LUT, but speed can be improved by optimizing the algorithm |
| Memory | Requires large memory to store the table | Requires less memory than LUT |
| Flexibility | Difficult to change accuracy or angle range after design | Easy to change accuracy or angle range by adjusting the number of iterations |
| Implementation | Easy to implement in both hardware and software | Easy to implement in hardware, but may be more difficult to implement in software |
## Application
### LUT combined with DDS
- An important application of the sine waves generated by this method is pulse width modulation (PWM).
![PWM](/FLOWCHART/PWM.png)
- The sine wave will be the input of the pulse width modulator, which will produce a series of periodic pulses whose duration is directly proportional to the input value. The value of the input sine wave will be compared with the value of the serrated wave, when the value of the serrated signal is greater then the output pulse is set at a high level and vice versa
![PWM_wave](/FLOWCHART/PWM_wave.png)
### CORDIC
- Sine wave generators with CORDIC IP play an important role in radar systems, providing the ability to generate accurate and efficient radar pulses
## Development direction
### Corrects Distortion of sine waves generated by CORDIC IP at high frequencies
- Reducing PHASE_INC value
- Clock Frequency Increase
- Proper PI value representation to avoid phase overflow
- Change the scan angle from 2π to 0.5π or π
### Expanded functionality
- Amplitude change: allows the user to adjust the amplitude of the sine wave
- Add other waveforms: in addition to sine waves, other waveforms can be added such as triangle waves, square waves, etc.
- Frequency scan: automatically changes the frequency of the sine wave according to a certain frequency range
- Modulation: allows modulation of sine waves with other signals to produce more complex waveforms
### Optimize performance
- Resource reduction: use optimization techniques to minimize the amount of hardware resources required for the design
- Speed increase: algorithm optimization and Verilog code to improve sine wave generation speed
- Reduce power consumption: use energy-saving design techniques to reduce the power consumption of the sine wave generator
