# Terraform_homework

Create Terraform configuration file,
which creates compute instance type e2-micro with a Debian 9
OS and installed NGINX web server.
The Web server must show the message:
"Hello world from Crash course DevOps"

## Conventional module structure
It is strongly recommended splitting the code logically into the following files:

* `main.tf` - create all resources
* `provider.tf` - contains Provider's configuration. It's not changed as much as other parts of code, so it's better to keep it in a separate file
* `data.tf` - contains data sources
* `variables.tf` - contains declarations of variables used in main.tf
* `outputs.tf` - contains outputs from the resources created in main.tf
* `terraform.tfvars` - the values of variables are specified here. They are usually project-specific, so it's better to add it to .gitignore. You should try keeping Terraform code as generic as possible, so it can be easily re-used by other people.
* `terraform.tfvars.example` - this one contains some examples on how to specify the variables, some comments, etc. Store it in the repo, so everyone can use it as an example
* `firewall.tf` can be used to separate firewall settings

## Avoid using hard-coded parameters
All the input parameters, used by resources, data sources, providers and outputs, should come from:
* variables
```hcl
resource "aws_key_pair" "tf-key" {
  key_name   = var.key_pair_name
  public_key = file(var.public_key_file)
}
```

* data sources
```hcl
ami           = data.aws_ami.debian.id
```

* other resources
```hcl
resource "aws_eip" "elastic_ip" {
  instance = aws_instance.devops_task_6c.id
}
```

## Data source - Dynamic block
Data source `aws_ami` has repeatable content chunks, the `filter {}`. Which is when the dynamic block can help avoid copying and pasting similar chunks of code many times. Please take a look at the `data.tf` and `variables.tf` (variable `ami_filters`) to see how it works.

## Firewall Rules - Dynamic block
The same, `aws_security_group` resource contains `ingress {}` and `egress {}` structures, which are designed to repeat multiple times inside the resource. I've implemented the dynamic blocks there as well. Please review the `firewall.tf`, `variables.tf` and `terraform.tfvars.example` (variables `ingress_fw_rules` and `egress_fw_rules`).

>**Note:** for the `egress_fw_rules` variable in the `variables.tf` file I've specified a default parameter, which defines the egress firewall rule allowing all egress requests traveling **from** the EC2 instance. That is required for the bootstrap script to be able to access package repository and install Nginx Web Server. On the other hand, the default value for the `ingress_fw_rules` is an empty list. Which basically means that all ingress requests, sent to the EC2 instance, will be rejected. That won't prevent the bootstrap script from installing Nginx, but the Web Server will not be accessible from the external network, unless a set of the ingress rules is defined in the `terraform.tfvars`, which can be done **after** the EC2 instance is provisioned.

## Bootstrap script
It's better to keep the bootstrap script in a separate file. Please take a look at the `user_data` parameter in the `aws_instance` resource (`main.tf`), `bootstrap_script_file` variable in the `variables.tf` file and the bootstrap script itself in the `nginx.sh` file.