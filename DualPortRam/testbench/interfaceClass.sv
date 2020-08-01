// The Clock will be sent to both testcases and DUV through interface.
// So clock is the input to the interface...
interface ram_if(input bit clock);

    logic [63:0]data_in;
    logic [63:0]data_out;
    logic [11:0]wrt_address;
    logic [11:0]rd_address;
    logic write;
    logic read;

    //Write Driver clocking block
    clocking wrt_drv_cb @(posedge clock)
        // The output and the input skew..
        // The input skew determines before how much time the TB samples the DUV output
        // The output skew determines after how much time the TB drives the DUV input.
        default input #1 output#1; 
        output data_in;
        output wrt_address;
        output write;
    endclocking: wr_drv_cb

    //Read Driver clocking block
    clocking rd_drv_cb @(posedge clock)
        default input #1 output #1;
        output rd_address;
        output read;
    endclocking: rd_drv_cb

    //Write Monitor clocking block
    clocking wrt_mon_cb @(posedge clock)
        default input #1 output #1;
        input data_in;
        input wrt_address;
        input write;
    endclocking: wr_mon_cb

    //Read Driver clocking block
    clocking rd_mon_cb @(posedge clock)
        default input #1 output #1;
        input data_out;
        input rd_address;
        input read;
    endclocking: rd_mon_cb

    //Write Driver modport
    modport WRT_DRV (clocking wrt_drv_cb);
    //Write Monitor modport
    modport WRT_MON (clocking wrt_mon_cb);
    //Read Driver modport
    modport RD_DRV (clocking rd_drv_cb);
    //Read Monitor modport
    modport RD_MON (clocking rd_mon_cb);
        
endinterface:ram_if