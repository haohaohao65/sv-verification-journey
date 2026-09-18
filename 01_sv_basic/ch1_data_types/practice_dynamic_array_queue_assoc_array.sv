module practise;

int dyn_arr[];
int val;
int q[$];
int score[string];
initial begin
dyn_arr=new[5];
dyn_arr = '{10,20,30,40,50};
dyn_arr=new[7](dyn_arr);
$display("dyn_arr size = %0d, content = %p", dyn_arr.size(), dyn_arr);


q.push_back(1);
q.push_back(2);
q.push_back(3);
q.push_front(99);
val=q.pop_front();
$display ("val=%0d,q=%p", val, q);


score["Alice"]=95;
    score["Bob"]=88;

    if(score.exists("Tom"))
    $display("Tom's score=%0d", score["Tom"]);
    else
    $display("Tom is absent");
end

endmodule