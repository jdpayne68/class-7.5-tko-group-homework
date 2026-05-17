SEIR-1 Week 9 Homework

Q & A

Load Balancers

How does load balancing contribute to fault tolerance? What about high availability?
Load balancing helps with fault tolerance because the LB uses health checks to see which backend servers are working. When a server fails the health check, the LB stops sending traffic to it and shifts that traffic to healthy servers, which keeps the application running. It also helps with high availability because the LB can spread traffic across multiple backends in different zones or regions, so even if one zone goes down, users still get served.

Do global load balancers decrease latency for end users? Why or why not?
Yes, global LBs decrease latency. The global LB uses anycast a single IP advertised from many of Google's data centers around the world so a user gets routed to the closest data center automatically. It's like traveling to a nearby city instead of having to travel to another state: the closer the data center, the faster the connection.

What are LB health checks for? Do we always need them? Is a LB different from a reverse proxy?**
Health checks are for checking if the server is alive so the LB can stop sending traffic to dead servers and only route users to working ones. Yes, we always need health checks in real production because the LB needs to route around failures without them, traffic would keep going to dead servers and users would see errors. A reverse proxy is a server that sits in front of other servers and forwards requests to them — the client doesn't talk to the backend directly. The LB distributes traffic, which means it spreads the load across many backends, and it uses health checks so it knows which backends are eligible to receive the traffic.

What are LB routing rules and URL maps for? Give an example or two of them in use.**
A global LB has one public IP. A real website has multiple parts like a homepage, API server, and storage like Cloud Storage buckets that contain the images. URL maps are the load balancer's routing table a list of the rules. Routing rules are entries in the table that say "if the URL matches X, send to the backend called Y." For example, /api/* would route to the API backend, and /images/* would route to the Cloud Storage bucket.

Explain what an anycast IP address is used for in the context of a global load balancer.
Anycast is one IP address that exists in many places at once. Once you connect to it you get sent to the closest one automatically. Global LBs use it because one IP serves the whole planet, giving every user fast service because they always reach the nearest data center.

Cloud Armor

What does Cloud Armor offer?**
Cloud Armor is Google's Web Application Firewall (WAF) and DDoS protection service. It sits in front of your load balancer and inspects incoming traffic, blocking malicious requests before they reach your backends. The main protections it offers are DDoS defense, WAF rules that block common web attacks like SQL injection and cross-site scripting, and IP-based or geography-based filtering to allow or deny traffic from specific regions.

Why is it used in the first place?**
A regular firewall can't stop attacks like SQL injection. Cloud Armor does, by blocking DDoS attacks, which are floods of traffic, and filtering by IP address or country.

What layer in the OSI model does it operate at? Why is this important and how is this firewall different from VPC firewall rules?
Cloud Armor operates at Layer 7 of the OSI model, which is the application layer. This matters because Layer 7 can read the HTTP request content, while Layer 3/4 only sees IPs and ports. VPC firewall rules work at Layer 3/4, so they can block traffic by IP or port but can't inspect the actual request — Cloud Armor can, which is why it blocks by request content, attack patterns, rates, and geography.

What are rate-based rules for?
Rate-based rules block clients who send too many requests too fast. They're used for DDoS protection and brute-force logins that are sending many requests per minute.

What is reCAPTCHA and how does it relate to this service?
reCAPTCHA makes sure you are not a bot and that you are a human by clicking squares with things like bikes or bridges. Cloud Armor can use reCAPTCHA to challenge any suspicious requests — if a visitor has bot vibes, Cloud Armor will test them for human validation.

Cloud CDN

What are POPs used for?**
POPs are physical Google data centers scattered around the world that store cached copies of your content. Google has hundreds of them, and that's how Cloud CDN delivers content fast — users get served from the nearest POP instead of from your origin server.

What kind of files are served with Cloud CDN?**
Static files like images, videos, CSS, JavaScript, fonts, and HTML. CDN is not good for dynamic content or anything that updates constantly.

What services can be used with Cloud CDN for the source of content (the origin)?**
Cloud CDN can pull content from Cloud Storage buckets, VMs with a backend service on the load balancer, Managed Instance Groups (MIGs) which are groups of virtual machines that auto-scale and self-heal, and external origins which are servers outside of GCP.

Does Cloud CDN help protect against any types of malicious actors or cyberattacks? Explain.**
Cloud CDN helps absorb DDoS traffic by spreading the load across Google's POPs, which makes it harder for attackers to overwhelm your origin. It also hides the origin server, which makes it harder to target. But it's not a full security solution — Cloud Armor handles real web attack protection.

Should an enterprise always use Cloud CDN? Why or why not?**
An enterprise should not always use Cloud CDN. It is good for static content like images, videos, JavaScript, and CSS — especially when users are globally spread out and you have high traffic that benefits from caching. It is not a good fit when your content is dynamic or personalized, when traffic is low, when all your users are in one region (a regional setup is cheaper), or when you need real-time data.

What is TTL and how does it control content "freshness"?**
TTL is Time To Live in seconds. It's a number that says how long a cached copy is valid before CDN has to grab a fresh version from the origin. Short TTL is expensive because it keeps the data freshly cached. Long TTL is fast and cheap but the data might be stale.

Runbook - Global External HTTP Load Balancer with MIG Backend

Goal Spin up a global external HTTP load balancer using a MIG as the backend, include health checks. All steps done via Click Ops in the GCP

