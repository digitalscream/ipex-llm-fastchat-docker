
#!/bin/bash

source /opt/intel/oneapi/setvars.sh

source ipex-llm-init -c -g

export USE_XETLA=OFF
export SYCL_PI_LEVEL_ZERO_USE_IMMEDIATE_COMMANDLISTS=2
export ZES_ENABLE_SYSMAN=1

# Use this if you have multiple Intel GPUs and don't want to use them all - 
# card selector can be an integer, or comma-separated integers
# export ONEAPI_DEVICE_SELECTOR=level_zero:0,1

cd /llm/bin

init-llama-cpp
init-ollama

OLLAMA_KEEP_ALIVE="-1" OLLAMA_HOST="0.0.0.0:11434" ./ollama serve &

sleep 2

./ollama create llama_local -f llama3.model


/bin/bash
