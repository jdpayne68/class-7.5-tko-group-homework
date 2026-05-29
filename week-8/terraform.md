# Dependency is implicit in the "router"" argument (references google_compute_router.router.name)


HAD TO AD roles/compute.networkAdmin to terraform service account
this allows to reserve static external IP
https://docs.cloud.google.com/vpc/docs/reserve-static-external-ip-address

Configure static external IP address
https://docs.cloud.google.com/compute/docs/ip-addresses/configure-static-external-ip-address#terraform_1

List Images
https://docs.cloud.google.com/sdk/gcloud/reference/compute/images/list

Machine types


LEARN REGEX



# Helpful, but not needed when the required API has already been enabled.


- In a subdirectory called “terraform”
- A .gitignore file (ask group leader if unsure)

## Critical requirements

- No state file can be committed to your repo
- No provider binaries (.terraform dir) if you somehow figure out Git LFS
- Your code must be able to be cloned and ran (terraform init, validate, apply) as is
- Submission is not acceptable without meeting these

## A terraform config conforming to best practices

This includes:

- Terraform {} code block
  - Ideally this has versioning requirements for the terraform binary of at least 1.10

- Provider {} code block
  - Latest provider version

- Comments where needed to make config self-documenting

- Follow style guide for naming conventions

- Idiomatic formatting (hint: there is a command for this)

- Files separated in a logical manner and numbered

- Resources must logically build on each other

- No unneeded explicit dependencies

## The Terraform config must provision a VM

- Must have an external IP
- Must use the “centOS stream 10” OS image
- The root persistent disk must be 100 GB
- Must be a machine type in the N series (you choose!)

## Startup script

For the startup script use the following script.

Put the script in the startup script argument however you like.

Startup scripts Theo has provided will not work because CentOS is a flavor of RHEL so some commands are slightly different.

Feel free to look at the script, I added some simple comments to understand it.

Command to get script:

```bash
curl -o startup.sh https://raw.githubusercontent.com/aaron-dm-mcdonald/class7.5-notes/refs/heads/main/week-8/hw/startup-for-rhel.sh
````

Put it in the default vpc (or do the BAM, see below)) and use this argument too:

```hcl
tags = ["http-server"]
```

or port 80 will not open or you make a separate firewall rule (either is fine). The former option is easiest.

* Do not include unneeded arguments

## The terraform config must include output

* for the internal and external IP addresses of the VM
* For the name, id and self_link attributes


## Be a man 1:

- Expand the the existing VM
- Write terraform config for your own VPC, subnet and firewall
- Write the output for both IP addresses using only one output code block and explain what it is and how you did this
- Remove the tags = [“http-server”] argument value but keep the “tags = [ ]” argument and add a tag to your custom firewall rule

## Be a man 2:

- Expand BAM1 but write a VM template resource and use it to provision the VM all with terraform
- Document how you solved this carefully