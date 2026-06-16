import torch
import torch.nn as nn
import torch.optim as optim

class DualTowerModel(nn.Module):
    def __init__(self, user_dim, job_dim, hidden_dim=256):
        super().__init__()

        self.user_tower = nn.Sequential(
            nn.Linear(user_dim, hidden_dim),
            nn.ReLU(),
            nn.Linear(hidden_dim, hidden_dim)
        )

        self.job_tower = nn.Sequential(
            nn.Linear(job_dim, hidden_dim),
            nn.ReLU(),
            nn.Linear(hidden_dim, hidden_dim)
        )

        self.sigmoid = nn.Sigmoid()

    def forward(self, user_vec, job_vec):
        u = self.user_tower(user_vec)
        j = self.job_tower(job_vec)
        score = torch.sum(u * j, dim=1)
        return self.sigmoid(score)