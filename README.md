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
| Thông số           | LUT và DDS   | CORDIC     | Tần số (thay đổi) | Tần số xung clock | Biên độ               | Kích thước ROM | Độ phân giải | Độ phân giải pha | Fcw        | Kích thước Accu | Pha          |
|-------------------|--------------|-------------|-------------------|-------------------|-----------------------|---------------|---------------|-------------------|------------|----------------|--------------|
| Tần số            | 5MHz         | 500kHz      | 5MHz             | 500MHz            | -32768→32767         | 10 bit        | 16 bit         | 〖0.3〗^°         | 24 bit     | 24 bit         | 0→360°      |
| Tần số xung clock | 500MHz       | 100MHz      | Cố định          |                  | -1→1                | Không sử dụng | 16 bit         | Không giới hạn | Không sử dụng | Không sử dụng | -π→π        |
| Biên độ           |              |             |                  |                  |                      |               |               |                  |            |                |              |
| Kích thước ROM    |              |             |                  |                  |                      |               |               |                  |            |                |              |
| Độ phân giải     |              |             |                  |                  |                      |               |               |                  |            |                |              |
| Độ phân giải pha |              |             |                  |                  |                      |               |               |                  |            |                |              |
| Fcw              |              |             |                  |                  |                      |               |               |                  |            |                |              |
| Kích thước Accu   |              |             |                  |                  |                      |               |               |                  |            |                |              |
| Pha              |              |             |                  |                  |                      |               |               |                  |            |                |              |


