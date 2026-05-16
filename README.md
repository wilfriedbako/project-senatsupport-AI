# SenatSupport AI

## AI-Assisted IT Support & Incident Management Platform

SenatSupport AI is a cloud-based support operations platform designed to simulate how modern organizations can automate ticket management, incident prioritization, operational visibility, and engineering workflows using AI, serverless architecture, and infrastructure automation.

The project focuses on solving a real operational challenge:

As organizations grow across cloud environments, SaaS platforms, remote teams, and internal systems, support teams receive an increasing number of requests and incidents every day. Without automation, teams can quickly become overwhelmed by manual ticket triage, delayed responses, and lack of visibility into operational issues.

SenatSupport AI was designed to explore how AI and cloud engineering can improve operational efficiency by automating key parts of the incident management lifecycle.

---

# Live Demo

Frontend Application:

http://senatsupport-frontend-bako.s3-website-us-east-1.amazonaws.com

---

# Project Goals

The goal of this project was not simply to deploy cloud services.

Instead, the focus was to build a realistic operational platform that demonstrates:

* intelligent ticket classification
* automated urgency scoring
* engineer assignment workflows
* operational dashboards
* real-time visibility for leadership teams
* serverless cloud architecture
* infrastructure automation
* monitoring and alerting
* scalable deployment practices

This project combines concepts from:

* Cloud Engineering
* DevOps
* AI Operations (AIOps)
* Platform Engineering
* Infrastructure as Code
* Operational Automation

---

# Architecture Overview

## High-Level Workflow

1. Employees submit support tickets through a frontend web portal.
2. Requests are sent through an API layer.
3. Serverless compute processes the request.
4. AI analyzes the ticket content.
5. The platform classifies the issue and assigns urgency.
6. Tickets are automatically routed and stored.
7. Operational dashboards update in real time.
8. High-priority incidents trigger automated notifications and alerts.

---

# Architecture Diagram

![Architecture Diagram](./screenshots/architecture.png)

---

# Key Features

## AI-Powered Ticket Classification

The platform uses AI to analyze incoming support requests and automatically determine:

* ticket category
* urgency level
* issue summary
* assignment priority

This reduces manual triage work and helps support teams respond faster.

---

## Automated Engineer Assignment

Tickets are automatically assigned to engineers based on operational logic and urgency.

Example:

* network issues
* access problems
* cloud outages
* application failures

can all be routed dynamically to appropriate support engineers.

---

## Real-Time Operational Dashboards

The platform includes dashboards designed for operational visibility.

Leadership teams can monitor:

* total tickets
* resolved incidents
* open incidents
* critical incidents

This provides a centralized operational overview instead of relying on hundreds of individual notifications.

---

# Director Dashboard

![Director Dashboard](./screenshots/director-dashboard.png)

---

## Engineer Workflow Management

Engineers can:

* update ticket status
* move incidents through lifecycle stages
* resolve or close issues
* track operational progress

Lifecycle stages include:

* Open
* In Progress
* Resolved
* Closed

---

# Engineer Dashboard

![Engineer Dashboard](./screenshots/engineer-dashboard.png)

---

## Automated Critical Incident Notifications

When a ticket reaches high urgency levels, the platform automatically sends operational alerts using notification services.

This simulates how real organizations escalate critical incidents to reduce response times.

---

# Critical Alert Notification

![SNS Email Alert](./screenshots/email-alert.png)

---

# Infrastructure Automation

The infrastructure was fully automated using Infrastructure as Code principles.

Instead of manually creating services in the cloud console, the environment can be reproduced consistently using Terraform.

This helps:

* reduce configuration drift
* improve deployment consistency
* support repeatable environments
* simulate real DevOps workflows

---

# Terraform Deployment

![Terraform Deployment](./screenshots/terraform-deployment.png)

---

# Storage Architecture

The project uses two separate cloud storage buckets for different operational purposes.

## 1. Frontend Hosting Bucket

The first storage bucket hosts the public frontend application used by employees, engineers, and leadership teams.

Purpose:

* static website hosting
* frontend application delivery
* public access to dashboards and ticket portal

Example:

* HTML
* CSS
* JavaScript frontend files

---

## 2. Terraform Remote State Bucket

The second storage bucket was created specifically for Infrastructure as Code operations.

Purpose:

* remote Terraform state storage
* infrastructure consistency
* collaborative deployment workflows
* centralized infrastructure tracking

This simulates how engineering teams manage shared infrastructure environments in production systems.

