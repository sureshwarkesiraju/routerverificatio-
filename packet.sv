class packet;

  rand bit [7:0] sa;
  rand bit [7:0] da;
  bit [31:0] len;
  bit [31:0] crc;
  rand bit [7:0] payload[];
  bit [7:0] inp_stream[$];
  bit [7:0] outp_stream[$];



  //Print function
  function void print();
    $write("[TB Packet] Sa=%0d Da=%0d Len=%0d crc=%0d", sa, da, len, crc);
    foreach (payload[k]) $write("[TB Packet] Payload[%0d]=%0d\n", k, payload[k]);
  endfunction


  //Pack function
  function void pack(ref bit [7:0] q_inp[$]);
    q_inp = {<<8{this.payload, this.crc, this.len, this.da, this.sa}};
  endfunction

  // Unpack function
  function void unpack(ref bit [7:0] q_inp[$]);
    {<<8{this.payload, this.crc, this.len, this.da, this.sa}} = q_inp;
  endfunction

  constraint valid {
    sa inside {[1 : 8]};
    da inside {[1 : 8]};
    payload.size() inside {[2 : 1900]};
    foreach (payload[i]) payload[i] inside {[0 : 255]};
  }

  function void post_randomize();
    len = payload.size() + 1 + 1 + 4 + 4;
    crc = payload.sum();
    this.pack(inp_stream);
  endfunction

  function void copy(packet rhs);
    if (rhs == null) begin
      $display("[ERROR] Empty packet recived");
      $finish;
    end
    this.sa = rhs.sa;
    this.da = rhs.da;
    this.len = rhs.len;
    this.crc = rhs.crc;
    this.payload = rhs.payload;
    this.inp_stream = rhs.inp_stream;
  endfunction


  function bit compare(input packet dut_pkt);
    bit status;
    status = 1;

    foreach (dut_pkt.inp_stream[i]) begin
      $display(this.inp_stream[i]);
      $display(dut_pkt.outp_stream[i]);
      status = status && (this.inp_stream[i] == dut_pkt.outp_stream[i]);
    end
    return status;
  endfunction
endclass
