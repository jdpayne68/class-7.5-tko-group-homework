# 🌐 SEIR-I Lab 2 — GCP Terraform: Iowa VM + Startup Script + Port 80

![GCP](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=googlecloud&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Nginx](https://img.shields.io/badge/Nginx-009639?style=for-the-badge&logo=nginx&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Shell Script](https://img.shields.io/badge/Shell_Script-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)
![HTTP](https://img.shields.io/badge/Port%2080-HTTP-E34F26?style=for-the-badge&logo=html5&logoColor=white)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen?style=for-the-badge)

---

## 📋 Lab Overview

This lab transitions students from manual "click ops" to infrastructure-as-code using **Terraform on Google Cloud Platform (GCP)**. Students will deploy a Compute Engine VM in the **Iowa region (us-central1-a)** complete with:

- A **Compute Engine VM** provisioned via Terraform
- A **Firewall rule** allowing inbound HTTP traffic on **Port 80**
- A **startup script** that automatically installs **nginx** and serves an ops panel at the following endpoints:
  - `/` — Main ops panel
  - `/healthz` — Health check endpoint
  - `/metadata` — VM metadata endpoint

### 🎯 Workforce Relevance

This lab represents the real transition from cloud consumer to **cloud engineer**:

- Reproducible deployments through code
- Version-controlled infrastructure using Git
- Predictable changes via `terraform plan`
- Reviewable infrastructure diffs before applying

---

## 🛠️ Requirements

The following tools and access are required to complete this lab:

| Tool | Purpose |
|------|---------|
| **Terraform** | Infrastructure provisioning and management |
| **GCP Console** | Cloud resource visibility and management |
| **Google SDK (gcloud CLI)** | Authentication and CLI-based GCP access |
| **Git** | Version control for Terraform files |
| **Web Browser** | Verifying the deployed ops panel at Port 80 |
| **Bash / Terminal** | Running CLI commands and gate validation scripts |
| **GCP Service Account `.json` key** | Authentication for Terraform to provision GCP resources |

---

## 📁 Project / Folder Structure

```
seir-lab2-gcp-terraform/
├── 00-auth.tf                   # Primary Terraform configuration (VM + Firewall)
├── 01-vpc&subnet.tf             # Input variable definitions
├── 03-firewall.tf       
├── 03-compute-instance.tf  
├── 03-outputs.tf                # Output values (e.g., vm_url, vm_external_ip)
├── gate_lab2_http.sh            # Runs the gate checks to make sure that everything configured correctly      
├── startup_script.sh            # Nginx install + ops panel setup
├── README.md                    # This documentation
├── Artifacts                    # Saved screenshots
|   ├── badge.txt
|   ├── gate_pass.png
|   ├── gate_result.png
|   ├── gate_result_detailed_pass.png
|   ├── homepage_ops_panel.png
|   ├── output_vm_url.png
|   ├── terraform_init.png
|   ├── terraform_validate.png
|   ├── terraform_plan.png       # See tfplan document for the full plan
|   ├── terraform_apply.png
|   ├── tfplan
|   └── tfplan

```

---

## 🚀 Steps to Complete the Lab (Assuming you've already run 'gcloud init')

### Step 0 - Prerequisite

Run the following command so that Terraform can have access to the default credentials needed to get this up and running

```bash
gcloud auth application-default login
```

### Step 1 — Set Up Your Terraform Project Folder

Create a local project directory and add your Terraform configuration files (see folder structure above for Terraform file names).

### Step 2 — Add Your GCP Service Account Key

Place your GCP service account `.json` credentials file into your project folder. Ensure it is referenced correctly in your Terraform provider block.

### Step 3 — Initialize Terraform

Run the following command to download required providers and initialize the working directory:

```bash
terraform init
```

### Step 4 — Validate the Configuration

Check your Terraform files for syntax errors and configuration issues:

```bash
terraform validate
```

### Step 5 — Plan the Deployment

Generate an execution plan and save it to a file:

```bash
terraform plan -out tfplan
```

Review the plan output to confirm the expected resources (VM + firewall rule) before applying.

### Step 6 — Apply the Infrastructure

Deploy the resources to GCP using the saved plan:

```bash
terraform apply tfplan  #you could also choose to 'terraform apply -auto-approve'
```

Terraform will provision the Compute Engine VM in `us-central1-a` and configure the firewall rule to allow Port 80.

### Step 7 — Retrieve the VM URL

After a successful apply (in case you cleared the console where this should have already popped up as a result of the last command), retrieve the VM's public URL:

```bash
terraform output vm_url
```

Copy the URL and open it in your web browser to confirm nginx is serving the ops panel.

---

## 📸 Artifacts / Screenshots

> 📌 **"Show Your Work"** — Include screenshots for each major step below.

| # | Screenshot Description | Placeholder |
|---|------------------------|-------------|
| 1 | `terraform init` — Successful provider initialization | Artifacts/terraform_init.png |
| 2 | `terraform validate` — Configuration valid output | Artifacts/terraform_validate.png |
| 3 | `terraform plan` — Plan summary showing VM + firewall rule | Artifacts/terraform_plan.png |
| 4 | `terraform apply` — Successful resource creation output | Artifacts/terraform_apply.png |
| 5 | `terraform output vm_url` — URL displayed in terminal | Artifacts/output_vm_url.png |
| 6 | Gate script pass in terminal | Artifacts/gate_pass.png | 
| 7 | Gate script — Passing all HTTP gate checks | Artifacts/gate_result_detailed_pass.png |

---

## ✅ Gate Validation

All gates must pass before the lab is considered complete.

**Download and run the gate script:**

```bash
# Download gate script and name is gate_lab2_http.sh
curl -o gate_lab2_http.sh https://github.com/cautchybailly/SEIR-1/blob/main/weekly_lessons/weekb/python/gate_lab2_http.sh
```

**Run validation via CLI:**

```bash
VM_IP=$(terraform output -raw vm_external_ip)
VM_IP="$VM_IP" ./gate_lab2_http.sh
```

All HTTP endpoint checks (`/`, `/healthz`, `/metadata`) must return successful responses.

---

## 🧹 Teardown / Destroy Infrastructure

When the lab is complete, destroy all provisioned resources to avoid ongoing GCP charges:

```bash
terraform destroy
```

Confirm the destroy prompt by typing `yes`. Verify in the GCP Console that the VM and firewall rule have been removed.

> 💰 **Cost Tip:** Always run `terraform destroy` immediately after completing the lab. Compute Engine VMs accrue costs even when idle.

---

## 💡 Lessons Learned

### What is Relatable to the User / Customer?
Infrastructure-as-code mirrors how production cloud environments are managed in enterprise settings. Using Terraform means any teammate can reproduce your exact environment from scratch — no more "it works on my machine."

### Struggles Encountered
Error 403 and 404 were coming up in getting everything created. I originally had the wrong project name listed (I was using Saba-Seir as the project but my Terraform code made mention to another name). I used the following to identify what the active project name was and then made sure that my variables file had the correct project name:

```bash
gcloud config list project
```

### Cost Savings After Teardown
_Note any observations about GCP billing after destroying resources. Did you encounter any lingering charges? Were there resources the destroy command missed?_

---

## 📚 References

### GCP / Terraform Documentation
- [Google Cloud Compute Engine Documentation](https://cloud.google.com/compute/docs)
- [Terraform Google Provider Documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Terraform CLI Commands Reference](https://developer.hashicorp.com/terraform/cli/commands)

### Lab Resources
- **Gate Script:** [gate_lab2_http.sh](https://github.com/cautchybailly/SEIR-1/blob/main/weekly_lessons/weekb/python/gate_lab2_http.sh)
- **Course Repository:** [cautchybailly / SEIR-1](https://github.com/cautchybailly/SEIR-1)

### Additional Reading
- **How to Fix Terraform GCP Permission Denied Errors** (https://oneuptime.com/blog/post/2026-02-23-how-to-fix-terraform-gcp-permission-denied-errors/view)

---

## 🔧 Troubleshooting

### Common Issues & Commands

| Issue | Resolution |
|-------|-----------|
| `terraform init` fails | Verify internet connectivity and provider block syntax |
| Credentials error | Confirm `.json` key path in provider block is correct |
| VM unreachable on Port 80 | Check firewall rule targets and startup script execution logs |
| `terraform apply` timeout | Verify GCP project quotas and billing is active |
| nginx not serving content | SSH into VM and check `systemctl status nginx` |

### Useful Commands

```bash
# Check nginx service status on VM
sudo systemctl status nginx

# Restart nginx
sudo systemctl restart nginx

# View startup script logs
sudo journalctl -u google-startup-scripts.service

# SSH into VM via gcloud
gcloud compute ssh <INSTANCE_NAME> --zone=us-central1-a

# View Terraform state
terraform show

# List all Terraform outputs
terraform output
```

---

## 👤 Author & Contributors

| Field | Details |
|-------|---------|
| **Author** | Cautchy Bailly |
| **Group Leader** | Jacques Payne |
| **Group Name** | Tetsuzai Kubo Ouroboros (TKO) |
| **Date** | March 26, 2026 |

---

*Documentation template adapted from SEIR-I Lab standards. Version-controlled for future updates.*