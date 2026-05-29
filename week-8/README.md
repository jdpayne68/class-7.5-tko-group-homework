## High Availability and Fault Tolerance

### High Availability

High availability is about reducing downtime when a zone or instance becomes unavailable (for example, a zonal outage or hardware issue). It uses data redundancy and automated failover to minimize downtime, but does not completely prevent disruptions to users. High availability accepts a tolerated level of downtime.

The concept of availability can be seen in cloud provider Service Level Agreements (SLAs). For example, Google claims 99.999% availability (maximum 26 seconds downtime per month) for a Bigtable instance with clusters in three or more regions and multi-cluster routing configured. If only a single-cluster routing policy is configured, availability drops to 99.9% (43.2 minutes per month).

### Fault Tolerance

Fault tolerance is about continued operation during failure. It uses redundant resources and data replication to eliminate single points of failure. Typically implemented through active-active architectures, so services continue operating even when part of the system fails.

### Important Differences

High availability accepts some level of downtime during failures and failover. It is more cost-effective and practical for most applications. Fault tolerance aims for uninterrupted service but requires duplicating resources and replicating data. It is more complex and costly, but appropriate for mission-critical operations.

### Documentation

- [Design Reliable Infrastructure for Your Workloads in Google Cloud](https://docs.cloud.google.com/architecture/infra-reliability-guide/design)
- [About High Availability](https://docs.cloud.google.com/sql/docs/mysql/high-availability)
- [Disk Replication](https://docs.cloud.google.com/compute/docs/disks/about-regional-persistent-disk)
- [Building Blocks of Reliability in Google Cloud](https://docs.cloud.google.com/architecture/infra-reliability-guide/building-blocks)

---

## Autoscaling and Elasticity

### Autoscaling

Autoscaling is a mechanism that implements elasticity by automatically adjusting resources based on metrics, schedules, or policies.

- **Vertical scaling (up/down)** increases or decreases the capacity of an individual resource. It is the equivalent of upgrading or downgrading CPU, memory, storage, or GPUs on a computer.
- **Horizontal scaling (out/in)** adds or removes instances with the same configuration to distribute workloads across multiple resources. It improves scalability, availability, and fault tolerance.

### Elasticity

Elasticity is the ability of a system to automatically expand and contract resources in response to changes in demand. Like a rubber band, resources expand or shrink as demand increases or decreases.

### Important Differences

Vertical scaling is more appropriate for databases, monolithic applications, or workloads that cannot be easily distributed across multiple instances. Horizontal scaling is preferred in cloud environments because it improves scalability, availability, resilience, and cost efficiency by distributing workloads across multiple instances.

### Documentation

- [Architecture for Reliable Scalability](https://aws.amazon.com/blogs/architecture/architecting-for-reliable-scalability/)
- [What is Cloud Scalability](https://cloud.google.com/discover/what-is-cloud-scalability?hl=en#what-is-cloud-scalability)
- [Auto Scaling Benefits for Applications Architecture](https://docs.aws.amazon.com/autoscaling/ec2/userguide/auto-scaling-benefits.html)

---

## Managed and Unmanaged Instance Groups

### Managed Instance Group

Managed instance groups are a homogeneous group of VM instances managed as a single unit. They use an instance template and support autoscaling, autohealing, rolling updates, and maintaining a desired number of instances.

### Unmanaged Instance Group

Unmanaged instance groups are a heterogeneous group of VM instances grouped together for operational purposes but managed individually. They do not use instance templates and do not support autoscaling, autohealing, or automated rolling updates.

### Important Differences

Managed instance groups are best for modern cloud applications because they are highly elastic, scale automatically, and provide high availability. Unmanaged instance groups are best for mixed workloads that require different instance configurations.

### Documentation

- [Instance Groups](https://docs.cloud.google.com/compute/docs/instance-groups)

---

## Health Checks

### Health Checks: Applications (in instance groups)

Application-based health checks probe instances in a managed instance group to verify that an application responds as expected. If an application is not responding, the MIG automatically recreates the VM.

### Health Checks: Load Balancers

Load balancer health checks determine which backend instances should receive traffic. If an instance fails the health check, the load balancer stops sending traffic to it until it becomes healthy again.

### Important Distinctions

Both health checks can use the same endpoint, for example, `/healthz`. Application-based health checks repair or replace VMs; load balancer health checks determine which instances should receive traffic.

### Documentation

- [Health Checks Overview](https://docs.cloud.google.com/load-balancing/docs/health-check-concepts)
- [Set Up an Application-Based Health Check and Autohealing](https://docs.cloud.google.com/compute/docs/instance-groups/autohealing-instances-in-migs)
- [Managed Instance Groups - Autohealing](https://docs.cloud.google.com/compute/docs/instance-groups#autohealing)
- [Use Health Checks (for Load Balancers)](https://docs.cloud.google.com/load-balancing/docs/health-checks)
- [Health Checks for Application Load Balancer Target Groups](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/target-group-health-checks.html)
- [Health Checks for Instances in an Auto Scaling Group](https://docs.aws.amazon.com/autoscaling/ec2/userguide/ec2-auto-scaling-health-checks.html)

---

## Three Tier Architecture

### Three Tier Architecture

Three-tier architecture decouples an application into three tiers: presentation, application, and data. This design improves scalability, security, and flexibility because each tier isolates responsibilities and can scale independently.

### Presentation Tier (Frontend)

The presentation tier determines how users interact with the application. It displays content and handles user input.

Examples:

- Load balancers
- Web servers
- Content delivery networks
- Frontend applications built with HTML, CSS, and JavaScript

### Application Tier (Business Logic)

The application tier processes user input and performs operations in the application. It contains the core business logic of the application.

Examples:

- VMs
- Containers
- API Gateways
- Cloud Functions / Lambda

### Data Tier (Storage)

The data tier stores, retrieves, and manages application data. The application tier communicates with the data tier to access and manipulate data.

Examples:

- Relational databases (RDS, MySQL, PostgreSQL)
- NoSQL databases (MongoDB, Cassandra, Redis)
- Redis caching
- Object storage services (Amazon S3, Google Cloud Storage, Azure Blob Storage)

### Documentation

- [An Overview of Traditional Web Hosting](https://docs.aws.amazon.com/whitepapers/latest/web-application-hosting-best-practices/an-overview-of-traditional-web-hosting.html)
- [Key Components of an AWS Web Hosting Architecture](https://docs.aws.amazon.com/whitepapers/latest/web-application-hosting-best-practices/key-components-of-an-aws-web-hosting-architecture.html)
- [Build a Modern Three-Tier Architecture Web Application with Cloud Run](https://developers.google.com/learn/pathways/solution-three-tier-cloud-run)
- [Building a Three-Tier Architecture on a Budget](https://aws.amazon.com/blogs/architecture/building-a-three-tier-architecture-on-a-budget/)