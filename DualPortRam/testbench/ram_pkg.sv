package ram_pkg;
    int number_of_transactions = 1;
    `include "transactionClass.sv";
    `include "generatorClass.sv";
    `include "writeDriver.sv";
    `include "readDriver.sv";
    `include "writeMon.sv";
    `include "readMon.sv";
    `include "refModel.sv";
    `include "scoreboard.sv";
    `include "environment.sv";
endpackage:ram_pkg