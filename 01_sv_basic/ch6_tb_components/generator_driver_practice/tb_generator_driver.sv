`include "Generator.sv"
`include "Driver.sv"

module tb_generator_driver;

    mailbox mb;

    Generator gen;
    Driver drv;

    initial begin

        mb=new();// 1. 创建 mailbox


        gen=new(mb);
        drv=new(mb);// 2. 创建 Generator 和 Driver

        fork
        gen.run();// 3. 运行 Generator
        drv.run();// 4. 运行 Driver
        join

    end

endmodule