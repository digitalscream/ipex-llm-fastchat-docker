FROM intelanalytics/ipex-llm-xpu:2.1.0-SNAPSHOT

# Disable pip's cache behavior
ARG PIP_NO_CACHE_DIR=false

# Install Serving Dependencies
RUN cd /llm && \
    pip install --pre --upgrade ipex-llm[xpu,serving] && \
    pip install transformers==4.36.2 gradio==4.19.2
    

RUN apt-get update -y && apt-get install -y git-lfs
RUN pip3 install fschat
RUN pip3 install fschat[model_worker,webui] pydantic==1.10.15
RUN pip3 install autoawq==0.1.8 accelerate==0.25.0 einops

VOLUME [ "/llm", "/root/.cache/huggingface" ]

# This COPY is only necessary until IPEX 2.5.0 is released - it fixes a bug loading Mistral models
COPY config.py /usr/local/lib/python3.9/dist-packages/ipex_llm/vllm/
COPY startup.sh /bin/start_fastchat.sh
RUN chmod 755 /bin/start_fastchat.sh

WORKDIR /llm/
EXPOSE 7860 8000

ENV FS_ENABLE_WEB=true FS_ENABLE_OPENAI_API=true LOGDIR=/logs SYCL_PI_LEVEL_ZERO_USE_IMMEDIATE_COMMANDLISTS=1 USE_XETLA=OFF

ENTRYPOINT [ "/bin/bash", "/bin/start_fastchat.sh" ]
