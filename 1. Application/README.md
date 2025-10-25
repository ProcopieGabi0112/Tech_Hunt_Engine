# 🏗️ Tech_Hunter_Engine 
# System Architecture Overview

## 🌐 General Description

**Tech_Hunter_Engine** is built on a **hybrid architecture** that combines **local processing and data entry** with **cloud-based analytics, automation, and AI-driven recommendations**.  
The system ensures both scalability and offline usability, allowing users to interact locally while maintaining continuous synchronization with cloud resources.

---

## ☁️ 1. Cloud Component (Oracle Cloud Infrastructure)

The **Cloud Component** is responsible for **data processing, AI-driven recommendation generation, and automated reporting**.

### 🔹 Key Elements

| Component | Description |
|------------|-------------|
| **Oracle Autonomous Database (ADB)** | Main transactional database in the cloud. Stores all user profiles, form submissions, and processed data from the local environment. |
| **Oracle Autonomous Data Warehouse (ADW)** | Dedicated for analytics and machine learning. Receives data periodically from the ADB to enable complex processing and AI model training. |
| **AI Model Execution Environment** | A serverless or containerized process (e.g., OCI Function or Data Science Job) that runs the recommendation model. It analyzes the processed data and identifies users with `report_flag_sent = 'N'`. |
| **Email & PDF Report Service** | Once a user’s data is processed, the system generates a personalized PDF report with job and technology recommendations and sends it to the user’s registered email address. |

## 🔧 Cloud Technology Stack

| Layer | Technology |
|--------|-------------|
| **Cloud Databases** | Oracle Autonomous Database, Oracle Autonomous Data Warehouse |
| **AI/Automation** | OCI Functions / Python ML Scripts |
| **Synchronization** | Custom Replication Scripts (Python / Spring Batch) |
| **PDF & Email Services** | Python, ReportLab, SMTP integration |

### ⚙️ Cloud Workflow

1. **Data Storage** – User data initially uploaded or synchronized from local systems is stored in the **Autonomous Database (ADB)**.  
2. **Data Transfer** – Relevant datasets are replicated from ADB into the **Autonomous Data Warehouse (ADW)** for analytical processing.  
3. **AI Processing** – The **AI model** periodically runs, scanning for users where `report_flag_sent = 'N'`.  
4. **Report Generation** – For each identified user, a personalized **PDF report** is created and stored.  
5. **Email Dispatch** – The generated report is automatically **emailed** to the corresponding user.  
6. **Status Update** – The system updates `report_flag_sent = 'Y'` in the database, marking the process as complete.

---

## 💻 2. Local Component

The **Local Component** provides a user-friendly interface for data entry, local analytics, and offline operation.  
It synchronizes periodically with the cloud to ensure all user data remains consistent and up to date.

## 🔧 Local Technology Stack

| Layer | Technology |
|--------|-------------|
| **Frontend** | React (Web) |
| **Backend** | Spring Boot |
| **Local Databases** | PostgreSQL, MongoDB |
| **Containerization** | Docker |

### 🔹 Key Databases

| Database | Role | Description |
|-----------|------|-------------|
| **PostgreSQL** | Analytical & Visualization Layer | Stores structured data retrieved from the cloud, allowing local users to visualize trends, explore dashboards, and view aggregated data. |
| **MongoDB** | JSON Data Storage Layer | Collects raw user submissions as JSON documents, representing real-time inputs from students or users filling out forms. |

---

## 🔄 Local–Cloud Synchronization

### 🧩 Replication Logic

Depending on the user type and data state, two replication flows exist:

1. **New User Flow**  
   - User submits data via frontend → stored in **MongoDB** as JSON.  
   - Data is validated and prepared for transfer.  
   - Synchronized to the **Oracle Autonomous Database** in the cloud.  

2. **Existing User Flow**  
   - Cloud data is replicated into **PostgreSQL** for visualization.  
   - User can update or complete missing data locally.  
   - Upon confirmation, updates are synchronized back to the cloud.

---

## 📤 Report Generation Process

When a user completes all required data and confirms submission:
1. The local application sends the data to the **Autonomous Database** in the cloud.  
2. A **scheduled AI process** in the cloud identifies the new or updated users.  
3. A **PDF generation service** (Python-based) creates a personalized recommendation report.  
4. The **email service** delivers the report to the user’s registered address.  
5. The user’s record is updated (`report_flag_sent = 'Y'`).

---