This is for Engineers familiar with GCP basics

Prerequisites -GCP project with billing enabled -VPC network and subnet already created ('tko-vpc' with subnet in us-central1') -IAM role that is Compute Admin or Owner -Access to the GCP console

Step 1: Create Instance Template

Console: Compute Engine > Instance templates - Click "Create Instance Template"

Ste: -Name: 'tko-web-template-v1' -Machine type: e2-medium -Boot disk: Debian 12, 10 GB Standard persistent disk

Networking -Network: tko-vpc -Subnet: 'us-central1' -Network tags: 'http-server', 'lb-health-check'

Expland > Advanced options > Management > Automatikno > Startup script: (paste):

#!/bin/bash
apt-get update
apt-get install -y nginx
echo "<h1>Hello from $(hostname)</h1>" > /var/www/html/index.html
systemctl start nginx
systemctl enable nginx
Click "create"
Step 2: Create Managed Instance Group (MIG)

Console: Compute Engine > Instance Groups. Click "create instance group"

Select: New managed instance group

Set: -Name: 'tko-web-mig' -Instance template: 'tko-web-template-v1'

Loacation -Multiple zones -Region: 'us-central1' -Zones: leave default

Autoscaling -Autoscaling mode: On: add and remove instances -Minimum 3 sentences -Maximum 6 sentences -Autscaling signal: CPU utilzation, target 60%

Click "create"

Step 3: Create Firewall Rules

Rule 1 - Allow Health Check Probes

Console: VPC Newtork > Firewall. Click "Create firewall rule"

Basicis -Name: 'tko-allow-health-checks' -Networ: 'tko-vpc' -Direction: Ingress Action on match: Allow

Targets -Targets: Specified target tags -Target tags: 'lb-health-check'

Source: -Source filder: IPv4 ranges -Source IPv4 ranges: '35.191.0.0/16', '130.211.0.0/22'

Protocols and ports -Protocols and ports: Specified protocols and ports -Check 'TCP', port '80'

Click "Create"

Rule 2 - Allow HTTP Traffic

Click 'Create firewall rule' again

Basics -Name: 'tko-allow-http' -Network: 'tko-vpc' -Direction: 'Ingress' -Action on match: 'Allow'

Targets -Targets: Specified target tags -Target tags: 'http-server'

Source: -Source filter: IPv4 ranges -Source IPv4 ranges: '0.0.0.0/0'

Protocols and ports: -Protocols and ports: Specified protocols and ports -Check TCP, port '80'

Click 'Create'

Step 4: Create the Global Load Balancer

4a. Start the LB Wizard

Console: **Network services > Load balancing. Click Create load balancer.

Select Application Load Balancer (HTTP/S). Click Next.

Facing:

Public facing or internal:** Public facing (external)
Global or Regional:** Global
Existing or new LB:** New
Click Configure.

4b. Configure the Frontend

Click Frontend configuration.

Set:

Name: tko-web-frontend
Protocol:HTTP
Network Service Tier:** Premium
IP version:IPv4
IP address: Ephemeral (auto-assign)
Port: 80
Click Done.

4c. Configure the Backend

Click Backend configuration > Backend services & backend buckets > Create a backend service.

Basics:

Name: tko-web-backend-service
Backend type: Instance group
Protocol: HTTP
Named port: http
Timeout: 30 seconds
Under Backends > New backend**:

Instance group:tko-web-mig
Port numbers:80
Balancing mode:Utilization
Maximum backend utilization:80%
Capacity: 100%
Click Done
Under Health check, click Create a health check:

Name: tko-web-healthcheck
Protocol: HTTP
Port:** 80
Request path: /
Check interval:** 10 seconds
Timeout:** 5 seconds
Healthy threshold: 2
Unhealthy threshold: 3
Click Save
Leave Cloud CDN and Cloud Armor unchecked.

Click Create.

4d. Configure Routing Rules

Click Routing rules.

Leave the default routing rule as is — it sends all paths (/*) to tko-web-backend-service.

Click Done.

4e. Review and Create

Click Review and finalize. Confirm all 3 sections show green check marks.

Click Create. Wait 5–10 minutes for the LB to provision.

Copy the IP address shown for the forwarding rule. This is anycast IP.

Step 5: Verify the Load Balancer

Go back to the MIG (tko-web-mig) and confirm the autohealing health check is set to tko-web-healthcheck. Update if not.

Wait at least 5 minutes after LB creation for backends to become healthy.

In a browser, open http://<LB_IP_ADDRESS> (the anycast IP from Step 4e).

Confirm the page loads showing Hello from <vm-hostname>.

Refresh several times. Hostname should change — proves traffic is distributed across MIG instances.

Check backend health: Network services > Load balancing > tko-web-backend-service**. All 3 backends should show 'Healthy'

Step 6: Cleanup (Avoid Billing)

Delete in this order to avoid dependency errors:

Load Balancer: Network services > Load balancing > select the LB > Delete.

Backend Service: Network services > Load balancing > Backend services > delete tko-web-backend-service.

Health Check: Compute Engine > Health checks > delete tko-web-healthcheck.

MIG:** Compute Engine > Instance groups > delete tko-web-mig.

Instance Template: Compute Engine > Instance templates > delete tko-web-template-v1.

Firewall Rules: VPC Network > Firewall > delete tko-allow-health-checks and tko-allow-http.

Confirm in Billing > Reports that no Compute Engine charges are still accruing.

