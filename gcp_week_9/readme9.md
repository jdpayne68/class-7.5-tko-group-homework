# Runbook

Goal: to create fully configure external application global load balancer in clickops, with a MIG as the backend. And showing how to connect the load balancer up to a MIG.

Prerequisites:

Google Account

Global Instance Template

Locust


## Steps

1. Log into your google account


**Section 1 Global Instance Template**
1.  Go to the 3 hashes in the top left corner, on the drop down click Compute Engine and Instance templates
![Instance Template](./screenshots/instance_template_01.png)
2. Click on create instance template
    - Name the instance template (preferably something that fits what you are creating using it for). 
    ![Create](./screenshots/instance_template_create_02.png) 
    - Make sure Global is seleted (if you don't you are stuck on the one region)
    ![Global](./screenshots/instance_template_global_03.png) 
    - Go down to the firewall and make sure Allow HTTP traffic is checked in (if not the startup script will timeout when trying to run it)
    ![Firewall](./screenshots/instance_template_firewall_04.png) 
    - Click on Advanced options and go to Management -> Automation -> Startup Script add the script you are planning to use.
    - Once done click on the Create button on the bottom left
    ![Startup](./screenshots/instance_template_startup_05.png) 


**Section 2 MIG**
1.  As in the first section go to the 3 hashes in the top left corner go to Compute Engine and Instance groups
![Instance Group](./screenshots/instance_group_01.png) 
2. Click on Create Instance Group
![](./screenshots/instance_group_create_02.png) 
    - Name the instance group and make sure to choose the Global instance template(if you don't you can't change the region)
    ![Name](./screenshots/instance_group_name_03.png) 
    - Go to the Location section choose multiple zones, the region and zones you plan on using 
    - Set up the Autoscaling with the minimum and maximum  number of instances you will need 
    ![Location/Autoscaling](./screenshots/instance_group_location_04.png) 
    - Go to the VM instance lifecycle and Autohealing -> Health check,  if you have one created already you can use it, if not   
3. Click on create a health check 
    - Name it and give a Description
    - Scope = Global
    - Protocol = TCP
    - Port = 80
    - Logs = On
    - Health criteria leave default or change check interval to 10.  When done click save
    ![Health Check](./screenshots/instance_group_health_05.png) 
5. Once all that is set click Create in the bottom right corner 
![Create](./screenshots/instance_group_finish_06.png)

** Note this process has to be done multiple times depending on how many MIGs you plan on using.


**Section 3 Global Load Balancer**
1.  Type in the search bar Load Balancer, click on load balancing. It will take you to the load balancing page click on Create load balancer.
![Load Balance](./screenshots/load_balancing_01.png)
    - Type of load balancer = Application Load Balancer (HTTP/HTTPS)
    ![Application](./screenshots/load_balancing_application_load_02.png)
    - Public facing or internal = Public facing (external)
    ![Public](./screenshots/load_balancing_public_03.png)
    - Global or single region deployment = Best for global workloads
    ![Global](./screenshots/load_balancing_global_04.png)
    - Load balancer generation = Global external Application Load Balancer 
    ![Global External](./screenshots/load_balancing_global_external_05.png)
    - Create load balancer = Configure
    ![Configure](./screenshots/load_balancing_configure_06.png)
2. It will go to the load balancer setup page, name your load balancer
3. Click on Frontend configuration give it a name and description, protocol HTTP, leave the rest default, click done.
![Frontend](./screenshots/load_balancing_frontend_07.png)
4. Click on backend configuration, click on the Backend services & backend buckets -> Create a backend service
![Backend](./screenshots/load_balancing_public_backend_08.png)
    - Give it a name and description
    - Backend type = Instance group
    - Protocol = HTTP
    - Named port = http
    - timeout = you decide
    - IP address selection policy = Only IPv4
    - Health check = circle back to Section 2
- Create New backend(s)
    - Ip stack type = IPv4 (single-stack)
    - Instance group = choose the instance group(s)
    - Port numbers = 80
    - Balancing mode = Rate
    - Traffic duration = default(Short)
    - Maximum RPS = you decide
    - the rest can be left default
- Click done and click on Add a backend repeat this process for all the instance groups you plan on using.
![Backend Setup](./screenshots/load_balancing_backend_setup_09.png) 
- Uncheck the Cloud CDN
![Cloud CDN](./screenshots/load_balancing_cloud_cdn_010.png)
- Go to Cloud Armor and set it to None, once that is done click Create at the bottom.
![Cloud Armor](./screenshots/load_balancing_cloud_armor_011.png)
5.  Click on Create a backend bucket, name it and give description. Cloud Storage bucket click Browse and choose the bucket you plan on using.
- Uncheck Cloud CDN once again and click create at the bottom.
![Backen Bucket](./screenshots/load_balancing_backend_bucket_012.png)
6. Click on Routing rules mode -> Simple host and path rule, and delete the Backend2
![Routing Rules](./screenshots/load_balancing_routing_rules_013.png)
7. Once that is done review everything done up to that point, make sure its correct. Click on create at the bottom.
![Review](./screenshots/load_balancing_review_finalize_014.png)
8.  When it is done creating click on it and find the IP:Port copy the ip address (the 4 octet) and paste it into your browser (ex.http://0.0.0.0)
![IP Address](./screenshots/load_balancing_ip_address_015.png)
    - This will check if it has been setup correctly, if done correctly this is how it should look.
    ![SC Instance Group](./screenshots/load_balancing_website1_016.png)
    - It should cycle through the Instance Groups
    ![Berlin Instance Group](./screenshots/load_balancing_website2_017.png)


**Section 4 Teardown** 
1. On the Load balancer page check the box for the load balancer and click delete at the top
![Delete Load Balancer](./screenshots/teardown_load_balancer_01.png)
2. On the load balancer page click on backends check the box for the backend and click delete at the top 
![Delete Backends](./screenshots/teardown_backend_03.png)
3. Go to Instance group page check on the instance groups and click delete at the top 
![Delete Instance Groups](./screenshots/teardown_instance_group_02.png)
4. Go to Health check page check on the health check and click delete at the top 
![Delete Health Checks](./screenshots/teardown_health_check_04.png)

** Note the Load balancer has to be deleted first, the instance group can't be deleted if they are in use by a load balancer.

** Note the backend has to be deleted first, health checks can't be deleted if in use by a backend.

**Bonus Create a Bucket**
1. Go to the 3 hashes on the top left corner Cloud Storage -> Buckets
![Create Bucket 1](./screenshots/create_bucket_01.png)
2. Click on create bucket
![Create Bucket 2](./screenshots/create_bucket_02.png)
3. Name the bucket click -> Continue, leave the rest of the chooses as default 
![Create Bucket 3](./screenshots/create_bucket_03.png)
![Create Bucket 4](./screenshots/create_bucket_04.png)
![Create Bucket 5](./screenshots/create_bucket_05.png)
4. Click on create bucket in the bottom left 
![Create Bucket 6](./screenshots/create_bucket_06.png)


# Q&A

## Load Balancers

**How does load balancing contribute to Fault tolerance? What about high availability?** 

It checks for unhealthy or failed instances/servers and routes traffic to the healthy instances/servers that protects against downtime. That also insures that SLA is being honored.

**Do global load balancers decrease latency for end users? Why or why not?** 

Yes by way one of its features CDN, by sending traffic to the nearest edge location to the user, this cached content can be drawn upon when need at a much quicker rate.

**What are LB health checks for? Do we always need them? Is a LB different from a reverse proxy?**

They check for the health of instances, see if its failed/unhealthy and redirects traffic to healthy instances/servers. Yes in production envirnomentsand you need high avialabilty with minimum downtime. They are similar like they both sit in front of servers, but do different things, Load Balancers deals with spreading traffic around multiple servers, reverse proxy deals with one or more and manages the server.


**What are LB routing rules and URL maps for? Give an example or two of them in use.**

Routing rules are the set of methods used to move traffic to the correct destination, URL maps are whats used to route by using the routing rules, they work together to move traffic. Proximity based routing which uses the closest instance to the traffic source to get to the destination.

**Explain what an anycast IP address is used for in the context of a global load balancer.**

Anycast allows the use of a single IP address, so only one GLB is needed for multiple locations.

[Load Balancer](https://cloud.google.com/blog/topics/developers-practitioners/google-cloud-global-external-https-load-balancer-deep-dive)

[Reverse Proxy 1](https://www.f5.com/glossary/web-application-firewall-waf)

[Reverse Proxy 2](https://www.cloudflare.com/learning/ddos/glossary/web-application-firewall-waf/)

[Reverse Proxy Vs. Load Balancer](https://www.upguard.com/blog/reverse-proxy-vs-load-balancer)

[Anycast](https://en.wikipedia.org/wiki/Anycast)


## Cloud Armor

**What does cloud armor offer?**

It offers protections to application and websites aaginst Denial of Service (DDoS) and other website attacks (SQL Injection, cross-site scripting, etc.).

**Why is it used in the first place?**

To protect against website attacks/intrusions, also the fact that more of these attacks are starting to become common, especially considering how the majority of jobs now incorpporates some form of network infrastructure, services like this are needed more and more.

**What layer in the OSI model does it operate at? Why is this important and how is this firewall different from VPC firewall rules?**

It operates at Layer 7 Application (front), at the same time it does provider defense for Layer 3 & 4 as well. It works on the frontend to keep thing secure and protect against DDoS attacks, VPC firewall are rules for the network Layers 3 & 4, as opposed to cloud armor which does provide some defense for Layers 3 & 4 it mainly works at Layer 7. 
What are rate based rules for? 

**What is reCAPTCHA and how does it relate to this service?**

reCAPTCHA is a bot blocking tool, its used to confirm if the person is human, cloud armor can incorporate reCAPTCHA for bot protection.

[Cloud Armor Overview](https://docs.cloud.google.com/armor/docs/cloud-armor-overview)

[Cloud Armor](https://cloud.google.com/blog/topics/developers-practitioners/when-should-i-use-cloud-armor)

[Cloud Armor Policy](https://docs.cloud.google.com/armor/docs/security-policy-overview)

[reCAPTCHA](https://cloud.google.com/security/products/recaptcha?hl=en)

[OSI Model](https://www.cloudflare.com/learning/ddos/glossary/open-systems-interconnection-model-osi/)

[Layer 7](https://www.cloudflare.com/learning/ddos/what-is-layer-7/)



## Cloud CDN

**What are POPs used for?**

Points of Presence (POP) are used to get cached content from a edge location to users without having to connect to the origin server.


**What kind of files are served with Cloud CDN?**

It serves cached content such as images, video, webpages, scripts and font files 

**What services can be used with cloud CDN for the source of content (the origin)?**

Any services that uses HTTP/HTTPS, like Compute Engines (VM), Cloud Storage (buckets), Kubernates, Load Balancers, and Serverless

**Does Cloud CDN help protect against any types of malicious actors or cyberattacks? Explain.**

Yes its a frontend barrier of entry to the origin, by using caching attackers usually won't be able to hit the origin server.  Using this in tandem with Cloud Armor is what makes this a powerful protection tool. 

**Should an enterprise always use cloud CDN? Why or why not? What is TTL and how does it control content “freshness”?** 

It depends on the enterprise if its global I believe its beneficiary to use with edge locations and being able to cache information and get it redistributed quicky through the CDN, if its smaller and mostly internal (local) the caching doesn't help and that service wouldn't be fully taken advantage of. It is time to live, it controls how long data is cached before it expires.

[Cloud CDN 1](https://docs.cloud.google.com/cdn/docs/overview)

[Cloud CDN 2](https://www.geeksforgeeks.org/cloud-computing/what-is-google-cloud-cdn/)

[Cloud CDN 3](https://www.cloudflare.com/learning/cdn/what-is-a-cdn/)

[CDN Best Pratices](https://docs.cloud.google.com/cdn/docs/best-practices)

[TTL 1](https://www.cloudflare.com/learning/cdn/glossary/time-to-live-ttl/)

[TTL 2](https://docs.cloud.google.com/cdn/docs/using-ttl-overrides)


## Author & Contributors

**Author:** `Joe Tolliver`

**Group Leader:** `Jacques Payne`

**Group Name:** `T.K.O.`

**Date:** `5/13/2026`

**Version:** `1.0`