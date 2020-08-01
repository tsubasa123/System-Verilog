//Import the package
class test;
    import ram_pkg::*;
    //instantiate all the interfaces virtually since it is also a class.
    virtual ram_if.WRT_DRV wrt_drv_if;
    virtual ram_if.RD_DRV rd_drv_if;
    virtual ram_if.WRT_MON wrt_mon_if;
    virtual ram_if.RD_MON rd_mon_if;

    // Declare a handle for instantiating the env in the testcase
    ram_env env_h;

    function new(virtual ram_if.WRT_DRV wrt_drv_if,
                 virtual ram_if.RD_DRV rd_drv_if,
                 virtual ram_if.WRT_MON wrt_mon_if,
                 virtual ram_if.RD_MON rd_mon_if);

        this.wrt_drv_if = wrt_drv_if;
        this.rd_drv_if = rd_drv_if;
        this.wrt_mon_if = wrt_mon_if;
        this.rd_mon_if = rd_mon_if;
        env_h = new( wrt_drv_if,rd_drv_if,wrt_mon_if,rd_mon_if);
    endfunction:new

    virtual task build_and_run();
        begin
            number_of_transactions = 10;
            env_h.build();
            env_h.run();
            $finish; 
        end
    endtask:build_and_run

endclass:test