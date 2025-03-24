
module memalloc;

  int d1[];
  initial
  begin
  $display(d1.size());
  #10 d1=new[2];
  $display(d1.size());
  end
  endmodule
