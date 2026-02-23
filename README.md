# 3tier_eks
EKS 3-Tier Architecture Deployment (Flask + Kubernetes) This project demonstrates deploying a containerized Flask application to an Amazon EKS (Elastic Kubernetes Service) cluster using Kubernetes manifests.  The application is exposed publicly via an AWS LoadBalancer service and includes a /health endpoint for basic health monitoring.


---

# 🚀 3-Tier Flask Application Deployment on AWS EKS

## Overview

This project demonstrates end-to-end deployment of a containerized Flask application on **AWS EKS**, orchestrated via **Terraform**. It showcases production-ready patterns for networking, security, scalability, and observability.

The solution emphasizes:

* Declarative infrastructure provisioning with Terraform
* Kubernetes-native application deployment
* Secure VPC and subnet architecture
* Continuous monitoring with CloudWatch

---

## Infrastructure as Code (IaC)

**Tool:** Terraform (v1.x+)

**Rationale:**

* Ensures reproducibility across environments
* Tracks infrastructure state, reducing drift
* Integrates natively with AWS services
* Supports modular, reusable infrastructure patterns

---

## Provisioned Components

### Networking

* **VPC:** Isolated network (CIDR `10.0.0.0/16`)
* **Subnets:** Multi-AZ private and public subnets for high availability
* **Internet Gateway & NAT:** Enables controlled outbound traffic for nodes

### Identity & Access

* **IAM Roles:**

  * EKS Cluster Role → Control plane operations
  * Node Group Role → EC2 nodes for image pulls, logging, and metrics
* **Attached Policies:** AmazonEKSClusterPolicy, AmazonEKSWorkerNodePolicy, AmazonEC2ContainerRegistryReadOnly, CloudWatchAgentServerPolicy

### Compute & Orchestration

* **EKS Cluster:** Managed control plane, auto-scaled worker nodes
* **Pods:** Containerized Flask app in Python 3.9
* **Services:** Kubernetes LoadBalancer exposing HTTP traffic

---

## Terraform Workflow

```bash
terraform init        # Initialize backend & modules
terraform validate    # Validate HCL configuration
terraform plan        # Preview infrastructure changes
terraform apply       # Deploy infrastructure
```

**Outcome:**

* VPC, subnets, and networking fully configured
* EKS cluster and worker nodes provisioned
* IAM roles assigned
* LoadBalancer service exposed

---

## Application Deployment

1. **Update kubeconfig:**

```bash
aws eks update-kubeconfig --region us-east-1 --name 3tier-eks-cluster
```

2. **Deploy Kubernetes manifests:**

```bash
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f ingress.yaml
```

3. **Containerization:**

```dockerfile
FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .
EXPOSE 5000
CMD ["python", "app.py"]
```

* Pushed to Docker Hub for public access:

```bash
docker build -t <docker-username>/3tier-flask:latest .
docker push <docker-username>/3tier-flask:latest
```

---

## Kubernetes Networking & VPC Integration

* Service type `LoadBalancer` automatically provisions AWS ELB
* ELB routes traffic to NodePort → Pod
* Worker nodes in private subnets remain secure
* Security Groups allow:

  * Inbound: HTTP (80)
  * Internal pod-to-pod traffic
  * Outbound internet access for image pulls

---

## Monitoring & Observability

* **Pod Logs:** `kubectl logs <pod-name>`
* **Metrics:** CPU, memory, pod restarts, node health via **CloudWatch Container Insights**
* **Alarms & Dashboards:** CloudWatch monitors cluster health and traffic patterns

---

## Architecture (Logical Flow)

```
    ┌───────────────┐
    │     Users     │
    └───────┬───────┘
            │
    ┌───────▼───────┐
    │ AWS ELB       │
    └───────┬───────┘
            │
    ┌───────▼───────┐
    │ K8s Service   │
    │ LoadBalancer  │
    └───────┬───────┘
            │
    ┌───────▼───────┐
    │ EKS Workers   │
    │ (Private AZs) │
    └───────┬───────┘
            │
    ┌───────▼───────┐
    │ Flask Pods    │
    │  /health      │
    └───────────────┘
```


---

Do you want me to **create the draw.io-ready diagram next**? I can provide the exact shapes and connections so you just drag and drop.


