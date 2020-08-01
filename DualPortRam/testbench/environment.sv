class ram_env;
    //instantiate all the interfaces virtually since it is also a class.
    virtual ram_if.WRT_DRV wrt_drv_if;
    virtual ram_if.RD_DRV rd_drv_if;
    virtual ram_if.WRT_MON wrt_mon_if;
    virtual ram_if.RD_MON rd_mon_if;
    
    //mailbox handles instantiation of various mailboxes into objects.
    mailbox #(ram_trans) gen2wrt = new();
    mailbox #(ram_trans) gen2rd = new();

    mailbox #(ram_trans) wrtmon2rm = new();
    mailbox #(ram_trans) rdmon2rm = new();

    mailbox #(ram_trans) rdmon2sb = new();
    mailbox #(ram_trans) rm2sb = new();

    //object instatiation of all the class transactors
    ram_gen gen_h;
    ram_wrt_drv wrt_drv_h;
    ram_wrt_mon wrt_mon_h;
    ram_read_drv read_drv_h;
    ram_read_mon read_mon_h;
    ram_model ref_model_h;
    ram_sb sb_h;

    // The function new of environment class
    function new (virtual ram_if.WRT_DRV wrt_drv_if,
                  virtual ram_if.RD_DRV rd_drv_if,
                  virtual ram_if.WRT_MON wrt_mon_if,
                  virtual ram_if.RD_MON rd_mon_if);
        this.wrt_drv_if = wrt_drv_if;
        this.rd_drv_if = rd_drv_if;
        this.wrt_mon_if = wrt_mon_if;
        this.rd_mon_if = rd_mon_if;
    endfunction:new

    //The build task is used for connecting all the transactors through mailboxes and interfaces
    virtual task build();
        gen_h = new(gen2rd, gen2wrt);
        wrt_drv_h = new(wrt_drv_if,gen2wrt);
        wrt_mon_h = new(wrt_mon_if,wrtmon2rm);
        read_drv_h = new(rd_drv_if,gen2rd);
        read_mon_h = new(rd_mon_if,rdmon2sb,rdmon2rm);
        ref_model_h = new(wrtmon2rm,rdmon2rm,rm2sb);
        sb_h = new(rdmon2sb,rm2sb);
    endtask:build

    //A task to reset the dut
    virtual task reset_dut();
        begin
            rd_drv_if.rd_drv_cb.rd_address <= '0;
            rd_drv_if.rd_drv_cb.read <= '0;
            wrt_drv_if.wrt_drv_cb.write <= '0;
            wrt_drv_if.wrt_drv_cb.wr_address <= '0;
            repeat(5)
                @(wr_drv_if.wrt_drv_cb);
            for(int i=0; i<4096; i++)
                begin
                    wrt_drv_if.wrt_drv_cb.write <= '1;
                    wrt_drv_if.wrt_drv_cb.wr_address <= i;
                    wrt_drv_if.wrt_drv_cb.data_in <= '0;
                    @(wr_drv_if.wrt_drv_cb);
                end
            wrt_drv_if.wrt_drv_cb.write <= '0;
            repeat(5)
                @(wr_drv_if.wrt_drv_cb);
        end
    endtask:reset_dut

    virtual task start(); // All the starts will happen in parallel because all are created by fork join_none.
        gen_h.start();
        wrt_drv_h.start();
        wrt_mon_h.start();
        read_drv_h.start();
        read_mon_h.start();
        ref_model_h.start();
        sb_h.start();
    endtask:start

    virtual task stop();
        wait(sb_h.DONE.triggered);
    endtask:stop

    virtual task run();
        reset_dut();
        start();
        stop();
        sb_h.report();
    endtask:run
        
endclass:ram_env