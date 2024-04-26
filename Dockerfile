FROM intelanalytics/ipex-llm-xpu:latest

# Disable pip's cache behavior
ARG PIP_NO_CACHE_DIR=false


VOLUME [ "/llm", "/root/.cache/huggingface" ]

WORKDIR /llm/

RUN apt update && apt dist-upgrade -y && apt install -y clinfo

# Install dependencies
RUN cd /llm && \
    pip install --pre --upgrade ipex-llm[cpp]
    
    
#RUN curl -fsSL https://ollama.com/install.sh | sh

EXPOSE 11423 11423

COPY llama3.model /llm/bin/
COPY startup.sh /bin/start_ollama.sh
RUN chmod 755 /bin/start_ollama.sh

ENTRYPOINT [ "/bin/bash", "/bin/start_ollama.sh" ]
# docker run -it --name "lj_ollama" --device /dev/dri -p 11434:11434 -v /main_data/docker/llm_models/:/llm/ -v /main_data/docker/ollama_models/:/root/.ollama/ lj_ol:latest --model-path mistral
