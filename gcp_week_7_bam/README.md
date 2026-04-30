# Week 7 Lab: Automated Static Website Deployment on Google Cloud Storage

![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Google Cloud](https://img.shields.io/badge/Cloud-Google%20Cloud-4285F4?style=for-the-badge&logo=googlecloud&logoColor=white)
![GCS](https://img.shields.io/badge/Storage-GCS%20Bucket-34A853?style=for-the-badge&logo=googlecloudstorage&logoColor=white)
![Static Website](https://img.shields.io/badge/Website-Static%20Hosting-FBBC04?style=for-the-badge&logo=html5&logoColor=black)
![Status](https://img.shields.io/badge/Lab-POC%20Complete-0E8A16?style=for-the-badge)

---

## 1.Week 7 BaM

This lab is to deploy a proof-of-concept static website using **Google Cloud Storage (GCS)** and **Terraform**. The goal is to upload static website assets, making all the content public, and providing a URL to access the content.

The static website includes:

- `index.html`
- `error.html`
- A CSS stylesheet
- One custom image asset

The completed lab demonstrates how infrastructure-as-code can provision cloud storage resources, configure public object access, and host static content without manually creating resources in the Google Cloud Console.

---

## 2. Custom Badges

The project badges above show the major tools and services used in this lab:

| Badge | Meaning |
|---|---|
| Terraform | Infrastructure was written and deployed using Terraform. |
| Google Cloud | Resources were provisioned in Google Cloud Platform. |
| GCS Bucket | Static website files were stored in Google Cloud Storage. |
| Static Website | The bucket was configured to serve static web files. |
| Lab Status | Indicates the proof-of-concept lab was completed successfully. |

---

## 3. Lab / Task / Project Overview

This project automates a static website deployment on GCP using Terraform. Instead of manually creating a storage bucket and uploading files through the Google Cloud Console, Terraform is used to:

1. Create a Google Cloud Storage bucket.
2. Enable static website configuration on the bucket.
3. Upload the provided HTML and CSS files.
4. Upload a custom image file.
5. Make the bucket objects publicly readable.
6. Output a usable URL for viewing the deployed `index.html` page.

This lab is different from AWS S3 static website hosting because GCS does not provide the same type of dedicated static website endpoint. Instead, the public object URL is used to access the hosted files.

---

## 4. Lab / Task / Project Requirements

The following tools, accounts, and files are needed to complete this lab.

| Requirement | Needed? | Purpose |
|---|---:|---|
| Terraform | Yes | Used to provision the bucket, IAM access, website settings, and uploaded objects. |
| GCP Console | Yes | Used to verify resources, bucket settings, uploaded objects, and public access. |
| Git | Recommended | Used for version control and repository management. |
| VS Code | Recommended | Used as the development environment. |
| HTML/CSS Assets | Yes | Static website files uploaded to the GCS bucket. |
| Custom Image | Yes | Image asset referenced by the HTML page. |


---

## 5. Project / Folder Structure

Example project structure:

```text
GCP_Week_7_BaM/
├── 01-provider.tf
├── 02-backend.tf
├── 03-main.tf
├── 04-outputs.tf

├── 404.html
├── index.html 
├── mines.png
├── style.css
 
├── screenshots
    ├── 01-vscode_folder.png
    ├── 02-download_assest.png
    ├── 03-backend.png
    ├── 04-terraform_init.png
    ├── 05-terraform_validate.png
    ├── 06-terraform_plan.png
    ├── 07-terraform_apply.png
    ├── 08-bucket_created.png
    ├── 09-bucket_object.png
    ├── 010-website.png
    ├── 011-curl_test.png
    ├── 012-classmate_access.png
    ├── 013-terraform_destroy.png

├── .gitignore 
├── README.md
```

Recommended Terraform file responsibilities:

| File | Purpose |
|---|---|
| `provider.tf` | Configures the Google provider. |
| `backend.tf` | Configures Terraform state storage for using a remote backend. |
| `main.tf` | Created the GCS bucket, objects, IAM access. |
| `.gitignore` | instructs Git to intentionally ignore specific files or folders in my project. |


---

## 6. Steps Used to Complete This Lab

### Step 1: Create and Open the Project Folder

Navigate to the location where the lab project should be created. The folder should not be inside an existing Git repository.

```bash
mkdir <folder_name>
cd <folder_name>
code .
```

Confirm the current working directory:

```bash
pwd
```

---

### Step 2: Download the Provided Static Assets

Run the provided command to download the starter assets:

```bash
curl https://raw.githubusercontent.com/aaron-dm-mcdonald/class7.5-notes/refs/heads/main/week-7/bam/download-assets.sh | sh
```

After running the command, verify that the static files exist in the project folder:

```bash
ls 
```

Expected files include:

```text
index.html
error.html
style.css
```

A custom image file must also be added manually. The image filename must match the image reference inside the HTML file.

---

### Step 3: Configure the Terraform Provider

Create a `provider.tf` file to configure the Google provider.

Example:

```hcl
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "current version" 
    }
  }
}

provider "google" {
  project = "project-name"
  region  = "region"
}
```

---

### Step 4: Create Variables

Create a `backend.tf` file to save terraform state remotely.

Example:

```hcl
terraform {
  backend "gcs" {
    bucket = "gcsweek7"
    prefix = "terraform/state"
  }
}

resource "google_compute_disk" "gcs7_disk" {
  name  = "gcs7-disk"
  type  = "pd-standard"
  zone  = "us-central1-a"
  size  = 10
}
```

---

### Step 5: Create the GCS Bucket

Create a `main.tf` file and define the bucket.

Example:

```hcl
resource "google_storage_bucket" "gcswk7" {
  name          = "gcswk7"
  location      = "us-central1"
  storage_class = "STANDARD"
  force_destroy = true

  uniform_bucket_level_access = true

  website {
    main_page_suffix = "index.html"
    not_found_page = "404.html"
  }
}
```

Important settings:

- `force_destroy = true` allows Terraform to delete the bucket even if objects are still inside it.
- `uniform_bucket_level_access = true` helps manage access through bucket-level IAM instead of object ACLs.
- The `website` block enables static website behavior for the bucket.

---

### Step 6: Upload the Static Website Objects

Add one Terraform object resource for each uploaded file then run terraform plan and apply after adding each new object.

Example:

```hcl
resource "google_storage_bucket_object" "index" {
    name = "index.html"
    bucket = google_storage_bucket.your_bucket_name.name
    source = "index.html"
}

resource "google_storage_bucket_object" "error" {
    # names must start with a letter or underscore
    name = "error.html"
    bucket = google_storage_bucket.your_bucket_name.name
    source = "404.html"
}

resource "google_storage_bucket_object" "style" {
    name = "style.css"
    bucket = google_storage_bucket.your_bucket_name.name
    source = "style.css"
}

resource "google_storage_bucket_object" "mines" {
    name = "mines"
    bucket = google_storage_bucket.your_bucket_name.name
    source = "your-image.png/jpg/jpeg"
}
```

If using a `.jpg`, `.jpeg`, `.gif`, `.png`, or `.webp` file, update both the Terraform object name and the HTML image reference.

---

### Step 7: Make the Bucket Publicly Readable

Add an IAM member resource so anyone can view the objects.

```hcl
data "google_iam_policy" "objectViewer" {
  binding {
    role = "roles/storage.objectViewer"
    members = [
      "allUsers",
    ]
  }
}

resource "google_storage_bucket_iam_policy" "wk7policy" {
  bucket = google_storage_bucket.your_bucket_name.name
  policy_data = data.google_iam_policy.objectViewer.policy_data
  timeouts {
    # timeout configuration
    create = "5m"
  }
}
```

This IAM resource is needed because the bucket objects must be publicly accessible for the website to load from another computer.

---

### Step 8: Add an Output for the Website URL

Create an `outputs.tf` file.

Example:

```hcl
output "website_url" {
    description = "Public URL for the static website index page"
    value = "https://storage.googleapis.com/${google_storage_bucket.your_bucket_name.name}/index.html"
}

output "website_url_1" {
    description = "Public URL for the static website error page"
    value = "https://storage.googleapis.com/${google_storage_bucket.your_bucket_name.name}/error.html"
}

output "style_css" {
    description = "Public URL for css styling"
    value = "https://storage.googleapis.com/${google_storage_bucket.gcswk7.name}/style.css"
}

output "website_image" {
    description = "Public URL for the static website image page"
    value = "https://storage.googleapis.com/${google_storage_bucket.gcswk7.name}/mines.png"
}
```

This output builds a public URL using the bucket name and the uploaded `index.html` and `404.html` object.

---

### Step 9: Initialize Terraform

```bash
terraform init
```

Expected result:

```text
Terraform has been successfully initialized!
```

---

### Step 10: Validate and Format the Terraform Code

```bash
terraform fmt
terraform validate
```

Expected result:

```text
Success! The configuration is valid.
```

---

### Step 11: Run Terraform Plan

```bash
terraform plan
```

Review the plan and confirm that Terraform will create:

- One GCS bucket
- Four bucket objects
- One bucket IAM member
- The static website configuration
- The output URL

---

### Step 12: Apply the Terraform Configuration

```bash
terraform apply
```

Type `yes` when prompted.

After the deployment completes, Terraform should show an output similar to:

```text
website_url = "https://storage.googleapis.com/your_bucket_name/index.html"
```

---

### Step 13: Test the Website

Open the Terraform output URL in a browser.

You can also test with `curl`:

```bash
curl -I https://storage.googleapis.com/your_bucket_name/index.html
curl -I https://storage.googleapis.com/your_bucket_name/style.css
curl -I https://storage.googleapis.com/your_bucket_name/your_image.jpeg/png/jpg/gif
curl -I https://storage.googleapis.com/your_bucket_name/error.html
```

---

### Step 14: Verify Public Access from Another Computer

Ask a classmate or group member to open the website URL from their own computer.

Document whether they were able to access:

- The main page
- The CSS styling
- The image
- The error page

---

## 7. Artifacts / Screenshots



### Screenshot 1: Project Folder in VS Code

![VScode Folder](/screenshots/01-vscode_folder.PNG)

Description:

- Shows the local project folder.
- Shows Terraform files and static assets.
- Confirms the project is organized correctly.

---

### Screenshot 2: Downloaded Static Assets

![Downloaded Assets](/screenshots/02-download_assests.png)

Description:

- Shows `index.html`, `error.html`, `style.css`, and the custom image file.
- Confirms the starter files were downloaded successfully.

---

### Screenshot 3: Backend

![Backend](/screenshots/03-backend.png)

Description:

- Shows the backend bucket in Google Cloud Console.
- Confirms Terraform state can be saved remotely.

### Screenshot 4: Terraform Init

![Terraform Init](/screenshots/04-terraform_init.png)

Description:

- Shows `terraform init` completing successfully.
- Confirms provider plugins were installed.

---

### Screenshot 5: Terraform Validate

![Terraform Validate](/screenshots/05-terraform_validate.png)

Description:

- Shows `terraform validate` returning a successful validation message.
- Confirms the Terraform syntax is correct.

---

### Screenshot 6: Terraform Plan

![Terraform Plan](/screenshots/06-terraform_plan.png)

Description:

- Shows Terraform planning the bucket, object uploads, IAM member, and website settings.
- Confirms Terraform understands what resources need to be created.

---

### Screenshot 7: Terraform Apply

![Terraform Apply](/screenshots/07-terraform_apply.png)

Description:

- Shows `terraform apply` completing successfully.
- Shows the final output URL for the static website.

---

### Screenshot 8: GCS Bucket Created

![GCS Bucket](/screenshots/08-bucket_created.png)

Description:

- Shows the bucket in the Google Cloud Console.
- Confirms the bucket was created by Terraform.

---

### Screenshot 9: Objects Uploaded to Bucket

![Uploaded Objects](/screenshots/09-bucket_objects.png)

Description:

- Shows `index.html`, `error.html`, `style.css`, and the image object inside the bucket.
- Confirms Terraform uploaded all required static assets.

---

### Screenshot 10: Public Website Loaded in Browser

![Website Browser Test](/screenshots/010-website.png)

Description:

- Shows the static website loading successfully in a browser.
- Confirms the page, styling, and image are publicly accessible.

---

### Screenshot 11: Public Access Test from Terminal

![Curl Test](/screenshots/011-curl_test.png)

Description:

- Shows a successful `curl -I` test returning HTTP `200`.
- Confirms the object is publicly reachable.

---

### Screenshot 12: Classmate Access Confirmation

![Classmate Access](/screenshots/012-classmate_access.png)

Description:

- Shows proof that another user could access the website from their own computer.
- Confirms public access was configured correctly.

---

### Screenshot 13: Terraform Destroy

![Terraform Destroy](/screenshots/013-terraform_destroy.png)

Description:

- Shows the infrastructure being destroyed after the lab.
- Confirms cloud resources were removed to avoid unnecessary cost.

---

## 8. Steps Used to Teardown or Destroy the Infrastructure

When the lab is complete, destroy the resources to avoid leaving public cloud resources running.

Run:

```bash
terraform destroy
```

Type `yes` when prompted.

After the destroy completes, verify that the bucket is gone:

```bash
gcloud storage buckets list
```

If the bucket was destroyed successfully, the command should return an error saying the bucket does not exist or that the URL matched no objects.

The bucket resource used `force_destroy = true`, which allows Terraform to delete the bucket and the objects inside it during teardown.

---

## 9. Lessons Learned

### What Is Relatable to the User or Customer?

This lab is relatable because many real businesses need a simple and inexpensive way to host static content such as landing pages, documentation, internal guides, maintenance pages, or proof-of-concept websites.

Using Terraform makes the process repeatable. Instead of manually clicking through the console, the same configuration can be reused across environments.

---

### What Did I Learn While Building This Lab?

Key lessons from this project:

- GCS can host static website assets, but it works differently from AWS S3 static website hosting.
- Public access requires IAM permissions.
- The `roles/storage.objectViewer` role allows public users to view bucket objects.
- The `website` block configures the main page and error page.
- File names must match between the HTML source and Terraform object resources.

---

### What Changes Could Improve This Infrastructure?

Potential improvements include:


- Add versioning for bucket objects.
- Add logging and monitoring.


---

## 10. References

- Google Cloud. (n.d.). *Hosting a static website*. Google Cloud Storage Documentation. https://docs.cloud.google.com/storage/docs/hosting-static-website
- Google Cloud. (n.d.). *Cloud Storage IAM roles*. Google Cloud IAM Documentation. https://cloud.google.com/storage/docs/access-control/iam-roles
- Google Cloud. (n.d.). *Uniform bucket-level access*. Google Cloud Uniform bucket-level access Documentation. https://docs.cloud.google.com/storage/docs/uniform-bucket-level-access
- HashiCorp. (n.d.). *Google Provider Documentation*. Terraform Registry. https://registry.terraform.io/providers/hashicorp/google/latest/docs
- HashiCorp. (n.d.). *google_storage_bucket*. Terraform Registry. https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket
- HashiCorp. (n.d.). *google_storage_bucket_object*. Terraform Registry. https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_object
- HashiCorp. (n.d.). *google_storage_bucket_iam_member*. Terraform Registry. https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam
- HashiCorp. (n.d.). *Output data from Terraform*. Developer HashiCorp. https://developer.hashicorp.com/terraform/tutorials/configuration-language/outputs

---

## 11. Troubleshooting Section


### Common Issues and Fixes

| Issue | Possible Cause | Fix |
|---|---|---|
| Website returns `403 Forbidden` | Public IAM access was not applied. | Check the `google_storage_bucket_iam_member` resource. |
| Image does not load | Image filename does not match the HTML reference. | Update the HTML or object resource name. |
| CSS does not apply | CSS filename or path is incorrect. | Confirm the CSS file name in HTML and Terraform. |
| Bucket name error | Bucket name is not globally unique. | Choose a unique bucket name. |
| Terraform cannot delete bucket | Bucket contains objects. | Use `force_destroy = true`. |


---

### System / Local Commands Used

List files:

```bash
ls -la
```

Show current directory:

```bash
pwd
```

Create a folder:

```bash
mkdir
```

Open project in VS Code:

```bash
code .
```

---

## 12. Author & Contributors

**Author:** `Joe Tolliver`

**Group Leader:** `Jacques Payne`

**Group Name:** `T.K.O.`

**Date:** `4/29/2026`

**Version:** `1.0`

---


