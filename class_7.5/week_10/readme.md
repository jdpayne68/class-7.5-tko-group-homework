
---

# README

## Deliverables

### Standard Guidelines
- Use your normal HW GitHub repo to submit this.  
- Include all documentation and resources you used, **and how you used them**, and be specific.  
- Add a README of some kind for this week.  

### Individual Work
For all questions and documentation assume I am a junior employee new to cloud infrastructure. Assume I have some technical knowledge but you will be covering these concepts from the ground up. No need to be highly technical in these answers. I want to see that you understand and how well you can explain the topics of discussion, not how well you can copy/paste from the internet.

In a section called **“Q&A”**, answer the following:

---

# Q&A

## DNS and SSL/TLS

- **Explain what the traceroute and dig commands do. Compare and contrast.**  
   traceroutes shows the path your traffic etakes accross the internet
   dig is a DNS lookup tool
   you use dig whhen a domain isnt resolving or you want to inspect the dns
   You use traceroute when the traffic is slow, blocked, or routing incorrectly

- **What are the 3 or 4 most common DNS records and what are their use cases?**  
    A record maps domain to IP4 addesses
    AAAA record maps a domain to ipv6 addresses
    CName record points one domain to another
    mx record tells the itnernet where to deliver email for a domain
- **Give an overview of the steps in a TLS handshake.**  
    client hello when the browser says i want connect securely. and it gives the encryption methods
    server hello and certificate: server send back the chosen encryptionmethod and itss SSL/TLS cert
    cert validation: the browser checks it the cert is valid, it is signed by a trusted cert authority
    key exchange: the client and server securely agree on a shared session key
    encrypted comm begins: all further traffic is encrypted using the session key
- **How does an SSL/TLS cert know what domain it belongs to?**  
   
- **What is a certificate authority?**

## Load Balancers

- **How do application load balancers in GCP offload (decrypt) SSL? What part of the load balancer does this?**  
- **Are there use cases to have in‑flight encryption from the backend service to the backend itself?**

## Cloud Domain/DNS

- **Can multiple domains end up pointing to the same LB?**  
- **In the context of Cloud DNS, what are zones?**

---

# Runbook (Group Work)

In a section called **“runbook”**:

- You write your own runbook, test it with a partner, but work on it as a group of any size or your entire group. Ask your group leader for input.  
- Use the typical runbook format.

### Background
A drunk cloud engineer tried to update some settings. They broke several things. The VM now is not accessible as a web server on the public internet and SSH does not work.

### Goal
Troubleshoot and repair a VM that does not work correctly. Create a runbook so in the future when engineers are drunk it is easier to troubleshoot. Document all methods used even if they did not find the current issue as they may be helpful in the future.

### Additional Requirements
- Write a support ticket documenting:
  - What was happening when you first observed the VM  
  - What you expected it to do  
  - What the root cause was  
  - A reference to your newly created documentation (the “anti‑drunk engineer runbook”)  
- Ensure you document every step and method you use.  
- Don’t look at the script. Let it create the environment and simply start investigating and documenting.  
- Any troubleshooting methods that are valuable should be documented.

### Script to Create the Broken Environment
```
curl -s https://storage.googleapis.com/static-site-bucket-522479235074/broken-env-with-prechecks-v2.sh | bash
```

You will need gcloud properly configured; bash/git bash available (shouldn’t be an issue for anyone unless you’re using a less common Linux distro) OR simply use the GCP Cloud Shell.

The script now has preflight checks to ensure you have gcloud setup and don’t have the environment provisioned already.

Test it by having a group mate (or multiple) use this runbook to accomplish the goal after they create the environment on their own GCP account.

---

# Terraform Requirements

In a subdirectory called **“terraform”**, create the following:

### Requirements
- Follow normal practices (gitignore, Terraform best practices, etc)  
- Use settings from class  
- Create a VPC, firewall rules, VM template, health check, and MIG  
- Ideally create the Global Application LB too (HTTP only)  
- Use variables (only when appropriate) and use locals  
- Use a tfvars file  
- Use outputs  
- **Don’t use AI. AI = automatic failure**

---
