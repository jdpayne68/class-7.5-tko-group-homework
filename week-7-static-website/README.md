# Static Website on GCS

[Link to the original repo](https://github.com/KirkAlton-Class7/week-7-static-website)

[Link to my basic static website](https://storage.googleapis.com/c7-website-dev-kirkdevsecops/index.html)

[Upgraded version](https://storage.googleapis.com/kirkdevsecops-website/index.html)

> [!NOTE]
> The HTML widget in the upgraded version was developed in collaboration with ChatGPT.

---

This lab deploys a bucket in Google Cloud Storage and hosts a static HTML website.

## Source files:

* `index.html` (front facing page for the website)
* `404.html` (page shown when a website page is not found)
* `style.css` (stylesheet that controls the layout of all web pages)

---

## Some of the benefits of hosting a static website this way are:

* extremely cheap price
* automated deployment and teardown via Terraform
* website can be easily migrated to a different bucket, domain, or cloud provider

---

## Some of the drawbacks are:

* website must be exposed to the public internet
* HTTP only. GCS doesn't natively support HTTPS for custom domains
* HTTPS needs an Application Load Balancer
* cannot serve dynamic content  or "server-side scripts" such as PHP
* only supports "client-side technologies" or static files such as HTML, CSS and JavaScript.
* bucket name must match the domain name exactly

---

## Terraform

> [!NOTE]
>I used locals to create a map of source code files (`index.html`, `404.html` and `style.css`) and a list/tuple of image assets. In `02-bucket` I used `for_each` in the `google_storage_bucket_object` resource to iterate over the locals.

---

# Resources

[CSS Basics (W3Schools)](https://www.w3schools.com/html/html_css.asp)

[Host a Static Website on Google Cloud Storage (HTTP)](https://cloud.google.com/storage/docs/hosting-static-website-http)

[Terraform - Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest)

[Terraform - GCS Backend Configuration](https://developer.hashicorp.com/terraform/language/settings/backends/gcs)

[Terraform - Google Cloud Storage Bucket Resource](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket)

[Cloud Storage - IAM Access Control](https://cloud.google.com/storage/docs/access-control/iam)

[Terraform - Google Cloud Storage Bucket IAM Resource](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam)

[Terraform for_each, toset(), and tomap()](https://developer.hashicorp.com/terraform/language/meta-arguments/for_each)
