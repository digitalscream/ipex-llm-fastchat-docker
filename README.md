```
docker run -td --name "lj_ollama" --device /dev/dri -p 11434:11434 -v /main_data/docker/llm_models/:/llm/ lj_ol:latest --model-path mistral
```
