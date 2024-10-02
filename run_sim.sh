cmake --build ./freertos/app/build
fusesoc run --target sim_cpu_freertos --build --resolve-env-vars-early crush && vvp -n build/crush_0.0.1/sim_cpu_freertos-icarus/crush_0.0.1 +BINARY_PATH=freertos/app/build/crush_freertos.bin
