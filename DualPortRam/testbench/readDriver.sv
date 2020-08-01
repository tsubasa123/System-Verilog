//Read driver also known as BFM(Bus functional Model)
class ram_read_drv;

    mailbox #(ram_trans) gen2rd; // mailbox that connects the generator to read driver
    virtual ram_if.RD_DRV rd_drv_if; // Interface to connect the read driver to the DUV
    ram_trans data2duv; // The transaction data to send to the DUV.

    //The new function redefined
    function new(mailbox #(ram_trans) gen2rd,
                 virtual ram_if.RD_DRV rd_drv_if);
        this.gen2rd = gen2rd;
        this.rd_drv_if = rd_drv_if;
    endfunction:new

    //The driver action task
    virtual task drive();
        @(rd_drv_if.rd_drv_cb);
            rd_drv_if.rd_drv_cb.rd_address <= data2duv.rd_address;
            rd_drv_if.rd_drv_cb.read <= data2duv.read;
        //Disable the read signal after two clock cycles
        repeat(2) @(rd_drv_if.rd_drv_cb)
            rd_drv_if.rd_drv_cb.read <= '0; // Disable the active signal at the end.
    endtask:drive

    //The start method, Every transactor shall have the start method.
    //The start method is a parallel thread
    virtual task start();
        fork
            forever 
                begin
                    gen2rd.get(gen2duv);
                    drive();
                end
        join_none
    endtask:start
endclass:ram_read_drv