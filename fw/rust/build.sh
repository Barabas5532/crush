cargo objcopy -- -O binary binary/crush-blinky.bin
objcopy -I binary --verilog-data-width 4 -O verilog binary/crush-blinky.bin binary/crush-blinky.data
