cargo objcopy -- -O binary bin/crush-blinky.bin
objcopy -I binary --verilog-data-width 4 -O verilog bin/crush-blinky.bin bin/crush-blinky.data
