# Week 8 GCP Homework
---------------------------------------------

## Q&A (answer between 1 and 5 sentences)

1) What is the difference between high availability and fault tolerance? Which is best to strive for?

High availability refers to an agreed level of performance and choosing the services that meet that desired performance reliably. Fault tolerance means designing a system with redundancy(replica systems) so that it continues to operate correctly without interruption when something fails. When it comes to which is best to strive for it really depends. If it is a major company that absolutely cannot have any downtime ever, then fault tolerance is best. The trade off is that it will cost extra because replicas of the system will be useful.

2) Explain the difference between autoscaling and elasticity. What is vertical and horizontal autoscaling? Is one better? Are they feasible on prem?

Autoscaling is an automated monitoring of the system that adds or removes specific resources in response to workload demands. Elasticity would refer to a system as a whole being able to expand and contract automatically in order to meet the demands of the workload. Essentially autoscaling and elasticity go hand in hand. Vertical scaling is the ability to increase the capabilities of a single unit by scaling up or down (upgrade/downgrade). This usually involves adding more power like processors or RAM. Horizontal scaling is the ability to add more resources by scaling out. This would involve adding more servers or VMs so the workload could be spread out more. Both horizontal and vertical scaling have their pros and cons so it depends on what the need of the company is. For larger scale systems, horizontal scaling would be best. Yes.

3) Explain what the difference between managed and unmanaged instance groups is.

An unmanaged instance group is a collection of VM instances that you create and manage individually. The benefit of an unmanaged instance group is needing a more hands on interaction and needing to manages the instance yourself. This also means no autoscaling. A managed instance group (MIG) is a collection of VM instances created from a single instance template. When managed, the benefits include autoscaling, auto-updates and being deployable in multiple zones. 

4) Explain the different use cases for health checks used by applications (in instance groups) and health checks used by load balancers. Can they be the same? Are they different API calls? Should they be the same?

Health checks act as a trigger for auto healing purposes. The health checks used to monitor MIGs are similar to the health checks used for load balancing. Instance group health checks signal to delete and recreate instances that become unhealthy and load balancing health checks help direct traffic away from unhealthy instances and toward healthy instances. While they are similar, they are different in the sense that they serve different purposes.

5) Explain in a few sentences what the 3 tier architecture is and how it relates to what you are learning.

Three‑tier architecture splits into presentation, application, and data layers so each layer can scale, be secured, and be managed independently. The presentation tier displays information and collects the information. The application tier can add/delete/modify data. The data tier stores and manages the data. In relation to what we are learning: Tier 1 (presentation) generates events; Tier 2 (application) notices those events ; Tier 3 (data) records and stores the event.  

# Resources
- https://cloudwebschool.com/docs/gcp/architecture-and-best-practices/designing-highly-available-systems/
- https://cloud.google.com/blog/products/databases/breaking-down-cloud-sqls-3-fault-tolerance-mechanisms
- https://docs.cloud.google.com/compute/docs/instance-groups#benefits
- https://docs.cloud.google.com/compute/docs/load-balancing-and-autoscaling#autoscaling
- https://www.couchbase.com/blog/scalability-vs-elasticity/
- https://www.geeksforgeeks.org/system-design/system-design-horizontal-and-vertical-scaling/
- https://docs.cloud.google.com/compute/docs/instance-groups#unmanaged_instance_groups
- https://docs.cloud.google.com/compute/docs/instance-groups#autohealing
- https://www.ibm.com/think/topics/three-tier-architecture
- https://docs.cloud.google.com/load-balancing/docs/application-load-balancer#three-tier_web_services

# Week 8 Runbook
---------------------------------------------

## Goal:
 
- Create a fully configured managed instance group via ClickOps, with autoscaling, autohealing, and health checks enabled, and be able to verify the group will manage across multiple zones.

## Prerequisites:

- Google Cloud Account
- A project in GCP
- API enabled
- Instance template
- Startup script for the VMs

## Steps

1) Instance Template
Click on the 3 hash sign in top left of corner > Compute Engine > Instance Template > create instance template > Name the instance > regional or global/choose appropriate region > select allow http traffic > provide the appropriate startup script > create

![[Navigation menu.png]]
![[Compute Engine to Image Template.png]]
![[Create instance template.png]]
2) Instance group
Compute Engine > Instance Groups > create instance groups > Name the instance group (add description if desired/needed) > select the appropriate instance template > put in the number of desired templates > Multiple zones > select region and zone > autoscaling > autoscaling mode: on > minimum number of instances: 4 & maximum: 10 > mandatory health check addition(autohealing check next step) > create

![[Compute Engine to Instance Group.png]]

2) Health Check/Auto healing (must be created in instance group process)
Health check > create a health check > name the health check (lowercase, no spaces, add description if desired/needed) > regional scope > TCP Port 80 > logs on > default health criteria (or whatever heath criteria is desired/needed) > save
![[Autohealing Health Check.png]]

3) Once the MIG is created, wait for the green check under status that lets you know that it is properly deployed
![[MIG double check.png]]

4) SSH into one of the instances to make sure everything is working properly
![[SSH example.png]]
5) Take the external IP of one of the instances and, in a new tab go to http://yourexternalip



# Week 8 Terraform
---------------------------------------------

## The mandatory (required) arguments for a VM in terraform.

- boot_disk: This would be the boot disk for the instance.
- machine_type: This is the type of machine to create.
- name: A unique name of the resource that is being created.
- network_interface: This will specify the networks that will attach to the instance.

## How to output the internal and external IP addresses of the provisioned VM.

- internal ip = network_interface.0.network_ip
- external ip = network_interface.0.access_config.0.nat_ip

This can be figured out by reading through the terraform registry google documentation.

## 2 non-required arguments

- description: This optional argument can be used to briefly describe the resource
- desired_status: This optional argument can be used to manage the state of an instance. The 3 options are "RUNNING", "SUSPENDED" or "TERMINATED". "RUNNING" is the default state and it ensure the instance is powered on. "TERMINATED" will stop the instance. This would be used to save costs by having an instance not running but you want to keep configured. "SUSPENDED"saves the current state of the instance to storage and stops it.

## Explain how you would figure out the correct format for creating a VM with the "centOS stream 10" image.

In order to do that I would have to go to the google console. Afterwards I would create an instance. Next, I would go to the option of IS and storage, click on change. Under public image, there should be an option to choose CentOS as well as the preferred version I want.

## Explain the difference between the "name" argument and the compound "id" and "self_link" attributes.
Name is a unique identifier that is created by the user. ID would be the unique identifier that is created by the server. Self_link provides a url that can point directly to the resource. 

# Resources
- https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance
- https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/google-cloud-platform-outputs



