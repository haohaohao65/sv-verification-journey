module tb_data_types;

//1.来自例2.2的声明
bit [7:0] b_val;       //二状态，无符号
byte      b8_signed;      //二状态，有符号
logic [7:0] iport;     //四状态，模拟硬件接口

initial begin
     //观察byte 的符号位溢出
     b8_signed = 8'hFF; 
     $display("b8_signed (8'hFF) = %0d", b8_signed);  //应该输出-1

     //观察例2.3的四状态检测
     iport = 8'b1010_zzxx; //模拟硬件出现高阻和不定态

     if($isunknown(iport)) begin
         $display("%0t: 4-state value detected on iport %b", $time, iport);
     end else begin
         $display("iport is clean.");
     end

     //观察四状态强转为二状态（吞掉X/Z）
     b_val = iport;
     $display("Assigned to bit [7:0]: b_val = %b", b_val);
end

endmodule