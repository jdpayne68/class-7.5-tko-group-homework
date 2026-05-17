## Q & A

### What is the difference between high availability and fault tolerance? Which is best to strive for?
High availability means your system goes down but comes back up fast so there is minimal loss. Fault tolerance means it never goes down at all, users notice nothing. Fault tolerance is the goal but most companies use high availability because full fault tolerance is expensive. You need fully redundant systems running at all times which costs significantly more.

### Explain the difference between autoscaling and elasticity.
Elasticity is the ability to stretch and shrink based on demand. Autoscaling is what triggers that to happen automatically. They work together when autoscaling triggers elasticity, it is not a vs situation. Vertical scaling adds more power to one machine. Horizontal scaling adds more machines. Horizontal is preferred because it happens with no downtime. On prem both are hard — vertical means physically swapping hardware and horizontal means keeping idle servers on standby. This is a big reason companies move to cloud.

### What is the difference between managed and unmanaged instance groups?
Managed means GCP handles everything meaning all VMs are identical, built from the same template, and GCP manages autoscaling, autohealing, and multi-zone on its own. Unmanaged means you configure and manage everything yourself. Instances can be different from each other. Unmanaged makes sense if you already have existing VMs you need to group together. If you are starting fresh use managed.

### Explain the different use cases for health checks.
Instance group health checks check if the VM is alive. If it fails GCP replaces it automatically that describes autohealing. Load balancer health checks go further and check if the app inside the VM is actually ready for traffic. A VM can be running but the app inside could be broken. They can be the same check but should not be because they serve different purposes. They are configured separately with different API calls, one on the MIG and one on the backend service.

### Explain the 3 tier architecture.
Three tiers — presentation, application, and data. Presentation is what the user sees, the UI and web layer. The load balancer lives here and routes traffic. Application is the backend where the logic happens in GCP this is your managed instance group. Data is where everything gets stored databases, files, etc. 

## Runbook

### End Goal
The goal is to build a fully configured managed instance group in GCP using ClickOps. It will span multiple zones in us-east1, use an instance template, and have autoscaling and autohealing configured and verified.

### Prerequisites
- Make sure your GCP project is selected before you start or you will have to go back and redo things
- Compute Engine API needs to be enabled
- Create your instance template in the same region as your MIG — if the regions do not match the template will not show up in the dropdown
- You need IAM permissions to create Compute Engine resources

### Step 1 — Create Instance Template
1. Compute Engine → Instance Templates → Create Instance Template
2. Name it something like `yourname-instance-template-1`
3. Location → Regional → `us-east1`
4. Machine type → `e2-medium`
5. Boot disk → leave as default Debian
6. Firewall → check Allow HTTP traffic
7. Click Create and wait for it to finish

⚠️ If your template and MIG are not in the same region the template will not appear in the dropdown. Been there.

### Step 2 — Create Managed Instance Group
1. Compute Engine → Instance Groups → Create Instance Group
2. Pick New managed instance group stateless
3. Name it `yourname-mig-1`
4. Location → Multiple zones → `us-east1`
5. Instance Template → pick the one you just made
6. Number of instances → `2`
7. Do not hit Create yet — still need autoscaling and autohealing

### Step 3 — Configure Autoscaling
1. Scroll to Autoscaling → Configure Autoscaling
2. Mode → On
3. Min instances → `2`
4. Max instances → `10`
5. CPU utilization → leave at `60%`
6. Predictive autoscaling → leave Off

### Step 4 — Configure Autohealing
1. Scroll to Autohealing → Health Check dropdown → Create a health check
2. Name it `yourname-health-check-1`
3. Protocol → HTTP
4. Port → `80`
5. Request path → `/`
6. Check interval → `10 seconds`
7. Healthy threshold → `2`
8. Unhealthy threshold → `3`
9. Save it and make sure it shows up before moving on

### Step 5 — Create and Verify
1. Hit Create and wait for it to finish
2. Confirm both VMs are running
3. Check the zones — you want to see at least two different letters like us-east1-b and us-east1-c
4. Autoscaling should show On with min 2 max 10
5. Health check should show as In Use

⚠️ Health check will probably show Timeout at first if there is no web server running on port 80. That is normal in a lab setting.

---

## Terraform

### Mandatory Arguments for a GCP VM
Five things Terraform requires to create a VM. Name is what you call it. Machine type is the size. Zone is where it lives in GCP. Boot disk is the OS and image. Network interface is how it connects to the network and whether it gets an external IP. Leave any of these out and Terraform will not run.

### Outputs
Output blocks print information after terraform apply runs so you do not have to go digging in the console. For the internal IP I used `google_compute_instance.vm.network_interface.0.network_ip`. For external IP I used `google_compute_instance.vm.network_interface.0.access_config.0.nat_ip`. I found both of these in the Attributes Reference section of the Terraform registry docs for google_compute_instance.

### Two Non-Required Arguments
`description` lets you leave a note on the resource explaining what it is for. Good for when other engineers are reading your code and need context without digging through everything. `labels` let you tag resources with key value pairs like `env = "production"` or `team = "devops"` — helps with organizing and filtering resources especially when you have a lot of them.

### Finding the CentOS Stream 10 Image
I ran this in terminal:
```bash
gcloud compute images list --filter="name~'centos'"
```
It gave me a list of CentOS images with the name, project, family and status. The one I needed was `centos-stream-10-v20260505` in the `centos-cloud` project. In the Terraform boot_disk block you reference it as `"centos-cloud/centos-stream-10-v20260505"`.

### name vs id vs self_link
`name` is what you set when you write the config — it is your label for the resource. `id` and `self_link` are set by GCP automatically after the resource gets created, you do not touch those. `id` is GCP's internal unique identifier. `self_link` is the full API URL for the resource — other Terraform resources use it to point to this VM, like a load balancer or firewall rule that needs to know exactly which instance to talk to.