module top;

  //Section1: Variables for Port Connections Of DUT and TB.
  logic clk;
  logic reset;
  logic [7:0] dut_inp;
  logic inp_valid;
  logic [7:0] dut_outp;
  logic outp_valid;
  logic busy;
  logic [3:0] error;
  //Section2: Clock initiliazation and Generation
  initial clk = 0;
  always #5 clk = ~clk;

  //Section3:  DUT instantiation
  router_dut dut_inst (
      .clk(clk),
      .reset(reset),
      .dut_inp(dut_inp),
      .inp_valid(inp_valid),
      .dut_outp(dut_outp),
      .outp_valid(outp_valid),
      .busy(busy),
      .error(error)
  );

  //Section4:  Program Block (TB) instantiation
  testbench tb_inst (
      .clk(clk),
      .reset(reset),
      .dut_inp(dut_inp),
      .inp_valid(inp_valid),
      .dut_outp(dut_outp),
      .outp_valid(outp_valid),
      .busy(busy),
      .error(error)
  );

  //Section 6: Dumping Waveform
  /* initial begin
  $dumpfile("dump.vcd");
  $dumpvars(0,top.dut_inst); 
end
*/
endmodule
