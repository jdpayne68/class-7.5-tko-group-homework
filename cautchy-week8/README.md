## Q&A (each answer between 1 and 5 sentences)
- What is the difference between high availability and fault tolerance? Which is best to strive for? 

High availability refers to an agreed upon level of performance (as per your service level agreement). You want as much uptime as you can have but will only get 99.999% guaranteed for example. Fault tolerance refers to the ability of the system to work without EVER having a down moment. This involves setting up failovers so that if something does go down, you have redundancy (something else to take over while primary resources). It's kinda in the name : with fault tolerance we're looking for a system that will still thrive regardless of what "fault" may occur. The way to be so cool is to have the failovers set up to pick up the slack where and when needed. Fault-tolerance is best to strive for.

- Explain the difference between autoscaling and elasticity. What is vertical and horizontal autoscaling? Is one better? Are they feasible on prem? 

Scalability refers to the ability to grow as needed in order to accomodate an increasing workload. This is done by adding more resources to the setup (adding more servers, more storage, more network bandwidth etc.) This ensures that a business can keep up the level of service as demand increases.

Elasticity refers to a system's ability to bounce back. Once the increasing workload that triggered the scaling goes down, an elastic system will be able to downsize to meet current demands (and save resources as a result). This is necessary for resource allocation and cost optimization purposes.

Vertical autoscaling involves upgrading (scaling up) and downgrading (scaling down) by adding on more power(upgrading your CPUs) or going down in power with the goal to meet demand at the appropriate level. This is a single node though just swapping out the V6 for a V8 etc.

Horizontal autoscaling involves adding more resources in order to spread the workload across those resources. Think more stormtroopers as needed, so you send out more to handle the commotion. Call them back whenever you no longer need them.

In regards to what is best: vertical autoscaling is great for older (legacy) applications and small scale integration. Horizontal autoscaling is great for systems running on containers for example. Just scale out and add more containers. (Because of this you can scale horizontally on-prem with tools like Kubernetes). You also want to scale where predictable (i.e. consistently more traffic during weekend hours)

- Explain what the difference between managed and unmanaged instance groups is.

An unmanaged instance group is self-maintained (YOU do the load balancing across VMs that YOU manage yourself). A managed instance group (MIG) lets you operate on multiple VMs and can be configured to automatically do what is needed to keep the system alive per your standards (autoscaling, autohealing, auto-updates, deployable in multiple zones). MIGs are great for stateless architecture due to the highly available nature and the scalability. They are also great for stateful architecture on each restart (they preserve each instance's state)

- Explain the different use cases for health checks used by applications (in instance groups) and health checks used by load balancers. Can they be the same? Are they different API calls? Should they be the same? 

Both of them are compute.healthcheck in GCP. They both work through being polled at specific defined intervals. Health checks act as a trigger for autohealing purposes. If something fails to respond, the MIG automatically 86s it and builds a new VM to restore service. Being used with LBs though it works differently; when an instance becomes unhealthy and new ones need to be made, the health checks will let the system know to steer traffic away from the unhealthy to the healthy. Separation matters in use though; if you use the same endpoint you may end up with a replacement loop (for traffic management reasons you want to know if unhealthy so you can go elsewhere)

- Explain in a few sentences what the 3 tier architecture is and how it relates to what you are learning. 

3-tier architecture refers to having a presentation tier (1 : front end), a logic tier (2 : application/brain of the project) and a data tier (3 : back-end database). When it comes to the event driven architecture that we are learning to build, the event generation happens in tier 1; the processing (event is noticed, triggers the next action) happens in tier 2 

## Runbook

### Goal (3 sentences max)
- A fully configured managed instance group created via ClickOps


### Prerequisites (what do I need to have ready to make this happen?)
- A project in GCP
- API enabled
- instance template to define the VMs being configured

## Terraform

- Mandatory Requirements for a VM in Terraform (GCP)
    - VM resource name for Terraform in GCP : google_compute_instance
        - boot_disk
            - the required boot disk 
        - machine_type
            - the machine type to create
        - name 
            - the name of the resource being created
        - network_interface


- How to output the internal and external IP addresses of the provisioned VM 
    - Create an output block
        - make sure that the output block calls on an attribute resource for the VM block that will show the internal and external IP 
            - Calling on the 'network_interface.0.network_ip' attribute will indicate the internal IP address of the instance and calling on the 'network_interface.0.access_config.0.nat_ip' will show the given external ip
        - This was learned from going through the documentation (Terraform Registry and in Google's Documentation)

- Choose 2 non required arguments and give an explanation for both
    - Description
        - This will be where you put the brief description of the resource    
    - Hostname 
        - can be used to give a custom hostname for the instance (must follow RFC-1035 guidelines). When this is added, it forces Terraform to create a new resource

- Explain how you would figure out the correct format for creating a VM with the "centOS stream 10" image.
    - Go into console.cloud.google.com > Create instance > OS and Storage > click on Change > Select CentOS as Operating System > Select the Version of CentOS based on whether you're running on Arm64 or x86/64

- Explain the difference between the "name" argument and the compound "id" and "self_link" attributes
    - with name being an argument, you fill it out and provide the information for the resource to be built. With the "id" argument



RESOURCES USED: 
- https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/google-cloud-platform-change
- https://github.com/cautchybailly/terraform-docs-samples
- https://docs.cloud.google.com/docs/terraform/create-vm-instance
- https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#description-1
- https://docs.cloud.google.com/compute/docs/instance-groups
- https://www.ibm.com/think/topics/three-tier-architecture