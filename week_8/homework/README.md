# week-8-hw-class-7.5


# **Q & A**
---

### **What is the difference between high availability and fault tolerance? Which is best to strive for?**

the difference between high availability and fault tolerance is that high availability is when a service(VM, Instance,etc. ) is available 99.99% or 99.9999% of the time and that if something like a vm goes down, it is easily replaced by another service. Fault tolerance is when a node is cut or fails, the routing for user traffic is little or neglibly affected. Packets can proceeed, for instance, without much or little or no interruption.

---

### **Explain the difference between autoscaling and elasticity. What is vertical and horizontal autoscaling? Is one better? Are they feasible on prem?**

autocscaling means that nodes or things like instances can scale according to user need or volume need. elasticity means how a system can grow or shrink based on demand.

Vertical means that the service can scale with one machine. for instance, if you can just add more ram of hd capacity. Verses Horizontal where you scale with the number of machines. this is preferred for cloud native apps. vertical can happen on prem but horizontal is limited.

---

### **Explain what the difference between managed and unmanaged instance groups is.**

managed instance means that the instance is managed by google itself as far as autoscaling, autohealing etc. unmanaged is available but is not recommended. In the real world, managed is the right choice most of the time. unmanaged means it is a vm grouping that you have to manage yourself.

---

### **Explain the different use cases for health checks used by applications (in instance groups) and health checks used by load balancers. Can they be the same? Are they different API calls? Should they be the same?**

healthchecks are good for checking if apps are healthy or need to be autohealed or replaced. so if a instance fails in an instance group, then it can be dealt with immediately instead of catastrophic failure. health checks for load balancers is considered if traffice should be routed to which vm. They can use the same endpoint, but they are different API calls and serve different purposes.

you would use separate checks like if the Managed instance group is slow or if service needs to rerouted.

---

### **Explain in a few sentences what the 3 tier architecture is and how it relates to what you are learning.**

Three‑Tier Architecture  
Presentation : presentation means the UI or web ui  
Application : the logic of the application, routing, etc.  
Database : storage for application data  

---

# **Runbook**
---

### **Goal**
I want to create a managed instance group created via Clickops.  
I want to host an app on a instance group via a instance in an instance template. Once the instance template is made, I make an instance modeled on the template. Then I want the instance be in a group so they can be managed automatically by a MIG. This will enable autoscaling and autohealing. Also, we need to make sure that we choose Regional which is multizone for this to work(at least two zones). I need to make at least three for this to work or it will not work. I need to also make sure http is clicked so that the app can be visible online.

---

### **Steps**

#### **1. Create the Managed Instance Group**
- Go to Compute Engine  
- Instance groups  
- Create instance group  
- Select Managed instance group  
- Choose Regional (required for multi‑zone)  
- Select your instance template  
- Choose at least two zones in the region  

#### **2. Enable autoscaling**
- choose On: autoscale by CPU(for metrics)

#### **3. Enable autohealing**
- this is where you attach a health check

---

# **Terraform**
---

### **mandatory (required) arguments for a VM in terraform**
- name: resource name inside GCP  
- machine type: defines cpu/ram  
- zone: where the vm runs  
- boot_disk: includes image  
- network_interface: defines vpc and subnet  

---

### **Explain how to output the internal and external IP addresses of the provisioned VM and how you figured this out**

write output code in terraform:

```
output "internal_ip" {
    value = google_compute_instance.vm.network_interface[0].network_ip
}

output "external_ip" {
    value = google_compute_instance.vm.network_interface[0].access_config[0].nat_ip
}
```

---

### **Choose 2 non-required arguments and give an explanation for both**

metadata: this is the ky/value data to the VM, often used for startup scripts  
labels: key/value tages for billing, automation  

---

### **Explain how you would figure out the correct format for creating a VM with the “centOS stream 10” image**

you can use a gcloud command to find this. Use `gcloud compute images list` to search the GCP catalog.  
We can identify the project, image family and image naem.

---

### **Explain the difference between the “name” argument and the computed “id” and “self_link” attributes**

name is the resource name you assign  
id is a unique identifier given by GCP  
self_link the full url path to the resource, used by apis  

---
