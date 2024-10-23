### 7. **Terraform Modules**

#### Quick Theory

- A **module** is a container for multiple resources that are used together. Every Terraform configuration is actually part of a module, even if you don’t explicitly define one (the root module is the main working directory).
- Modules allow you to:
  - Reuse your infrastructure code across projects.
  - Organize your Terraform code better.
  - Abstract away complexity by encapsulating resources.

---

#### Step 1: Creating a Basic Module

Let’s start by creating a simple module to manage EC2 instances. You can then call this module from your root module.

1. **Create a directory** called `modules` inside your project:

   ```bash
   mkdir -p modules/ec2_instance
   ```

2. Inside `modules/ec2_instance`, create a `main.tf` file. This will define what the module does:

   ```hcl
   # EC2 instance module

   variable "instance_ami" {
     description = "The AMI to use for the EC2 instance"
     type        = string
   }

   variable "instance_type" {
     description = "The instance type"
     type        = string
     default     = "t2.micro"
   }

   resource "aws_instance" "this" {
     ami           = var.instance_ami
     instance_type = var.instance_type

     tags = {
       Name = "Instance from module"
     }
   }

   output "instance_id" {
     value = aws_instance.this.id
   }

   output "instance_public_ip" {
     value = aws_instance.this.public_ip
   }
   ```

3. **Define module input and outputs** in the `main.tf`. Notice that the AMI and instance type are passed in as variables, and we output the instance ID and public IP.

---

#### Step 2: Calling the Module from Root Configuration

Now that we have defined a module, let’s call it from the root configuration (`main.tf`).

1. In your root `main.tf` (outside the `modules` directory), replace the EC2 instance block with the following code to use the module:

   ```hcl
   provider "aws" {
     region = "us-west-2"
   }

   module "my_ec2_instance" {
     source        = "./modules/ec2_instance"
     instance_ami  = "ami-0c55b159cbfafe1f0"
     instance_type = "t3.micro"  # You can change this to a different instance type
   }

   output "instance_id" {
     value = module.my_ec2_instance.instance_id
   }

   output "instance_public_ip" {
     value = module.my_ec2_instance.instance_public_ip
   }
   ```

In the above code:

- **`source`** specifies the path to the module (relative or remote, like a GitHub URL or Terraform Registry).
- The module’s inputs are passed as variables (`instance_ami`, `instance_type`).
- The outputs from the module are accessed using `module.<module_name>.<output>`.

---

#### Step 3: Applying the Configuration

1. Run `terraform init` to initialize the configuration and ensure the module is recognized.
2. Run `terraform apply` to create the EC2 instance using the module.

```bash
terraform apply
```

Once applied, you should see the outputs from the module such as the instance ID and public IP.

---

### Step 4: Organizing Larger Projects with Modules

In larger projects, modules help you break down your infrastructure into logical parts. Common examples include:

- A **VPC module** to manage networking (subnets, routes, etc.).
- An **RDS module** to manage database instances.
- A **Security group module** to handle firewall rules.

