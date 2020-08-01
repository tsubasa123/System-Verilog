module ram_4096(clock,
                data_in,
                rd_address,
                wrt_address,
                read,
                write,
                data_out);
                
    parameter RAM_WIDTH = 64;
    parameter RAM_DEPTH = 4096;
    parameter ADDR_SIZE = 12;

    input clock,
          write,
          read;
    input [RAM_WIDTH-1:0] data_in;
    input [ADDR_SIZE-1:0] rd_address, wrt_address;
    output reg [RAM_WIDTH-1:0] data_out;

    reg [RAM_WIDTH-1:0] ram [RAM_DEPTH-1:0];
    
    always @(posedge clock)
        begin
            if (read)
                data_out <= ram[rd_address];
            if (write)
                ram[wrt_address] <= data_in; 
        end
endmodule
