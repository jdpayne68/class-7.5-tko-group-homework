# SEIR-1 Week 9 Homework

**Student:** Kamau
**Group:** TKO Group (led by Jacques)
**Week:** 9 — Cloud NAT, Global Load Balancing, Cloud CDN, Cloud Armor
**Assigned:** Fri 5/8/26 | **Due:** Thu 5/14/26
**Last updated:** May 15, 2026

---

## Progress

- [x] Load Balancers Q&A (5/5)
- [x] Cloud Armor Q&A (5/5)
- [x] Cloud CDN Q&A (6/6)
- [x] Runbook — global LB + MIG via ClickOps

---

## Q & A

### Load Balancers

**1. How does load balancing contribute to fault tolerance? What about high availability?**

Load balancing helps with fault tolerance because the LB uses health checks to see which backend servers are working. When a server fails the health check, the LB stops sending traffic to it and shifts that traffic to healthy servers, which keeps the application running. It also helps with high availability because the LB can spread traffic across multiple backends in different zones or regions, so even if one zone goes down, users still get served.

**2. Do global load balancers decrease latency for end users? Why or why not?**

Yes, global LBs decrease latency. The global LB uses anycast — a single IP advertised from many of Google's data centers around the world — so a user gets routed to the closest data center automatically. It's like traveling to a nearby city instead of having to travel to another state: the closer the data center, the faster the connection.

**3. What are LB health checks for? Do we always need them? Is a LB different from a reverse proxy?**

Health checks are for checking if the server is alive so the LB can stop sending traffic to dead servers and only route users to working ones. Yes, we always need health checks in real production because the LB needs to route around failures — without them, traffic would keep going to dead servers and users would see errors. A reverse proxy is a server that sits in front of other servers and forwards requests to them — the client doesn't talk to the backend directly. The LB distributes traffic, which means it spreads the load across many backends, and it uses health checks so it knows which backends are eligible to receive the traffic.

**4. What are LB routing rules and URL maps for? Give an example or two of them in use.**

A global LB has one public IP. A real website has multiple parts like a homepage, API server, and storage like Cloud Storage buckets that contain the images. URL maps are the load balancer's routing table — a list of the rules. Routing rules are entries in the table that say "if the URL matches X, send to the backend called Y." For example, `/api/*` would route to the API backend, and `/images/*` would route to the Cloud Storage bucket.

**5. Explain what an anycast IP address is used for in the context of a global load balancer.**

Anycast is one IP address that exists in many places at once. Once you connect to it you get sent to the closest one automatically. Global LBs use it because one IP serves the whole planet, giving every user fast service because they always reach the nearest data center.

---

### Cloud Armor

**1. What does Cloud Armor offer?**

Cloud Armor is Google's Web Application Firewall (WAF) and DDoS protection service. It sits in front of your load balancer and inspects incoming traffic, blocking malicious requests before they reach your backends. The main protections it offers are DDoS defense, WAF rules that block common web attacks like SQL injection and cross-site scripting, and IP-based or geography-based filtering to allow or deny traffic from specific regions.

**2. Why is it used in the first place?**

A regular firewall can't stop attacks like SQL injection. Cloud Armor does, by blocking DDoS attacks, which are floods of traffic, and filtering by IP address or country.

**3. What layer in the OSI model does it operate at? Why is this important and how is this firewall different from VPC firewall rules?**

Cloud Armor operates at Layer 7 of the OSI model, which is the application layer. This matters because Layer 7 can read the HTTP request content, while Layer 3/4 only sees IPs and ports. VPC firewall rules work at Layer 3/4, so they can block traffic by IP or port but can't inspect the actual request — Cloud Armor can, which is why it blocks by request content, attack patterns, rates, and geography.

**4. What are rate-based rules for?**

Rate-based rules block clients who send too many requests too fast. They're used for DDoS protection and brute-force logins that are sending many requests per minute.

**5. What is reCAPTCHA and how does it relate to this service?**

reCAPTCHA makes sure you are not a bot and that you are a human by clicking squares with things like bikes or bridges. Cloud Armor can use reCAPTCHA to challenge any suspicious requests — if a visitor has bot vibes, Cloud Armor will test them for human validation.

---

### Cloud CDN

**1. What are POPs used for?**

POPs are physical Google data centers scattered around the world that store cached copies of your content. Google has hundreds of them, and that's how Cloud CDN delivers content fast — users get served from the nearest POP instead of from your origin server.

**2. What kind of files are served with Cloud CDN?**

Static files like images, videos, CSS, JavaScript, fonts, and HTML. CDN is not good for dynamic content or anything that updates constantly.

**3. What services can be used with Cloud CDN for the source of content (the origin)?**

Cloud CDN can pull content from Cloud Storage buckets, VMs with a backend service on the load balancer, Managed Instance Groups (MIGs) which are groups of virtual machines that auto-scale and self-heal, and external origins which are servers outside of GCP.

