# infra-demo
Inference and Training Demos to Showcase Price/ Performance for Foundry
README.md
# Infra Demo

This repo shows:
- **train_demo.py**: train ResNet18 on CIFAR‑10 and log time+cost.
- **inference_demo.py**: run GPT‑2 inference (as a stand‑in for ChatGPT2), log time+cost at \$12.48/hr.
- **measure_startup.sh**: bash script to launch an instance (AWS/EC2 in this case)and measure its boot time.
- **validate_litecontainer_env.sh - bash script to validate the environment is ready for the training and inference demo to run - it checks 1. network reachability 2. server certificate validity 3. Public_key file exist ? 4. pdm present and has the ability to import my module?
## Setup

```bash
# 1. Clone
git clone https://github.com/<you>/infra-demo.git
cd infra-demo

# 2. Create Python venv & install
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# 3. Configure AWS CLI (for measure_startup.sh)
aws configure
