import torch
import torch.nn as nn
import torch.optim as optim
import torchvision
import torchvision.transforms as transforms
import time

# Config
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
num_epochs = 5
batch_size = 128
learning_rate = 1e-3
cost_per_hour = 0.0556  # $0.0556 per GPU‑hour

# CIFAR-10 dataset
transform = transforms.Compose([
    transforms.ToTensor(),
    transforms.Normalize((0.5,)*3, (0.5,)*3),
])
train_ds = torchvision.datasets.CIFAR10('./data', train=True, download=True, transform=transform)
train_loader = torch.utils.data.DataLoader(train_ds, batch_size=batch_size, shuffle=True)

# Model, loss, optimizer
model = torchvision.models.resnet18(num_classes=10).to(device)
criterion = nn.CrossEntropyLoss()
optimizer = optim.Adam(model.parameters(), lr=learning_rate)

total_time = 0.0
for epoch in range(1, num_epochs+1):
    start = time.time()
    running_loss = 0.0
    for imgs, lbls in train_loader:
        imgs, lbls = imgs.to(device), lbls.to(device)
        out = model(imgs)
        loss = criterion(out, lbls)
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()
        running_loss += loss.item()
    elapsed = time.time() - start
    total_time += elapsed
    cost = (elapsed/3600)*cost_per_hour
    print(f"[Epoch {epoch}/{num_epochs}] Loss: {running_loss/len(train_loader):.4f} | "
          f"Time: {elapsed:.1f}s | Cost: ${cost:.4f}")

total_cost = (total_time/3600)*cost_per_hour
print(f"→ Total training: {total_time:.1f}s | Cost: ${total_cost:.4f}")
