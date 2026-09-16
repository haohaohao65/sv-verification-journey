module tb_foreach_demo;

int matrix[2][3] = '{
    '{10, 20, 30},
    '{40, 50, 60}
};

initial begin
    $display("=== 1.空出第二维：只遍历第一维（行） ===");
    //注意逗号后面是空的！
    foreach (matrix[r, ]) begin
        //此时r只有0和1
        //用%p，直接把第r行整体打印出来
        $display("第 %0d 行整行内容: %p", r, matrix[r]);
    end

    $display("=== 2.两个维度都写：深入遍历每个具体元素 ===");
    foreach (matrix[r, c]) begin
        //此时r只有0和1，c只有0、1、2
        $display("第 %0d 行，第 %0d 列的元素: %0d", r, c, matrix[r][c]);
    end
end

endmodule