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