**4. Does Cloud CDN help protect against any types of malicious actors or cyberattacks? Explain.**

Cloud CDN helps absorb DDoS traffic by spreading the load across Google's POPs, which makes it harder for attackers to overwhelm your origin. It also hides the origin server, which makes it harder to target. But it's not a full security solution — Cloud Armor handles real web attack protection.

**5. Should an enterprise always use Cloud CDN? Why or why not?**

An enterprise should not always use Cloud CDN. It is good for static content like images, videos, JavaScript, and CSS — especially when users are globally spread out and you have high traffic that benefits from caching. It is not a good fit when your content is dynamic or personalized, when traffic is low, when all your users are in one region (a regional setup is cheaper), or when you need real-time data.

**6. What is TTL and how does it control content "freshness"?**

TTL is Time To Live in seconds. It's a number that says how long a cached copy is valid before CDN has to grab a fresh version from the origin. Short TTL is expensive because it keeps the data freshly cached. Long TTL is fast and cheap but the data might be stale.

---

## Runbook — Global External HTTP Load Balancer with MIG Backend (ClickOps)

**Goal:** Spin up a fully configured external application global load balancer using a Managed Instance Group (MIG) as the backend, with health checks. All steps performed via the GCP Console (no Terraform).

**Audience:** Engineers familiar with GCP basics (project, VPC, IAM).

---

### Prerequisites

Before running this runbook, ensure:

- A GCP project with billing enabled
- A VPC network and subnet already created (e.g., `tko-vpc` with a subnet in `us-central1`)
- IAM role of at least Compute Admin or Owner on the project
- Access to the GCP Console

---

### Step 1: Create Instance Template

1. Open GCP Console. Navigate to **Compute Engine > Instance templates**. Click **Create instance template**.

2. Set the basics:
   - **Name:** `tko-web-template-v1`
   - **Machine type:** `e2-medium`
   - **Boot disk:** Debian 12, 10 GB Standard persistent disk

3. Set networking:
   - **Network:** `tko-vpc`
   - **Subnet:** subnet in `us-central1`
   - **Network tags:** `http-server`, `lb-health-check`

4. Expand **Advanced options > Management > Automation > Startup script**. Paste:

   ```bash
   #!/bin/bash
   apt-get update
   apt-get install -y nginx
   echo "<h1>Hello from $(hostname)</h1>" > /var/www/html/index.html
   systemctl start nginx
   systemctl enable nginx
   ```

5. Click **Create**.

---

### Step 2: Create Managed Instance Group (MIG)

1. Navigate to **Compute Engine > Instance groups**. Click **Create instance group**.

2. Select **New managed instance group**.

3. Set the basics:
   - **Name:** `tko-web-mig`
   - **Instance template:** `tko-web-template-v1`

4. Set location:
   - **Location:** Multiple zones
   - **Region:** `us-central1`
   - **Zones:** leave default

5. Set autoscaling:
   - **Autoscaling mode:** On: add and remove instances
   - **Minimum instances:** 3
   - **Maximum instances:** 6
   - **Autoscaling signal:** CPU utilization, target 60%

6. Set port mapping (required so the LB knows where to send traffic):
   - **Port name:** `http`
   - **Port number:** `80`

7. Set autohealing:
   - **Health check:** `tko-web-healthcheck` (created in Step 4 if it does not exist)
   - **Initial delay:** 60 seconds

8. Click **Create**.

---

### Step 3: Create Firewall Rules

#### Rule 1 — Allow Health Check Probes

1. Navigate to **VPC Network > Firewall**. Click **Create firewall rule**.

2. Set the basics:
   - **Name:** `tko-allow-health-checks`
   - **Network:** `tko-vpc`
   - **Direction:** Ingress
   - **Action on match:** Allow

3. Set targets:
   - **Targets:** Specified target tags
   - **Target tags:** `lb-health-check`

4. Set source:
   - **Source filter:** IPv4 ranges
   - **Source IPv4 ranges:** `35.191.0.0/16`, `130.211.0.0/22`

5. Set protocols and ports:
   - **Protocols and ports:** Specified protocols and ports
   - Check **TCP** and enter port `80`

6. Click **Create**.

#### Rule 2 — Allow HTTP Traffic

1. Click **Create firewall rule** again.

2. Set the basics:
   - **Name:** `tko-allow-http`
   - **Network:** `tko-vpc`
   - **Direction:** Ingress
   - **Action on match:** Allow

3. Set targets:
   - **Targets:** Specified target tags
   - **Target tags:** `http-server`

4. Set source:
   - **Source filter:** IPv4 ranges
   - **Source IPv4 ranges:** `0.0.0.0/0`

5. Set protocols and ports:
   - **Protocols and ports:** Specified protocols and ports
   - Check **TCP** and enter port `80`

6. Click **Create**.

---

### Step 4: Create the Global Load Balancer

#### 4a. Start the LB Wizard

1. Navigate to **Network services > Load balancing**. Click **Create load balancer**.

