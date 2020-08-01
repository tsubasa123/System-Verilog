class ram_wrt_mon;
    //mailbox to connect to the ref model
    mailbox #(ram_trans) wrtmon2rm;
    //interface to get the data from DUV
    virtual ram_if.WRT_MON wrt_mon_if;
    // transaction handles 
    ram_trans wrtdata;
    ram_trans data2rm;
    // Since write monitor also generates coverage for write transaction
    ram_trans cov_data; 

    function new (mailbox #(ram_trans) wrtmon2rm,
                  virtual ram_if.WRT_MON wrt_mon_if);
        this.wrtmon2rm = wrtmon2rm;
        this.wrt_mon_if = wrt_mon_if;
        this.wrtdata = new; // wrtdata object
        mem_coverage = new(); //coverage instance. We can pass arguments later in mem_coverage.
    endfunction:new

    //Coverage definition for write transaction....
    covergroup mem_coverage;
        WR_ADD: coverpoint cov_data.wrt_address
            {
                bins ZERO           = {0};
                bins LOW1           = {[1:585]};
                bins LOW2           = {[586:1170]};
                bins MID_LOW        = {[1171:1755]};
                bins MID            = {[1756:2340]};
                bins MID_HIGH       = {[2341:2925]};
                bins HIGH1          = {[2926:3510]};
                bins HIGH2          = {[3511:4094]};
                bins MAX            = {[4095]};
            }   
        DATA: coverpoint cov_data.data_in
            {
                bins ZERO           = {0};
                bins LOW1           = {[1:500]};
                bins LOW2           = {[501:1000]};
                bins MID_LOW        = {[1001:1500]};
                bins MID            = {[1501:2000]};
                bins MID_HIGH       = {[2001:2500]};
                bins HIGH1          = {[2501:3000]};
                bins HIGH2          = {[3001:4293]};
                bins MAX            = {[4294]};
            }
        WR: coverpoint cov_data.write
            {
                bins write = {1};
            }
        WRITExADDxDATA: cross WR,WR_ADD,DATA;
    endgroup:mem_coverage

    virtual task monitor();
        @(wrt_mon_if.wrt_mon_cb);
        wait (wrt_mon_if.wrt_mon_cb.write == 1);
        @(wrt_mon_if.wrt_mon_cb);
        begin
            wrtdata.write = wrt_mon_if.wrt_mon_cb.write;
            wrtdata.wrt_address = wrt_mon_if.wrt_mon_cb.wrt_address;
            wrtdata.data_in = wrt_mon_if.wrt_mon_cb.data_in;
            wrtdata.display("...DATA FROM WRITE MONITOR..."); 
        end
    endtask:monitor

    virtual task start();
        fork
            forever 
                begin
                    monitor();
                    data2rm = new wrtdata;
                    cov_data = new wrtdata;
                    mem_coverage.sample(); 
                    wrtmon2rm.put(data2rm);
                end
        join_none
    endtask:start

endclass:ram_wrt_mon