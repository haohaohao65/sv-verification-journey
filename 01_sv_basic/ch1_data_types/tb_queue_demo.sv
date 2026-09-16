module tb_queue_demo;

int q[$]; //声明队列，初始为空
int item;

initial begin
    //验证队列的初始化
    $display("1.初始长度：%0d", q.size());

    //模拟FIFO（先进先出）：从尾部入队
    q.push_back(100);
    q.push_back(200);
    q.push_back(300);
    $display("2.入队后内容：%p", q); //输出'{100, 200, 300}

    //VIP插队：从头部塞入
    q.push_front(999);
    $display("3.头部插队后：%p", q); //输出'{999, 100, 200, 300}

    //模拟消费：从头部依次出队
    item = q.pop_front();
    $display("4.弹出的队头元素：%0d，剩余队列：%p", item, q);

    //像普通数组一样通过下标读写
    $display("5.当前第一个元素是：%0d", q[0]);
    q[0] = 888; //直接把原来的100改为888
    $display("6.修改后队列内容：%p", q); //输出'{888, 200, 300}

    //清空队列
    q.delete();
    $display("7.清空后长度：%0d", q.size());
end

endmodule