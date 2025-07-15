program testbench (
    input clk,
    router_if vif
);

  //Section4: TB Variables declarations. 
  //Variables required for various testbench related activities . 
  //ex: class handles

  //Section 4.1 : Include packet,generator,driver,iMonitor,oMonitor and scoreboard classes
  `include "packet.sv"
  `include "Generator.sv"
  `include "Driver.sv"
  //Section 4.1.1 : Include iMonitor,oMonitor and scoreboard classes
  `include "Imonitor.sv"
  `include "Omonitor.sv"
  `include "scoreboard.sv"
  //Section 4.2 : Define generator,driver,iMonitor,oMonitor,scoreboard and mailbox class handles

  generator gen;
  driver drvr;
  mailbox #(packet) mbx;

  //Section 4.2.1 : Define iMonitor,oMonitor,scoreboard class handles
  iMonitor iMon;
  oMonitor oMon;
  scoreboard scb;
  //Section 4.2.2 : Define mailbox class handles

  //Mailbox To connect iMonitor->scoreboard
  mailbox #(packet) mbx_iMon_scb;
  //Mailbox To connect oMonitor->scoreboard
  mailbox #(packet) mbx_oMon_scb;
  //Section 4.3 : Stimulus packet count 
  bit [15:0] pkt_count;

  //Section 6: Verification Flow
  initial begin
    //Section 6.1 : How many number of packets to generate
    pkt_count = 10;

    //Section 6.2 : Construct objects for mailbox,generator and driver.
    mbx = new(1);
    gen = new(mbx, pkt_count);
    drvr = new(mbx, vif.tb_mod_port);  //Change modport type TODO

    //Section 6.2.1 : Construct objects for mailbox.

    mbx_iMon_scb = new();
    mbx_oMon_scb = new();
    //Section 6.2.2 : Construct objects for iMon,oMon and scb and Connect mailboxes and interfaces
    iMon = new(mbx_iMon_scb, vif.tb_mon);
    oMon = new(mbx_oMon_scb, vif.tb_mon);
    scb = new(mbx_iMon_scb, mbx_oMon_scb);

    //Section 6.3 : Start generator and driver

    fork
      gen.run();
      drvr.run();
      //Section 6.3.1 : Start iMon,oMon and scoreboard
      iMon.run();
      oMon.run();
      scb.run();
    join_any

    //Wait for dut to process the packet and to drive on output
    //Section 6.4 : Wait until scoreboard received all packets from iMonitor and oMonitor
    wait (scb.total_pkts_recvd == pkt_count);  //Test termination
    repeat (5) @(vif.cb);  //drain time

    //Section 6.4.1 : Print results of iMonitor,oMonitor and scoreboard
    iMon.report();
    oMon.report();
    scb.report();


    $finish;
  end
endprogram




