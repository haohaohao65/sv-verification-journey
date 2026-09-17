module array_methods_practice;

int a[] = '{10, 25, 8, 30, 25, 15, 8};
int res_q[$];  // 用于接收返回值为数组/队列的方法结果
int total;

initial begin
    
    //1.找出所有>10的元素
    res_q = a.find() with (item>10);
    $display("1. Elements > 10: %p", res_q);

    //2.找出所有>10的元素的下标
    res_q = a.find_index() with (item>10);
    $display("2. Indices of elements > 10: %p", res_q);

    //3.找出第一个 > 20 的元素
    res_q = a.find_first() with (item>20);
    $display("3. First element > 20: %p", res_q);

    // 4. 求所有元素的和
    total = a.sum();
    $display("4. Sum of elements: %0d", total);

    // 6. 对数组升序排序(直接修改 a)
    a.sort();
    $display("7. Sorted array: %p", a);

    // 7. 得到去重后的数组
    res_q = a.unique();
    $display("5. Unique elements: %p", res_q);

    // 8. 求所有元素平方之后的总和
    total = a.sum() with (item*item);
    $display("6. Sum of squares: %0d", total);
end

endmodule