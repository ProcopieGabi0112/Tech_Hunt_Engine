# 🏗️ Tech_Hunter_Engine 
#  System Architecture Overview

## 🌐 General Description

**Tech_Hunter_Engine** is built on a **hybrid architecture** that combines **local processing and data entry** with **cloud-based analytics, automation, and AI-driven recommendations**.  
The system ensures both scalability and offline usability, allowing users to interact locally while maintaining continuous synchronization with cloud resources.

---

## ☁️ Cloud Component (Oracle Cloud Infrastructure)

The **Cloud Component** is responsible for **data processing, AI-driven recommendation generation, and automated reporting**.

### 🔹 Key Elements

| Component | Description |
|------------|-------------|
| **Oracle Autonomous Database (ADB)** | Main transactional database in the cloud. Stores all user profiles, form submissions, and processed data from the local environment. |
| **Oracle Autonomous Data Warehouse (ADW)** | Dedicated for analytics and machine learning. Receives data periodically from the ADB to enable complex processing and AI model training. |
| **AI Model Execution Environment** | A serverless or containerized process (e.g., OCI Function or Data Science Job) that runs the recommendation model. It analyzes the processed data and identifies users with `report_flag_sent = 'N'`. |
| **Email & PDF Report Service** | Once a user’s data is processed, the system generates a personalized PDF report with job and technology recommendations and sends it to the user’s registered email address. |

### ⚙️ Cloud Workflow

1. **Data Storage** – User data initially uploaded or synchronized from local systems is stored in the **Autonomous Database (ADB)**.  
2. **Data Transfer** – Relevant datasets are replicated from ADB int