---

# Cloud & DevOps Components

## Frontend & Hosting

* Amazon S3 (Frontend Hosting)
* Static Website Hosting

## API & Serverless Compute

* Amazon API Gateway
* AWS Lambda

## AI & Automation

* Amazon Bedrock
* AI-powered classification workflows

## Database & Storage

* Amazon DynamoDB
* Amazon S3 Remote State Storage

## Monitoring & Alerts

* Amazon SNS
* Amazon CloudWatch

## Security & Access Management

* AWS IAM

## Containers & Deployment

* Amazon ECR
* Docker

## Infrastructure Automation

* Terraform
* GitHub Actions

---

# Multi-Cloud Mindset

Although this implementation was deployed primarily on AWS, the architecture was intentionally designed with multi-cloud operational thinking in mind.

Modern organizations increasingly operate across:

* AWS
* Azure
* SaaS platforms
* distributed APIs
* hybrid operational environments

The operational concepts used in this project can extend beyond a single cloud provider.

---

# Technologies Used

* AWS Lambda
* Amazon API Gateway
* Amazon DynamoDB
* Amazon Bedrock
* Amazon SNS
* Amazon CloudWatch
* Amazon S3
* Amazon ECR
* IAM
* Terraform
* Docker
* GitHub Actions
* Python
* REST APIs
* Serverless Architecture

---

# Why This Project Matters

Many cloud projects focus only on deploying infrastructure.

This project focuses on something broader:

How cloud systems can improve operational workflows, incident response, automation, and organizational visibility at scale.

The future of cloud engineering is increasingly connected to:

* automation
* AI-assisted operations
* observability
* operational intelligence
* scalable platform engineering

SenatSupport AI was built to explore those ideas through a realistic operational platform.

---

# Challenges & Solutions

Building SenatSupport AI involved several real-world cloud engineering and operational challenges that helped simulate how modern support platforms are designed, deployed, and maintained at scale.

### 1. Frontend and API Communication

**Problem:**
The frontend application could not communicate properly with backend APIs after deployment.

**Solution:**
Configured API Gateway CORS policies to securely allow communication between the public frontend and backend services.

**Result:**
Users can now create tickets, retrieve analytics, and update workflows successfully through the web portal.

---

### 2. Static Dashboard Analytics

**Problem:**
Operational dashboards initially displayed static values instead of live ticket metrics.

**Solution:**
Created a dedicated analytics API endpoint powered by AWS Lambda and DynamoDB to retrieve real-time operational data.

**Result:**
Director dashboards now update dynamically with live incident statistics.

---

### 3. Lambda Deployment and Container Updates

**Problem:**
Backend updates were not appearing after deployment changes.

**Solution:**
Implemented proper container rebuild and deployment workflows using Docker, Amazon ECR, and GitHub Actions.

**Result:**
Infrastructure and application updates now deploy consistently across environments.

---

### 4. Public Frontend Hosting Permissions

**Problem:**
The frontend website hosted in Amazon S3 was initially inaccessible publicly.

**Solution:**
Configured S3 bucket policies and static website hosting permissions correctly while maintaining controlled access.

**Result:**
The application became publicly accessible through a live hosted frontend portal.

---

### 5. Ticket Lifecycle Update Failures

**Problem:**
Ticket status updates returned internal server errors during lifecycle transitions.

**Solution:**
Enhanced Lambda update logic and added required DynamoDB IAM permissions for ticket updates.

**Result:**
Engineers can now successfully manage tickets through operational lifecycle stages.

---

### 6. Critical Incident Notifications

**Problem:**
High-priority email alerts were not consistently triggering during testing.

**Solution:**
Validated SNS subscriptions, urgency conditions, and notification workflows inside Lambda functions.

**Result:**
Critical incidents now automatically trigger operational alert emails.

---

### 7. Infrastructure Automation Consistency

**Problem:**
Manual infrastructure deployment introduced operational inconsistency and scaling challenges.

**Solution:**
Implemented Infrastructure as Code using Terraform with remote state storage in Amazon S3.

**Result:**
The platform can now be recreated consistently and deployed using automated workflows.

---

# Future Improvements

Potential future enhancements include:

* SLA tracking
* role-based authentication
* real-time websocket updates
* Azure-native integrations
* advanced analytics dashboards
* automated escalation policies
* machine learning recommendation systems

---

# Author

Wilfried Bako

Cloud • DevOps • AI Operations • Infrastructure Automation
