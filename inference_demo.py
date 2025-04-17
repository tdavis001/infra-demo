import time
import torch
from transformers import AutoTokenizer, AutoModelForCausalLM

# Config
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
model_name = "gpt2"
cost_per_hour = 12.48  # $12.48 per GPU‑hour
num_runs = 3
prompt = "Once upon a time"

# Load model + tokenizer
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForCausalLM.from_pretrained(model_name).to(device)

total_time = 0.0
for i in range(1, num_runs+1):
    start = time.time()
    inputs = tokenizer(prompt, return_tensors="pt").to(device)
    outputs = model.generate(**inputs, max_new_tokens=50)
    elapsed = time.time() - start
    total_time += elapsed
    cost = (elapsed/3600)*cost_per_hour
    text = tokenizer.decode(outputs[0], skip_special_tokens=True)
    print(f"[Run {i}/{num_runs}] Time: {elapsed:.2f}s | Cost: ${cost:.4f}")
    print(f"Output snippet: {text[:80]}...\n")

total_cost = (total_time/3600)*cost_per_hour
print(f"→ Total inference: {total_time:.2f}s | Cost: ${total_cost:.4f}")
