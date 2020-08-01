//Include the testcase file
`include "testcase1.sv"
module top();
    parameter clock_cycle=10;
    reg clock;
    //Instantiate the physical interface
    ram_if DUV_IF(clock);

    test test_h;

    ram_4096 RAM(.clock(clock),
                 .data_in(DUV_IF.data_in),
                 .data_out(DUV_IF.data_out),
                 .rd_address(DUV_IF.rd_address),
                 .wrt_address(DUV_IF.wrt_address),
                 .read(DUV_IF.read),
                 .write(DUV_IF.write));
    initial 
        begin
           //create the test object and pass the DUV interface through it
           test_h = new(DUV_IF,DUV_IF,DUV_IF,DUV_IF);
           test_h.build_and_run();         
        end 
    
    initial 
        begin
            clock = 1'b0;
            forever #(clock_cycle/2) clock = ~clock;
        end
endmodule:top