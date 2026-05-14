# Runbook

Goal: to create fully configure external application global load balancer in clickops, with a MIG as the backend. And showing how to connect the load balancer up to a MIG.

Prerequisites:
Google Account
Global Instance Template


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


**Section 4 Teardown** 
1. On the Load balancer page check the box for the load balancer and click delete at the top
![Delete Load Balancer](./screenshots/teardown_load_balancer_01.png)
2. On the load balancer page click on backends check the box for the backend and click delete at the top 
![Delete Backends](./screenshots/teardown_backend_03.png)
3. Go to Instance group page check on the instance groups and click delete at the top 
![Delete Instance Groups]()
4. Go to Health check page check on the health check and click delete at the top 
![Delete Health Checks](./screenshots/teardown_health_check_04.png)

** Note the Load balancer has to be deleted first, the instance group can't be deleted if they are in use by a load balancer.

** Note the backend has to be deleted first, health checks can't be deleted if in use by a backend.



# Q&A

## Load Balancers

How does load balancing contribute to Fault tolerance? What about high availability? 

Do global load balancers decrease latency for end users? Why or why not? 

What are LB health checks for? Do we always need them? Is a LB different from a reverse proxy? 

What are LB routing rules and URL maps for? Give an example or two of them in use. 

Explain what an anycast IP address is used for in the context of a global load balancer. 


## Cloud Armor

What does cloud armor offer? 

Why is it used in the first place?

What layer in the OSI model does it operate at? Why is this important and how is this firewall different from VPC firewall rules? 

What are rate based rules for? 

What is reCAPTCHA and how does it relate to this service? 


## Cloud CDN

What are POPs used for? 

What kind of files are served with Cloud CDN? 

What services can be used with cloud CDN for the source of content (the origin)? 

Does Cloud CDN help protect against any types of malicious actors or cyberattacks? Explain. 

Should an enterprise always use cloud CDN? Why or why not? 
What is TTL and how does it control content “freshness”? 

