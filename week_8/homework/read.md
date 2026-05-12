“Q & A”
_________
What is the difference between high availability and fault tolerance? Which is best to strive for? 
the difference between high availability and fault tolerance is that high availability is when a service(VM, Instance,etc. ) is available 99.99% or 99.9999% of the time and that if something like a vm goes down, it is easily replaced by another service. Fault tolerance is when a node is cut or fails, the routing for user traffic is little or neglibly affected. Packets can proceeed, for instance, without much or little or no interruption

Explain the difference between autoscaling and elasticity. What is vertical and horizontal autoscaling? Is one better? Are they feasible on prem? 

autocscaling means that nodes or things like instances can scale according to user need or volume need. elasticity means how a system can grow or shrink based on demand. 

Vertical means that the service can scale with one machine. for instance, if you can just add more ram of hd capacity. Verses Horizontal where you scale with the number of machines. this is preferred for cloud native apps
vertical can happen on prem but horizontal is limited. 

Explain what the difference between managed and unmanaged instance groups is.

 managed instance means that the instance is managed by google itself as far as autoscaling, autohealing etc. unmanaged is available but is not recommended. In the real world, managed is the right choice most of the time. unmanaged means it is a vm grouping that you have to manage yourself. 

Explain the different use cases for health checks used by applications (in instance groups) and health checks used by load balancers. Can they be the same? Are they different API calls? Should they be the same? 
Explain in a few sentences what the 3 tier architecture is and how it relates to what you are learning. 

healthchecks are good for checking if apps are healthy or need to be autohealed or replaced. so if a instance fails in an instance group, then it can be dealt with immediately instead of catastrophic failure. health checks for load balancers is considered if traffice should be routed to which vm.  They can use the same endpoint, but they are different API calls and serve different purposes.

you would use separate checks like if the Managed instance group is slow or if service needs to rerouted. 


Three‑Tier Architecture
Presentation : presentation means the UI or web ui

Application : the logic of the application, routing, etc.

Database : storage for application data

section called RunBook:
__________________________





Section called Terraform
_____________________________