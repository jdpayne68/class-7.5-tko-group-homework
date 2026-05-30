
---

# README

## Deliverables
This repository includes:
- Documentation and resources used this week, with explanations of how each was used  
- A Q&A section written for a junior cloud engineer  
- A runbook for deploying an external Application Global Load Balancer using ClickOps  
- A Terraform directory containing required infrastructure code  
- Additional configuration for “Be a Man 1” and “Be a Man 2”

---

# Q&A  
*(All answers should be written assuming the reader is a junior engineer with some technical background. Keep explanations clear, grounded, and from first principles.)*

### Load Balancers
- How does load balancing contribute to fault tolerance? What about high availability?  
    a load balancer helps by spreading traffic across multiple backend servers. If one crashes, the Load balancer simply stops sending traffic to it. Fault tolerance means the system keeps working even when something breaks. So if one node fails, the traffic is routed someplace else.  
    High availability means the service stays reachable even during heavy load or regional outages.

- Do global load balancers decrease latency for end users? Why or why not?  
     It decreases latency because of google edge networking. They use anycast ips and route uses to the closest healthy google edge location.

- What are LB health checks for? Do we always need them? Is a LB different from a reverse proxy?  
We need this to monitor the health of servers, vms, backend services. Load balancers are a type of reverse proxy in that it routes traffic, performs health checks, supports rules. Reverse proxy sit between the user and the servers as a layer 7 osi and helps the same way. Even the documentation kind of allude them as very similar, I still have reservations about calling them the same. Something is off here. I need to do more research to settle on an opinion.. I do not think all reverse proxies are Load balancers, though the reverse might be true.

- What are LB routing rules and URL maps for? Provide examples.  
    Routing rules and URL maps tell the load balancer how to decide where traffic should go  
    examples:  
    - api/  -- api backend service  
    - static/ - cloud cdn service  
    - chciago/ = chcicago backend  
    - missouri/ = missouri backend  
    This allows multiple services to live behind one global ip

- Explain what an anycast IP address is used for in the context of a global load balancer.  
   - this is a single IP address advertised from any locations around the world. The google network will automatically route them to the closest location with the anycast ip.

### Cloud Armor
- What does Cloud Armor offer?  
  Cloud Armor is Google’s Web Application Firewall (WAF).

- Why is it used in the first place?  
    public applications are constantly attacked. Cloud armor blocks malicious traffice before it reaches your backend, reducing risk and protecting your infrastructur.

- What OSI layer does it operate at? Why is this important, and how is this firewall different from VPC firewall rules?  
   layer 7 application layer, it undestandds HTTPS traffic, it can block specific urls, headers, patterns, also against attackes like XSS, Bots. Thi is different from VPC firewall rules, which operate at layer3/4. VPC firewalls cannot inspect HTTP content: cloud armor can.

- What are rate‑based rules for?  
Rate‑based rules limit how many requests a client can make in a given time window. it protects against Bots, scrapers, DDos attacks.

- What is reCAPTCHA and how does it relate to this service?  
  this helps distinguish between humans from bots. Cloud armor integrates with reCAPTCHA so you can challenge suspicous traffice before it reaches your app.

### Cloud CDN
- What are POPs used for?  
POPs (Points of Presence) are Google’s global edge locations.

- What kind of files are served with Cloud CDN?  
  images, css, javascript, videos, videos, pdfs, static html

- What services can be used as origins?  
  cloud storage buckes, backend services behind a load balancer, instance groups, cloud run serivces

- Does Cloud CDN help protect against malicious actors or cyberattacks? Explain.  
  Yes but indirectly, they help mitigate DDoS attacks, traffic spikes, bot scraping

- Should an enterprise always use Cloud CDN? Why or why not?  
  It should use it when serving static content, global users, and when you wnat lower latency and lower backend load. Dont use it wen the content is dynamic or serve personallized or dynamic responses, caching is stale or incorrect

- What is TTL and how does it control content freshness?  
  Time to live, It tells the CDN how long to keep cached content before checking the origin again.

---

# Runbook  
*(This section is for engineers executing the task. Keep it high‑level, procedural, and free of unnecessary explanation.)*

## Goal
Deploy a fully configured external Application Global Load Balancer using ClickOps, backed by a Managed Instance Group, including health checks and correct wiring between components.

## Prerequisites
- GCP project with billing enabled  
- Required IAM permissions  
- Instance template prepared  
- Managed Instance Group deployed  
- Firewall rules allowing health check ranges  
- Basic understanding of GCP networking and load balancing components

## Steps
1. Create or verify the Managed Instance Group.  
2. Create a health check appropriate for the application.  
3. Create a backend service and attach the MIG and health check.  
4. Create a URL map and configure routing rules.  
5. Create the global external Application Load Balancer and attach the URL map.  
6. Configure the frontend (HTTP/HTTPS) and assign an external IP.  
7. Review and create the load balancer.  
8. Test the configuration to confirm correct routing and health check behavior.  
9. Document any deviations from class settings and justify them.

---

# Terraform Directory Requirements

## Required Files
- `.gitignore`  
- `main.tf`  
- `variables.tf`  
- `outputs.tf`  
- `vpc.tf`  
- `firewall.tf`  
- `mig.tf`  
- `loadbalancer.tf`  
- Any additional logically separated files

## Critical Requirements
- No state files or lock files committed  
- No provider binaries committed  
- Code must run with `terraform init`, `terraform validate`, and `terraform apply`  
- All code written by the student or group  
- Follow Terraform best practices and style guide  
- Use latest provider version  
- Include informative outputs  
- Use comments to make the code self‑documenting  
- Explain any non‑obvious values or arguments  
- No unnecessary resources

## Configuration Requirements
- Custom VPC  
- Firewall rules using target tags  
- Managed Instance Group with class‑consistent settings  
- External global load balancer (Be a Man 1)  
- Two backend services with path‑based routing (Be a Man 2)  
- Optional Cloud CDN configuration with notes

---

