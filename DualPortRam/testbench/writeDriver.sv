//Write driver also known as BFM(Bus functional Model)
class ram_wrt_drv;

    mailbox #(ram_trans) gen2wrt;
    ram_trans data2duv;
    virtual ram_if.WRT_DRV wrt_drv_if;

    //Function new to allocate the memory at runtime
    function new(mailbox #(ram_trans) gen2wrt,
                 virtual ram_if.WRT_DRV wrt_drv_if);
        this.gen2wrt = gen2wrt;
        this.wrt_drv_if = wrt_drv_if;
    endfunction:new
    //Function to drive the driver
    virtual task drive();
        @(wrt_drv_if.wrt_drv_cb);
            wrt_drv_if.wrt_drv_cb.wrt_address <= data2duv.wrt_address;
            wrt_drv_if.wrt_drv_cb.data_in <= data2duv.data_in;
            wrt_drv_if.wrt_drv_cb.write <= data2duv.write;
        //Disable the write signal after two clock cycles
        repeat(2) @(wrt_drv_if.wrt_drv_cb)
            wrt_drv_if.wrt_drv_cb.write <= '0;
    endtask:drive
    //Function to start the driver
    virtual task start();
        fork
            forever 
                begin
                    gen2wrt.get(data2duv);
                    drive();
                end
        join_none
    endtask:start

endclass:ram_wrt_drv