You can also use **remote modules** from the [Terraform Registry](https://registry.terraform.io/), which provides pre-built modules for many common infrastructure patterns. For example, there are official AWS VPC and security group modules available.

---

### 8. **Terraform Workspaces**

#### Quick Theory

- **Workspaces** are a way to manage multiple environments using the same Terraform configuration. Each workspace has its own state, allowing you to create isolated versions of your infrastructure (e.g., for development, staging, and production).
- By default, Terraform operates in the **default workspace**. You can create new workspaces and switch between them as needed.

---

#### Step 1: Create and Use Workspaces

Let’s try using workspaces to create separate environments.

1. **Check the current workspace:**

   ```bash
   terraform workspace show
   ```

2. **Create a new workspace** for development:

   ```bash
   terraform workspace new dev
   ```

3. You can create more workspaces (e.g., staging, prod):

   ```bash
   terraform workspace new staging
   terraform workspace new prod
   ```

4. **List all workspaces**:

   ```bash
   terraform workspace list
   ```

5. **Switch to a different workspace** (e.g., prod):

   ```bash
   terraform workspace select prod
   ```

Now, whenever you run `terraform apply`, Terraform will apply the infrastructure changes for the current workspace (e.g., dev, staging, prod), keeping the state isolated between environments.

---

#### Step 2: Using Workspaces in Configuration

You can modify your Terraform code to behave differently based on the workspace. For example, let’s adjust the instance name based on the active workspace.

1. Modify the `main.tf` file to include the workspace in the instance name:

   ```hcl
   resource "aws_instance" "example" {
     ami           = var.instance_ami
     instance_type = var.instance_type

     tags = {
       Name = "${terraform.workspace}-instance"
     }
   }
   ```

2. Apply the configuration in different workspaces:

   ```bash
   terraform workspace select dev
   terraform apply

   terraform workspace select prod
   terraform apply
   ```

Each workspace will now have a separate EC2 instance with a name reflecting the workspace (`dev-instance`, `prod-instance`).

---

### 9. **Terraform Data Sources**

#### Quick Theory

- **Data Sources** allow you to **fetch information about existing infrastructure** from your cloud provider or other sources. This is useful when you want to reference existing resources that are not managed by Terraform (like an existing VPC, or a list of available AMIs).

---

#### Step 1: Using Data Sources

Let’s say you want to use the most recent Amazon Linux 2 AMI without hardcoding its ID.

1. Modify your `main.tf` to use the AWS AMI **data source**:

   ```hcl
   # Fetch the latest Amazon Linux 2 AMI
   data "aws_ami" "latest_amazon_linux" {
     most_recent = true
     owners      = ["amazon"]

     filter {
       name   = "name"
       values = ["amzn2-ami-hvm-*-x86_64-gp2"]
     }
   }

   resource "aws_instance" "example" {
     ami           = data.aws_ami.latest_amazon_linux.id  # Use the fetched AMI
     instance_type = var.instance_type

     tags = {
       Name = "DataSource-Instance"
     }
   }
   ```

2. Now, whenever you run `terraform apply`, Terraform will query AWS for the most recent Amazon Linux 2 AMI and use it for the EC2 instance.

---

#### Step 2: Other Common Data Sources

Here are a few other common data sources:

1. **Fetching an existing VPC**:

   ```hcl
   data "aws_vpc" "default" {
     default = true
   }

   output "vpc_id" {
     value = data.aws_vpc.default.id
   }
   ```

2. **Fetching available subnets**:

   ```hcl
   data "aws_subnet_ids" "available" {
     vpc_id = data.aws_vpc.default.id
   }

   output "subnet_ids" {
     value = data.aws_subnet_ids.available.ids
   }
   ```

Using data sources allows you to integrate existing infrastructure with your Terraform configurations, making it easier to work with resources not directly managed by Terraform.

---

### **Advance Topics**

#### **1. How Do You Manage Sensitive Information in Terraform?**

##### Problem

Sensitive data such as API keys, passwords, or private keys shouldn't be hardcoded into Terraform configuration files. Instead, they need to be managed securely.

##### Solutions (Using Free Features)

- **Option 1: Environment Variables**
  - One of the simplest ways to handle sensitive data is to pass it as an environment variable during runtime.

- **Option 2: Using `.tfvars` Files**
  - You can use variable files (`.tfvars`) to store sensitive information and avoid hardcoding it into the main Terraform configuration.
  - **Tip**: Always add `.tfvars` files to `.gitignore` to avoid committing them to version control.

##### **Managing Sensitive Information with Environment Variables**

Using environment variables is a simple and effective way to manage sensitive information, like API keys, database passwords, or cloud credentials, without storing them directly in your Terraform files.

#### **Steps for Using Environment Variables in Terraform**

---

### **Step 1: Define a Sensitive Variable in Terraform**

Just like in the `.tfvars` file approach, you’ll first define a variable in your Terraform configuration. In this case, we'll define a variable without a default value since we will pass the value at runtime via environment variables.

Create a `variables.tf` file and define a variable for a sensitive piece of information (e.g., a database password):

```hcl
variable "db_password" {
  description = "The database password"
  type        = string
  sensitive   = true  # This ensures Terraform hides the value in outputs and logs.
}
```

---

### **Step 2: Reference the Variable in Terraform Code**

Next, in your Terraform configuration (`main.tf`), use this variable in your resources. For example, if you're creating an AWS RDS instance:

```hcl
resource "aws_db_instance" "example" {
  allocated_storage    = 20
  engine               = "mysql"
  instance_class       = "db.t2.micro"
  name                 = "exampledb"
  username             = "admin"
  password             = var.db_password  # Referencing the sensitive variable
  skip_final_snapshot  = true
}
```

---

### **Step 3: Set the Environment Variable**

Now, rather than passing the password directly in the code or in a `.tfvars` file, you can set the sensitive value using an environment variable.

For example, to set the `db_password` environment variable in your shell:

- On **Linux/macOS**:

  ```bash
  export TF_VAR_db_password="SuperSecretPassword123!"
  ```

- On **Windows (Command Prompt)**:

  ```bash
  set TF_VAR_db_password=SuperSecretPassword123!
  ```

- On **Windows (PowerShell)**:

  ```bash
  $env:TF_VAR_db_password="SuperSecretPassword123!"
  ```

The naming convention `TF_VAR_<variable_name>` tells Terraform to use the value of the environment variable for the corresponding input variable (`db_password` in this case).

---

### **Step 4: Run Terraform Commands**

Now that you've set the environment variable, Terraform will automatically use the value from the environment without requiring it to be hardcoded in your configuration files.

- Run `terraform plan` or `terraform apply` as usual:

  ```bash
  terraform apply
  ```

Since the sensitive value (`db_password`) was passed through the environment, Terraform won’t print it in logs, and it will be used only during resource creation.

---

### **Step 5: Verify That the Value Is Hidden**

If you inspect the plan or apply logs, you'll notice that the `db_password` is masked and marked as sensitive:

```bash
# Example output:
  + password = (sensitive value)
```

This keeps the sensitive information secure and ensures that it is not inadvertently exposed in the logs or the Terraform state file.

### **Summary**

- **Step 1**: Define a sensitive variable in Terraform (`variables.tf`).
- **Step 2**: Reference the sensitive variable in your resource definitions (`main.tf`).
- **Step 3**: Set the environment variable using `export TF_VAR_<variable_name>=<value>`.
- **Step 4**: Run Terraform commands, and Terraform will automatically use the environment variable.
- **Step 5**: Verify that the sensitive value is masked in the Terraform output and logs.

This method is often used in combination with tools like **AWS Secrets Manager**, **HashiCorp Vault**, or other secret management solutions that export environment variables securely in CI/CD pipelines.

---

##### Hands-On Example: Storing and Passing Sensitive Information

1. **Step 1: Define a sensitive variable in `variables.tf`**:

   ```hcl
   variable "db_password" {
     description = "The password for the RDS instance"
     type        = string
     sensitive   = true  # This will hide the value in the output
   }
   ```

2. **Step 2: Create a `.tfvars` file to store sensitive information** (e.g., `secrets.tfvars`):

   ```hcl
   db_password = "SuperSecretPassword123!"
   ```

3. **Step 3: Update your Terraform configuration to use this sensitive variable**:

   ```hcl
   resource "aws_db_instance" "example" {
     allocated_storage    = 20
     engine               = "mysql"
     instance_class       = "db.t2.micro"
     name                 = "exampledb"
     username             = "admin"
     password             = var.db_password  # Use the sensitive variable
     skip_final_snapshot  = true
   }
   ```

4. **Step 4: Run `terraform apply` using the `.tfvars` file**:

   ```bash
   terraform apply -var-file="secrets.tfvars"
   ```

This way, your sensitive values are kept out of the main configuration and only referenced securely. You can also use **environment variables** to pass secrets dynamically.

---

#### **2. How Would You Handle Drift in Your Terraform-managed Infrastructure?**

##### Problem

Drift occurs when changes are made to your infrastructure outside of Terraform (e.g., manually modifying an EC2 instance via the AWS console). Terraform may not be aware of these changes unless you detect and correct the drift.

##### Solution: Terraform’s built-in **`terraform plan`** and **`terraform apply`** commands help detect and fix drift

##### Hands-On Example: Detecting and Correcting Drift

1. **Step 1: Create an EC2 instance with Terraform**:

   ```hcl
   resource "aws_instance" "example" {
     ami           = "ami-0c55b159cbfafe1f0"
     instance_type = "t2.micro"
     tags = {
       Name = "ExampleInstance"
     }
   }
   ```

2. **Step 2: Apply the configuration**:

   ```bash
   terraform apply
   ```

3. **Step 3: Manually change the instance (simulate drift)**:
   - Go to the AWS console and manually change the instance type (e.g., from `t2.micro` to `t3.micro`).

4. **Step 4: Run `terraform plan` to detect drift**:

   ```bash
   terraform plan
   ```

   - Terraform will notice that the actual infrastructure has drifted from the state file and will show the difference.

5. **Step 5: Correct the drift by running `terraform apply`**:

   ```bash
   terraform apply
   ```

   - Terraform will revert the instance type back to `t2.micro` to match the configuration.

---

#### **3. How Would You Structure a Large Terraform Project for a Production Environment?**

##### Problem

As the size of your infrastructure grows, managing everything in a single file becomes unmanageable. You need a way to modularize and structure Terraform code for large-scale production environments.

##### Solution: Use **modules**, **environments**, and a well-organized directory structure

##### Hands-On Example: Structuring a Large Terraform Project

1. **Step 1: Set up a directory structure**:
   - Organize your Terraform code by separating modules, environments, and root configuration.

   ```
   ├── modules/
   │   ├── vpc/
   │   │   └── main.tf
   │   ├── ec2/
   │   │   └── main.tf
   │   └── rds/
   │       └── main.tf
   ├── envs/
   │   ├── dev/
   │   │   └── main.tf
   │   ├── staging/
   │   │   └── main.tf
   │   └── prod/
   │       └── main.tf
   └── main.tf  (root configuration)
   ```

2. **Step 2: Create reusable modules** in the `modules/` folder:
   - For example, create an EC2 module (`modules/ec2/main.tf`) to standardize the EC2 instance creation:

   ```hcl
   variable "instance_type" {
     type    = string
     default = "t2.micro"
   }

   resource "aws_instance" "this" {
     ami           = "ami-0c55b159cbfafe1f0"
     instance_type = var.instance_type

     tags = {
       Name = "ModuleInstance"
     }
   }
   ```

3. **Step 3: Use the modules in different environments**:
   - In the environment-specific `main.tf` (e.g., `envs/prod/main.tf`), call the module:

   ```hcl
   module "ec2_instance" {
     source       = "../../modules/ec2"
     instance_type = "t3.micro"  # Different instance type for production
   }
   ```

4. **Step 4: Apply different environments**:
   - Each environment (dev, prod) can have its own configurations but reuse the same modules for consistency.

   ```bash
   cd envs/prod
   terraform apply
   ```

This structure keeps code organized and ensures that resources are modular and reusable across environments.

---

#### **4. How Would You Organize Terraform Code for a Multi-region Setup?**

##### Problem

Managing resources across multiple AWS regions requires you to adapt Terraform configurations to create infrastructure in different regions.

##### Solution: Use **modules** and **multiple providers** to target different regions

##### Hands-On Example: Multi-region Setup

1. **Step 1: Define providers for different regions in `main.tf`**:

   ```hcl
   provider "aws" {
     alias  = "us-west-1"
     region = "us-west-1"
   }

   provider "aws" {
     alias  = "us-east-1"
     region = "us-east-1"
   }
   ```

2. **Step 2: Use modules with different providers to create resources in both regions**:

   ```hcl
   module "west_region_instance" {
     source    = "./modules/ec2"
     providers = {
       aws = aws.us-west-1
     }
     instance_type = "t3.micro"
   }

   module "east_region_instance" {
     source    = "./modules/ec2"
     providers = {
       aws = aws.us-east-1
     }
     instance_type = "t3.micro"
   }
   ```

3. **Step 3: Apply the configuration**:
   - Terraform will deploy EC2 instances in both regions:

   ```bash
   terraform apply
   ```

This approach allows you to manage infrastructure across multiple regions with minimal duplication of code.

---

#### **5. How Would You Use Terraform to Deploy and Manage an Auto-scaling Group?**

##### Problem

You need to deploy an auto-scaling group (ASG) that scales based on demand, for example, scaling EC2 instances automatically.

##### Solution: Use Terraform’s **AWS autoscaling group** resource

##### Hands-On Example: Deploy an Auto-scaling Group

1. **Step 1: Define a launch configuration for your EC2 instances**:

   ```hcl
   resource "aws_launch_configuration" "example" {
     name          = "example-launch-configuration"
     image_id      = "ami-0c55b159cbfafe1f0"
     instance_type = "t2.micro"
   }
   ```

2. **Step 2: Create the auto-scaling group**:

   ```hcl
   resource "aws_autoscaling_group" "example" {
     launch_configuration = aws_launch_configuration.example.id
     min_size             = 1
     max_size             = 5
     desired_capacity     = 2

     vpc_zone_identifier = ["subnet-0bb1c79de3EXAMPLE"]

     tag {
       key                 = "Name"
       value               = "AutoscalingGroupInstance"
       propagate_at_launch = true
     }
   }
   ```

3. **Step 3: Apply the configuration**:

   ```bash
   terraform apply
   ```

This will deploy an auto-scaling group that starts with 2 instances and can scale between 1 and 5 instances based on demand.
