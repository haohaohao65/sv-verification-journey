module tb_dynamic_array;

int d_arr[];

initial begin
    //初始状态
    $display("1.初始大小：%0d", d_arr.size()); //输出0


    //分配3个空间并赋值
    d_arr = new[3];
    d_arr = '{10, 20, 30};
    $display("2.分配空间后内容：%p", d_arr); //输出'{10, 20, 30}


    //扩容到5个，并保留之前的3个
    d_arr = new[5](d_arr);
    d_arr[3] = 40;
    d_arr[4] = 50;
    $display("3.扩容后内容：%p", d_arr); //输出'{10, 20, 30, 40, 50}


    //清空释放
    d_arr.delete();
    $display("4.清空后大小：%0d", d_arr.size()); //输出0
    
end

endmodule