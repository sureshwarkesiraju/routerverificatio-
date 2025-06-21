program testbench (
    input clk,
    router_if vif
);

  //Section 1: Define variables for DUT port connections
  /*  input clk;
  input [7:0] dut_outp;
  input outp_valid;
  input busy;
  input [3:0] error;
  output reg reset;
  output reg [7:0] dut_inp;
  output reg inp_valid;
*/

  //Section 4: TB Variables declarations. 
  //Variables required for various testbench related activities . ex: stimulus generation,packing ....
  //TODO
  typedef struct {
    bit [7:0]  sa;
    bit [7:0]  da;
    bit [31:0] len;
    bit [31:0] Crc;
    bit [7:0]  payload[];
  } packet;

  bit [7:0] inp_stream [$];
  bit [7:0] outp_stream[$];
  packet stimulus_pkt, dut_pkt, Q_in[$], Q_out[$];
  bit [31:0] count;
  //Section 5: Methods (functions/tasks) definitions related to Verification Environment

  task apply_reset();
    //TODO
    $display("[TB reset] Applied reset to DUT");
    vif.reset <= 1;
    repeat (2) @(vif.cb);
    vif.reset <= 0;
    $display("[TB Reset] Reset completed");
  endtask


  //Generate function
  function automatic void generate_stimulus(ref packet pkt);
    pkt.sa = $urandom_range(1, 8);
    pkt.da = $urandom_range(1, 8);
    pkt.payload = new[$urandom_range(10, 20)];
    foreach (pkt.payload[i]) pkt.payload[i] = $urandom_range(2, 1900);
    pkt.len = pkt.payload.size() + 4 + 4 + 1 + 1;
    pkt.Crc = pkt.payload.sum();
    $display("[TB Generate] packet (size=%0d) at time =%0t", pkt.len, $time);
  endfunction




  // Drive function
  task automatic drive(const ref bit [7:0] inp_stream[$]);
    wait (vif.cb.busy == 0);  //wait utill router is ready to accept packets
    @(vif.cb);
    $display("[TB Drive] Driving of packet started at time=%0t", $time);
    // $display("[TB reviced packet (in_stream) ]", inp_stream);
    vif.cb.inp_valid <= 1;
    foreach (inp_stream[i]) begin
      vif.cb.dut_inp <= inp_stream[i];
      @(vif.cb);
    end
    vif.cb.inp_valid <= 0;
  endtask


  //Print function
  function void print(input packet pkt);
    $display("[TB Packet] Sa=%0d Da=%0d Len=%0d Crc=%0d", pkt.sa, pkt.da, pkt.len, pkt.Crc);
    foreach (pkt.payload[k]) $display("[TB Packet] Payload[%0d]=%0d", k, pkt.payload[k]);
  endfunction


  //Pack function
  function automatic void pack(ref bit [7:0] q_inp[$], input packet pkt);
    q_inp = {<<8{pkt.payload, pkt.Crc, pkt.len, pkt.da, pkt.sa}};
  endfunction

  // Unpack function
  function automatic void unpack(ref bit [7:0] q_out[$], inout packet pkt);
    {<<8{pkt.payload, pkt.Crc, pkt.len, pkt.da, pkt.sa}} = q_out;
  endfunction

  // Compare function
  function bit compare(packet ref_pkt, packet dut_pkt);
    return ((ref_pkt == dut_pkt) ? 1 : 0);
  endfunction

  //Result function
  function void result();
    bit [31:0] matched;
    bit [31:0] mis_matched;

    if (Q_in.size() == 0) begin
      $display("[TB Error] Q - Input is empty , no packets in Q_in");
      $finish;
    end
    if (Q_out.size() == 0) begin
      $display("[TB Error] Q - Output is empty , no packets in Q_out");
      $finish;
    end

    foreach (Q_in[i]) begin
      if (compare(Q_in[i], Q_out[i])) matched++;
      else begin
        mis_matched++;
        $display("[Error] packet %d Mismatching", i);
      end
    end  //foreach end

    if (mis_matched == 0 && matched == count) begin
      $display("**********************************************************");
      $display("********************** TEST PASSESD **********************");
      $display("************** [INFO] All pakckets matched ***************");
      $display("************** [INFO] matched =%0d mismatched =%0d **********", matched,
               mis_matched);
      $display("**********************************************************");
    end else begin
      $display("[INFO] There is mismatch in  packets");
      $display("[INFO] matched =%d mismatched =%d", matched, mis_matched);
      $display("[INFO] Check which packets are mismatched in section 5");
    end
  endfunction



  //--------End of Section 5 ----------------  


  //Section 6: Verification Flow
  initial begin
    //TODO
    count = 10;
    apply_reset();
    repeat (count) begin
      inp_stream.delete();
      wait (vif.cb.busy == 0);
      generate_stimulus(stimulus_pkt);
      //print(stimulus_pkt);
      pack(inp_stream, stimulus_pkt);
      Q_in.push_back(stimulus_pkt);
      drive(inp_stream);
      repeat (5) @(vif.cb);
    end
    //Wait for dut to process the packet and to drive on output

    wait (vif.cb.busy == 0);
    repeat (10) @(vif.cb);

    if (Q_out.size() == 0) begin
      $display("[TB error]  There are no packets to compare");
      $finish;
    end
    result();
    $finish;
  end

  //--------End of Section 6 ---------------- 



  //Section 7: Dumping Waveform
  //TODO

  //--------End of Section 7 ---------------- 

  //Section 8: Collect DUT output
  //TODO 
  initial begin
    forever begin
      @(posedge vif.cb.outp_valid);
      repeat (inp_stream.size()) begin
        if (vif.cb.outp_valid == 0) break;
        outp_stream.push_back(vif.cb.dut_outp);
        @(vif.cb);
      end  // end of while
      //$display("[TB reviced packet OUT]", outp_stream);
      unpack(outp_stream, dut_pkt);
      Q_out.push_back(dut_pkt);
      outp_stream.delete();
    end  //end of forever
  end  //end of initial begin
endprogram
