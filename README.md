# ipex-llm-fastchat-docker
Docker image providing fastchat (webui and api) for Intel Arc GPUs with IPEX-LLM(https://github.com/intel-analytics/ipex-llm).

# Installation

1. To start, you absolutely *must* install the latest drivers for your GPU, even if you think you've already got them in your kernel:

```
sudo apt-get install -y gpg-agent wget
wget -qO - https://repositories.intel.com/gpu/intel-graphics.key | \
  sudo gpg --dearmor --output /usr/share/keyrings/intel-graphics.gpg

echo "deb [arch=amd64,i386 signed-by=/usr/share/keyrings/intel-graphics.gpg] https://repositories.intel.com/gpu/ubuntu jammy client" | \
  sudo tee /etc/apt/sources.list.d/intel-gpu-jammy.list

sudo apt-get update
sudo apt-get -y install \
    gawk \
    dkms \
    linux-headers-$(uname -r) \
    libc6-dev
sudo apt install intel-i915-dkms intel-fw-gpu
sudo apt-get install -y gawk libc6-dev udev\
    intel-opencl-icd intel-level-zero-gpu level-zero \
    intel-media-va-driver-non-free libmfx1 libmfxgen1 libvpl2 \
    libegl-mesa0 libegl1-mesa libegl1-mesa-dev libgbm1 libgl1-mesa-dev libgl1-mesa-dri \
    libglapi-mesa libgles2-mesa-dev libglx-mesa0 libigdgmm12 libxatracker2 mesa-va-drivers \
    mesa-vdpau-drivers mesa-vulkan-drivers va-driver-all vainfo

sudo reboot
```

2. Set up permissions:

```
sudo gpasswd -a ${USER} render
newgrp render

# Verify the device is working with i915 driver
sudo apt-get install -y hwinfo
hwinfo --display
```
3. Install Docker (if you don't already have it)
```
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

4. Clone this repo.
```
git clone https://github.com/digitalscream/ipex-llm-fastchat-docker.git
cd ipex-llm-fastchat-docker
```

5. Make some directories for storing the models, and for the logs (make sure you do this on a disk with plenty of space...you're going to be downloading a lot of models when you start playing with it...):
```
mkdir ~/fastchat
mkdir ~/fastchat/logs
```

# Usage
1. Build (don't forget the period on the end):
```
docker build --tag 'ipex-llm-fastchat-docker' .
```

2. Run!
```
docker run --device /dev/dri -v ~/fastchat:/root/.cache/huggingface -v ~/fastchat/logs:/logs \
  -p 7860:7860 -p 8000:8000 ipex-llm-fastchat-docker:latest \
  --model-path mistralai/Mistral-7B-Instruct-v0.2
```
**NOTE**: if you want to use an AWQ-quantised model, you'll need `--load-in-low-bit asym_int4` on the end:

```
docker run --device /dev/dri -v ~/fastchat:/root/.cache/huggingface -v ~/fastchat/logs:/logs \
  -p 7860:7860 -p 8000:8000 ipex-llm-fastchat-docker:latest \
  --model-path TheBloke/laser-dolphin-mixtral-2x7b-dpo-AWQ --load-in-low-bit asym_int4
```

3. Play with it. Visit `http://localhost:7860` in your browser and off you go. For extra points, if you're a VS Code user, you can install the Continue extension. The base URL is `http://localhost:8000/v1`, and just set the API key to `EMPTY`.

# What's performance like?

My system is a Ryzen 3600 with 96GB RAM and an Arc A770 16GB. With Mistral 7b, I see around 60 tokens/s. With Mixtral 2x7b AWQ, that drops to 30-40 tokens/s (understandably). If you're seeing ~8-10 tokens/s, then I can almost guarantee that you haven't installed the latest GPU drivers.

# What's config.py for?

This is pretty much temporary - there's currently a bug in the IPEX vLLM worker, which should be fixed when they release 2.5.0. They put a hack in place to get around the fact that Mistral models weren't properly supported by `transformers` at the time, but the hack wasn't completely removed. This version of `config.py` fixes that.

# TODO

At some point, I'll get around to putting together a decent `docker-compose.yml` to package the whole lot together.

# Thanks

Thanks to @itlackey for the `startup.sh` script, and the Intel devs for the example Dockerfiles needed to get this all up and running.
