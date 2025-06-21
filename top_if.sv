interface router_if (
    input clk
);
  logic reset;
  logic [7:0] dut_inp;
  logic inp_valid;
  logic [7:0] dut_outp;
  logic outp_valid;
  logic busy;
  logic [3:0] error;

  clocking cb @(posedge clk);
    output dut_inp;
    output inp_valid;
    input dut_outp;
    input outp_valid;
    input busy;
    input error;
  endclocking

  modport tb_mod_port(clocking cb, output reset);

endinterface

module top;
  logic clk;
  //Section2: Clock initiliazation and Generation
  initial clk = 0;
  always #5 clk = ~clk;
  // interface instatiaion
  router_if router_if_inst (clk);

  //Section3:  DUT instantiation
  router_dut dut_inst (
      .clk(clk),
      .reset(router_if_inst.reset),
      .dut_inp(router_if_inst.dut_inp),
      .inp_valid(router_if_inst.inp_valid),
      .dut_outp(router_if_inst.dut_outp),
      .outp_valid(router_if_inst.outp_valid),
      .busy(router_if_inst.busy),
      .error(router_if_inst.error)
  );

  //Section4:  Program Block (TB) instantiation
  testbench tb_inst (
      .clk(clk),
      .vif(router_if_inst.tb_mod_port)
  );

  //Section 6: Dumping Waveform
  /* initial begin
  $dumpfile("dump.vcd");
  $dumpvars(0,top.dut_inst); 
end
*/
endmodule
