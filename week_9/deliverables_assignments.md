

# README

## Deliverables
This repository includes:
- Documentation and resources used this week, with explanations of how each was used  
- A Q&A section written for a junior cloud engineer  
- A runbook for deploying an external Application Global Load Balancer using ClickOps  
- A Terraform directory containing required infrastructure code  
- Additional configuration for “Be a Man 1” and “Be a Man 2”

---

# Q&A  
*(All answers should be written assuming the reader is a junior engineer with some technical background. Keep explanations clear, grounded, and from first principles.)*

### Load Balancers
- How does load balancing contribute to fault tolerance? What about high availability?  
- Do global load balancers decrease latency for end users? Why or why not?  
- What are LB health checks for? Do we always need them? Is a LB different from a reverse proxy?  
- What are LB routing rules and URL maps for? Provide examples.  
- Explain what an anycast IP address is used for in the context of a global load balancer.

### Cloud Armor
- What does Cloud Armor offer?  
- Why is it used in the first place?  
- What OSI layer does it operate at? Why is this important, and how is this firewall different from VPC firewall rules?  
- What are rate‑based rules for?  
- What is reCAPTCHA and how does it relate to this service?

### Cloud CDN
- What are POPs used for?  
- What kind of files are served with Cloud CDN?  
- What services can be used as origins?  
- Does Cloud CDN help protect against malicious actors or cyberattacks? Explain.  
- Should an enterprise always use Cloud CDN? Why or why not?  
- What is TTL and how does it control content freshness?

---

# Runbook  
*(This section is for engineers executing the task. Keep it high‑level, procedural, and free of unnecessary explanation.)*

## Goal
Deploy a fully configured external Application Global Load Balancer using ClickOps, backed by a Managed Instance Group, including health checks and correct wiring between components.

## Prerequisites
- GCP project with billing enabled  
- Required IAM permissions  
- Instance template prepared  
- Managed Instance Group deployed  
- Firewall rules allowing health check ranges  
- Basic understanding of GCP networking and load balancing components

## Steps
1. Create or verify the Managed Instance Group.  
2. Create a health check appropriate for the application.  
3. Create a backend service and attach the MIG and health check.  
4. Create a URL map and configure routing rules.  
5. Create the global external Application Load Balancer and attach the URL map.  
6. Configure the frontend (HTTP/HTTPS) and assign an external IP.  
7. Review and create the load balancer.  
8. Test the configuration to confirm correct routing and health check behavior.  
9. Document any deviations from class settings and justify them.

---

# Terraform Directory Requirements

## Required Files
- `.gitignore`  
- `main.tf`  
- `variables.tf`  
- `outputs.tf`  
- `vpc.tf`  
- `firewall.tf`  
- `mig.tf`  
- `loadbalancer.tf`  
- Any additional logically separated files

## Critical Requirements
- No state files or lock files committed  
- No provider binaries committed  
- Code must run with `terraform init`, `terraform validate`, and `terraform apply`  
- All code written by the student or group  
- Follow Terraform best practices and style guide  
- Use latest provider version  
- Include informative outputs  
- Use comments to make the code self‑documenting  
- Explain any non‑obvious values or arguments  
- No unnecessary resources

## Configuration Requirements
- Custom VPC  
- Firewall rules using target tags  
- Managed Instance Group with class‑consistent settings  
- External global load balancer (Be a Man 1)  
- Two backend services with path‑based routing (Be a Man 2)  
- Optional Cloud CDN configuration with notes

---

# Be a Man 1
Terraform configuration to deploy an external global load balancer building on the week’s assignment.

---

# Be a Man 2
Add two backend services:
- “colombia”  
- “thailand”  

Configure routing so that:
- `/colombia` serves a basic webpage with a Colombian-themed image  
- `/thailand` serves a basic webpage with a Thai-themed image  

Optional: Add Cloud CDN and include notes on configuration decisions.

