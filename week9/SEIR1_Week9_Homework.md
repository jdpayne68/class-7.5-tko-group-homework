# SEIR-1 Week 9 Homework

Week: 9: Cloud NAT, Global Load Balancing, Cloud CDN, Cloud Armor  

## Progress

Load Balancers Q&A (5/5)  
Cloud Armor Q&A (5/5)  
Cloud CDN Q&A (6/6)  
Runbook: global LB + MIG via ClickOps

## Q & A

## Load Balancers

### 1. How does load balancing contribute to fault tolerance? What about high availability?

Load balancing helps with fault tolerance because the LB uses health checks to see which backend servers are working. When a server fails the health check, the LB stops sending traffic to it and shifts that traffic to healthy servers, which keeps the application running. It also helps with high availability because the LB can spread traffic across multiple backends in different zones or regions, so even if one zone goes down, users still get served.

### 2. Do global load balancers decrease latency for end users? Why or why not?

Yes, global LBs decrease latency. The global LB uses anycast, which is a single IP advertised from many of Google's data centers around the world, so a user gets routed to the closest data center automatically. It's like traveling to a nearby city instead of having to travel to another state: the closer the data center, the faster the connection.

### 3. What are LB health checks for? Do we always need them? Is a LB different from a reverse proxy?

Health checks are for checking if the server is alive so the LB can stop sending traffic to dead servers and only route users to working ones. Yes, we always need health checks in real production because the LB needs to route around failures. Without them, traffic would keep going to dead servers and users would see errors. A reverse proxy is a server that sits in front of other servers and forwards requests to them. The client doesn't talk to the backend directly. The LB distributes traffic, which means it spreads the load across many backends, and it uses health checks so it knows which backends are eligible to receive the traffic.

### 4. What are LB routing rules and URL maps for? Give an example or two of them in use.

A global LB has one public IP. A real website has multiple parts like a homepage, API server, and storage like Cloud Storage buckets that contain the images. URL maps are the load balancer's routing table, a list of the rules. Routing rules are entries in the table that say "if the URL matches X, send to the backend called Y." For example, `/api/*` would route to the API backend, and `/images/*` would route to the Cloud Storage bucket.

### 5. Explain what an anycast IP address is used for in the context of a global load balancer.

Anycast is one IP address that exists in many places at once. Once you connect to it, you get sent to the closest one automatically. Global LBs use it because one IP serves the whole planet, giving every user fast service because they always reach the nearest data center.

## Cloud Armor

### 1. What does Cloud Armor offer?

Cloud Armor is Google's Web Application Firewall (WAF) and DDoS protection service. It sits in front of your load balancer and inspects incoming traffic, blocking malicious requests before they reach your backends. The main protections it offers are DDoS defense, WAF rules that block common web attacks like SQL injection and cross site scripting, and IP based or geography based filtering to allow or deny traffic from specific regions.

### 2. Why is it used in the first place?

A regular firewall can't stop attacks like SQL injection. Cloud Armor does, by blocking DDoS attacks, which are floods of traffic, and filtering by IP address or country.

### 3. What layer in the OSI model does it operate at? Why is this important and how is this firewall different from VPC firewall rules?

Cloud Armor operates at Layer 7 of the OSI model, which is the application layer. This matters because Layer 7 can read the HTTP request content, while Layer 3/4 only sees IPs and ports. VPC firewall rules work at Layer 3/4, so they can block traffic by IP or port but can't inspect the actual request. Cloud Armor can, which is why it blocks by request content, attack patterns, rates, and geography.

### 4. What are rate based rules for?

Rate based rules block clients who send too many requests too fast. They're used for DDoS protection and brute force logins that are sending many requests per minute.

### 5. What is reCAPTCHA and how does it relate to this service?

reCAPTCHA makes sure you are not a bot and that you are a human by clicking squares with things like bikes or bridges. Cloud Armor can use reCAPTCHA to challenge any suspicious requests. If a visitor has bot vibes, Cloud Armor will test them for human validation.

## Cloud CDN

### 1. What are POPs used for?

POPs are physical Google data centers scattered around the world that store cached copies of your content. Google has hundreds of them, and that's how Cloud CDN delivers content fast. Users get served from the nearest POP instead of from your origin server.

### 2. What kind of files are served with Cloud CDN?

Static files like images, videos, CSS, JavaScript, fonts, and HTML. CDN is not good for dynamic content or anything that updates constantly.

### 3. What services can be used with Cloud CDN for the source of content, also called the origin?

Cloud CDN can pull content from Cloud Storage buckets, VMs with a backend service on the load balancer, Managed Instance Groups (MIGs) which are groups of virtual machines that autoscale and self heal, and external origins which are servers outside of GCP.

### 4. Does Cloud CDN help protect against any types of malicious actors or cyberattacks? Explain.

Cloud CDN helps absorb DDoS traffic by spreading the load across Google's POPs, which makes it harder for attackers to overwhelm your origin. It also hides the origin server, which makes it harder to target. But it's not a full security solution. Cloud Armor handles real web attack protection.

### 5. Should an enterprise always use Cloud CDN? Why or why not?

An enterprise should not always use Cloud CDN. It is good for static content like images, videos, JavaScript, and CSS, especially when users are globally spread out and you have high traffic that benefits from caching. It is not a good fit when your content is dynamic or personalized, when traffic is 
