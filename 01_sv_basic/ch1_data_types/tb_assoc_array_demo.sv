module tb_assoc_array_demo;  //声明关联数组

//声明稀疏内存：地址是32位bit，存储数据是int
int memory[bit [31:0]];
bit [31:0] addr; //地址


//声明字符串映射字典：Key是string，Value是int
int port_map[string];
string name;

initial begin
    // ---场景1：稀疏内存建模---
    memory[32'h0000_0010] = 32'hAAAA_BBBB;
    memory[32'h8000_0000] = 32'h1234_5678;
    memory[32'hFFFF_0000] = 32'hDEAD_BEEF;

    $display("1.内存实际占用格子数：%0d", memory.num()); //输出3

    //检查地址是否存在
    if (memory.exists(32'h0000_0000)) begin
        $display("2.地址0x0000_0000存在，数据为：%x08X", memory[32'h0000_0000]);
    end

    //使用first()和next()遍历关联数组
    if(memory.first(addr)) begin
        do begin
            $display("地址：%x08X，数据：%x08X", addr, memory[addr]);
        end while(memory.next(addr));
    end

    // ---场景2：字符串索引（字典查找）---
    port_map["ETH0"] = 1001;
    port_map["PICE"] = 2002;
    port_map["UART1"] = 3003;

    $display("3.PICE对应端口号：%0d", port_map["PICE"]);

    //使用foraeach直接遍历关联数组
    foreach(port_map[port_name]) begin
        $display("端口名：%s，端口号：%0d", port_name, port_map[port_name]);
    end
end
endmodule