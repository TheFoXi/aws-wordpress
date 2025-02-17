# **Installing WordPress on AWS using Terraform**

This project automatically deploys **WordPress** on AWS **EC2 (Ubuntu 24.04)** using **RDS (MySQL) and ElastiCache (Redis)**.

**All resources are configured in the `eu-west-1` region with AWS Free Tier considerations.**  
The region and other settings can be changed in the Terraform configuration.

---

## Requirements
Before starting, make sure you have:
- **AWS account** with **Free Tier**.
- The pairing of the private and public key. The public key must be stored in `EC2 > Key Pairs`.  
  In this example, the key name is **“wordpress”**. (`terraform.tfvars > ec2_ssh_key`)
- The **wp_deploy.sh** script is designed for installation only on **Ubuntu servers**.
- **Locally installed tools**:
  - [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
  - [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
  - AWS user with the required permissions (For this example, [AdministratorAccess](https://docs.aws.amazon.com/aws-managed-policy/latest/reference/AdministratorAccess.html) will work, but for production, a limited user should be created.)

## Project Structure 

```text
README.md
deploy/
│── wp_deploy.sh            # Deployment script for WordPress
terraform/
│── modules/                # Reusable Terraform modules
│   ├── alb/                # ALB (Application Load Balancer )
│   ├── vpc/                # VPC (Networking)
│   ├── sg/                 # Security Group rules for EC2, RDS, Redis
│   ├── ec2/                # EC2 Instance for WordPress
│   ├── rds/                # RDS MySQL Database
│   ├── redis/              # ElastiCache Redis
│   ├── iam/                # IAM Users
│── providers.tf            # AWS provider configuration
│── main.tf                 # Root file that calls all modules
│── variables.tf            # Global variables
│── terraform.tfvars        # Predefined values for global variables
│── outputs.tf              # Global output values
```


---

## What will be created?
After deployment, will be created:
- **EC2 instance** (`t2.micro`, Ubuntu 24.04) for the web server.
- **VPC** with **public and private subnets**.
- **Security Groups** (for EC2, RDS, Redis).
- **RDS MySQL** (WordPress database).
- **ElastiCache Redis** (session caching for WordPress).
- **Nginx + PHP 8.3** (for handling requests).
- **Automatic WordPress deployment** via `wp-cli`.

---

## AWS Profile Setup
Before deployment, you need to configure **AWS CLI** so Terraform can use your account.

### **1. Add AWS credentials**
If you have an **Access Key** and **Secret Key**, configure the profile:
```shell
aws configure
```
Enter the details:
```
AWS Access Key ID [None]: YOUR_ACCESS_KEY
AWS Secret Access Key [None]: YOUR_SECRET_KEY
Default region name [None]: eu-west-1
Default output format [None]: json
```
**Important:** This profile will be used automatically.

---

### **2. Verify connection**
Run the command:
```shell
aws sts get-caller-identity
```
If everything is fine, you will see **your user ID**:
```json
{
    "UserId": "AIDXXXXXXXXXXX",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/terraform-user"
}
```

---

## Deploying the Project
Now you can deploy the infrastructure using Terraform.

### **1. Initialize Terraform**
Go to the project folder `cd /terraform` and run:
```shell
terraform init
```
- This downloads the required **modules and providers**.

---

### **2. Pre-deployment check**
```shell
terraform plan
```
- Displays the **list of resources** Terraform will create.

---

### **3. Deploy the infrastructure**
```shell
terraform apply
```
- Creates **EC2, RDS, Redis, and all necessary resources**.

**!!! The process takes ~5-10 minutes. !!!**

---
## Preparing for WordPress Installation

### **1. Get the EC2 IP address**
After `terraform apply`, retrieve **server parameters**:
```shell
terraform output
```
You will see something like:
```shell
alb_dns = "wordpress-alb-xxxxxxxxx.eu-west-1.elb.amazonaws.com"
ec2_public_ip = "111.22.3.444"
rds_endpoint  = "wordpress-db.xxxxxxxxxxxx.eu-west-1.rds.amazonaws.com"
redis_endpoint = "wordpress-redis.xxxxxxxxxxxx.0001.euw1.cache.amazonaws.com"
```
**Copy** `ec2_public_ip` – it is needed for SSH.  
**Save** `rds_endpoint` and `redis_endpoint` – they will be needed later.
---
### **2. Connect to the server via SSH**
To log in to the server, use:
```shell
ssh -i /path/to/your/priv_key ubuntu@111.22.3.444
```
**Replace `111.22.3.444`** with your EC2 IP address.

---
### **3. Upload the script to the server**
```shell
scp -i /path/to/your/priv_key ./deploy/wp_deploy.sh ubuntu@111.22.3.444:~
```
This **uploads the script** to the home directory of the `ubuntu` user.

### 3.1 Alternative method
Log into the server and manually create `wp_deploy.sh`
```shell
nano wp_deploy.sh
```
Paste the code from the local file `deploy/wp_deploy.sh`
```shell
chmod +x wp_deploy.sh
sudo ./wp_deploy.sh
```

---

### **4. Grant execution permissions**
After logging into the server, run:
```shell
chmod +x wp_deploy.sh
```
**Now the script can be executed**.

---

## **Running WordPress Installation**

Run the script **with `sudo` privileges**:
```shell
sudo ./wp_deploy.sh
```
The script **will ask for input parameters.**  
Most parameters can be left as default, but these **must be entered**:  
**MySQL** hostname - `rds_endpoint` (Without port :3306)  
**Redis** hostname - `redis_endpoint`  
**EC2** IP – `ec2_public_ip`
### After entering all data, **WordPress will be installed automatically**.

---

## How to verify WordPress is running?
After installation, you can check if WordPress is working:

### **1. Get the EC2 IP or ALB address**
```shell
terraform output ec2_public_ip
OR
terraform output alb_dns
```
📌 Copy the IP address and open it in a browser:
```
http://YOUR_EC2_IP/
OR
http://wordpress-alb-********.eu-west-1.elb.amazonaws.com/
```

---

### **2. Access the WordPress admin panel**
Open:
```
http://IP or ALB/wp-admin
```
Enter the previously set **Username** and **Password**.

---

## Deleting Resources
If the project is no longer needed, you can delete all resources:
```shell
terraform destroy -auto-approve
```
**Important:** This will delete **all** created resources.

---

## **Additional Settings**
If you need to:
- **Change the region and availability zones** → Modify `terraform.tfvars`
- **Change the EC2 settings** → Modify `ec2_ami`, `ec2_ssh_key` or `instance_type` in `terraform.tfvars`
- **Change the MySQL Config** → Modify `terraform.tfvars` MySQL Configs

## **Troubleshooting**
* After running `nginx -t`, you get the error:  
  *could not build server_names_hash, you should increase server_names_hash_bucket_size: 64*

**Solution:** Increase `server_names_hash_bucket_size` to 128 because the ALB address is longer than 64 characters.

```shell
sudo nano /etc/nginx/nginx.conf
```

Find the `http { ... }` block and add the following line inside it:

```shell
server_names_hash_bucket_size 128;
```

Example:
```nginx
http {
    server_names_hash_bucket_size 128;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # Other settings...
}
```

Apply the changes:
```shell
sudo nginx -t  # Validate the configuration
sudo systemctl restart nginx  # Restart Nginx
```  

**After these steps, Nginx should work without errors with ALB DNS name.**




