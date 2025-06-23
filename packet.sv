class packet;

  bit [7:0] sa;
  bit [7:0] da;
  bit [31:0] len;
  bit [31:0] Crc;
  bit [7:0] payload[];
  bit [7:0] inp_stream[$];
  bit [7:0] outp_stream[$];



  //Print function
  function void print();
    $write("[TB Packet] Sa=%0d Da=%0d Len=%0d Crc=%0d", sa, da, len, Crc);
    foreach (payload[k]) $write("[TB Packet] Payload[%0d]=%0d", k, payload[k]);
  endfunction


  //Pack function
  function automatic void pack(ref bit [7:0] q_inp[$]);
    q_inp = {<<8{this.payload, this.Crc, this.len, this.da, this.sa}};
  endfunction

  // Unpack function
  function automatic void unpack(ref bit [7:0] q_inp[$]);
    {<<8{this.payload, this.Crc, this.len, this.da, this.sa}} = q_inp;
  endfunction
endclass