2. Select **Application Load Balancer (HTTP/S)**. Click **Next**.

3. Set facing:
   - **Public facing or internal:** Public facing (external)
   - **Global or Regional:** Global
   - **Existing or new LB:** New

4. Click **Configure**.

#### 4b. Configure the Frontend

1. Click **Frontend configuration**.

2. Set:
   - **Name:** `tko-web-frontend`
   - **Protocol:** HTTP
   - **Network Service Tier:** Premium
   - **IP version:** IPv4
   - **IP address:** Ephemeral (auto-assign)
   - **Port:** `80`

3. Click **Done**.

#### 4c. Configure the Backend

1. Click **Backend configuration > Backend services & backend buckets > Create a backend service**.

2. Set the basics:
   - **Name:** `tko-web-backend-service`
   - **Backend type:** Instance group
   - **Protocol:** HTTP
   - **Named port:** `http`
   - **Timeout:** 30 seconds

3. Under **Backends > New backend**:
   - **Instance group:** `tko-web-mig`
   - **Port numbers:** `80`
   - **Balancing mode:** Utilization
   - **Maximum backend utilization:** 80%
   - **Capacity:** 100%
   - Click **Done**

4. Under **Health check**, click **Create a health check**:
   - **Name:** `tko-web-healthcheck`
   - **Protocol:** HTTP
   - **Port:** `80`
   - **Request path:** `/`
   - **Check interval:** 10 seconds
   - **Timeout:** 5 seconds
   - **Healthy threshold:** 2
   - **Unhealthy threshold:** 3
   - Click **Save**

5. Leave Cloud CDN and Cloud Armor unchecked for now.

6. Click **Create**.

#### 4d. Configure Routing Rules

1. Click **Routing rules**.

2. Leave the default routing rule as is — it sends all paths (`/*`) to `tko-web-backend-service`.

3. Click **Done**.

#### 4e. Review and Create

1. Click **Review and finalize**. Confirm all 3 sections show green check marks.

2. Click **Create**. Wait 5–10 minutes for the LB to provision.

3. Once created, copy the **IP address** shown for the forwarding rule. This is your anycast IP.

---

### Step 5: Verify the Load Balancer

1. Go back to the MIG (`tko-web-mig`) and confirm the autohealing health check is set to `tko-web-healthcheck`. Update if not.

2. Wait at least 5 minutes after LB creation for backends to become healthy.

3. In a browser, open `http://<LB_IP_ADDRESS>` (the anycast IP from Step 4e).

4. Confirm the page loads showing `Hello from <vm-hostname>`.

5. Refresh the page several times. Confirm the hostname changes — this proves traffic is being distributed across MIG instances.

6. Check backend health in the Console:
   - Navigate to **Network services > Load balancing > tko-web-backend-service**.
   - Confirm all 3 backends show **Healthy** status.

---

### Step 6: Cleanup (Avoid Billing)

Delete in this order to avoid dependency errors:

1. **Load Balancer:** Network services > Load balancing > select the LB > Delete.

2. **Backend Service:** Network services > Load balancing > Backend services > delete `tko-web-backend-service`.

3. **Health Check:** Compute Engine > Health checks > delete `tko-web-healthcheck`.

4. **MIG:** Compute Engine > Instance groups > delete `tko-web-mig`.

5. **Instance Template:** Compute Engine > Instance templates > delete `tko-web-template-v1`.

6. **Firewall Rules:** VPC Network > Firewall > delete `tko-allow-health-checks` and `tko-allow-http`.

7. Confirm in **Billing > Reports** that no Compute Engine charges are still accruing.

---

### Key Setting Explanations

- **Network Service Tier: Premium** — Required for a global LB. Standard tier only supports regional LBs.
- **Balancing mode: Utilization** — The LB distributes traffic based on CPU utilization of backend VMs. The other option (Rate) distributes based on requests per second.
- **Health check thresholds (2 healthy, 3 unhealthy)** — A VM must succeed 2 checks in a row to be marked healthy, and fail 3 in a row to be marked unhealthy. Prevents flapping from one-off failures.
- **Source ranges `35.191.0.0/16` and `130.211.0.0/22`** — These are Google's published health check probe ranges. Required for the LB to reach backends.
- **Ephemeral IP** — Auto-assigned and lost if the LB is deleted. For production, reserve a static IP instead.

---

## Documentation & Resources Used

- Cloud NAT: https://docs.cloud.google.com/nat/docs/private-nat
- Global LB: https://docs.cloud.google.com/load-balancing/docs/https/setup-global-ext-https-compute
- Cloud CDN: https://cloud.google.com/cdn
- Cloud Armor: https://cloud.google.com/security/products/armor
- Health check IP ranges: https://cloud.google.com/load-balancing/docs/health-check-concepts

---

*Note: All Q&A answers and runbook content written by Kamau in his own words, with Claude used only for teaching concepts and clarifying questions, not for generating answers.*
