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
|Parameters|DDS Combinations LUTs|CORDIC| 
|-------------------|--------------|-------------|
|Frequency|5MHz(variable)|500kHz(fixed)|
|Clock Frequency|500MHz|100MHz| 
|Amplitude|-32768 $\to$ 32767|-1 $\to$ 1| 
|Kích thước ROM|10bit|Not use|
|Resoluttion|16bit|16bit|
|Phase Resoluttion| $0.3^o$|             |
| Fcw              |              |             |
| Kích thước Accu   |              |             |
| Pha              |              |             |


