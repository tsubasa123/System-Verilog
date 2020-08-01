class ram_read_mon;
    //mailbox handles to connect to scoreboard and refernce model
    mailbox #(ram_trans) rdmon2sb;
    mailbox #(ram_trans) rdmon2rm;
    //interface to get the data from DUV
    virtual ram_if.RD_MON rd_mon_if;

    // Data to send from the read monitor.
    ram_trans rddata;
    ram_trans data2sb;
    ram_trans data2rm;

    function new (virtual ram_if.RD_MON rd_mon_if,
                  mailbox #(ram_trans) rdmon2sb,
                  mailbox #(ram_trans) rdmon2rm);
        this.rd_mon_if = rd_mon_if;
        this.rdmon2sb = rdmon2sb;
        this.rdmon2rm = rdmon2rm;
        this.rddata = new; // In read monitor we need to create the transaction so we need to create object.
    endfunction:new 

    virtual task monitor();
        @(rd_mon_if.rd_mon_cb); // wait for clockedge
        wait (rd_mon_if.rd_mon_cb.read == 1);
        @(rd_mon_if.rd_mon_cb);
        begin
            rddata.read = rd_mon_if.rd_mon_cb.read;
            rddata.rd_address = rd_mon_if.rd_mon_cb.rd_address;
            rddata.data_out = rd_mon_if.rd_mon_cb.data_out;
            rddata.display("...DATA FROM READ MONITOR...");
        end
    endtask:monitor

    virtual task start();
        fork
            forever 
                begin
                    monitor();
                    data2sb = new rddata;
                    data2rm = new rddata;
                    rdmon2sb = put(data2sb);
                    rdmon2rm = put(data2rm);
                end
        join_none
    endtask:start

endclass:ram_read_mon
