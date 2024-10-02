### Step-by-Step Instructions:

1. **Install Terraform (if not already installed)**:
   - You can download and install Terraform from [here](https://www.terraform.io/downloads).

2. **Initialize Terraform**:
   - Run the following command in your project directory (where your `terraform-run-me.tf` is located) to initialize the working directory. This will download the necessary provider plugins (AWS in this case).

   ```bash
   terraform init
   ```

3. **Plan the Terraform Execution**:
   - The `terraform plan` command allows you to see what resources will be created or modified without actually applying them. This step helps you verify if the infrastructure will be created correctly.

   ```bash
   terraform plan -out output
   ```

4. **Apply the Terraform Configuration (Create the Resources)**:
   - This command will create all the resources defined in the Terraform configuration file.

   ```bash
   terraform apply
   ```

   After running the command, Terraform will prompt for confirmation. You can bypass the confirmation prompt by adding the `-auto-approve` flag:

   ```bash
   terraform apply plan_output -auto-approve
   ```

5. **View the Output in the Terminal**:
   - Once the apply process is complete, the output block you defined will display the details (name, ID, and type) of each resource in the terminal.
   
   Example of output in the terminal:
   ```bash
   Apply complete! Resources: 20 added, 0 changed, 0 destroyed.

   Outputs:

   vpc_details = {
     "id" = "vpc-0abcdef1234567890"
     "name" = "MyVPC"
     "type" = "VPC"
   }
   ```

6. **Save the Output to a Text File**:
   - To save the outputs to a text file, use the `terraform output` command with redirection to a file.

   ```bash
   terraform output > terraform_output.txt
   ```

   This command will save the outputs to `terraform_output.txt` in the same directory. The file will contain all the outputs (name, ID, type) of the resources created by Terraform.

7. **Verify the Resources**:
   - After Terraform has created the resources, you can go to the **AWS Management Console** to verify that the resources (EC2 instances, VPCs, Load Balancers, etc.) have been created.

8. **Clean Up (Optional)**:
   - If you want to delete the resources after testing to avoid charges, you can run the following command:

   ```bash
   terraform destroy -auto-approve
   ```

   This will delete all the resources created by Terraform. Like `apply`, you can add the `-auto-approve` flag to skip the confirmation prompt.

### Additional Notes:
- **Manual Steps**:
   - Jenkins Pipeline Configuration: Pipelines and jobs for Jenkins need to be set up via a Jenkinsfile or manually.
   - GitHub Integration: GitHub repository linking and webhook setup for Jenkins need to be configured manually in Jenkins.
   - AppSpec and Deployment Scripts: These need to be placed in the GitHub repository manually.
   - Manual Cleanup Steps: While terraform destroy can remove infrastructure, specific cleanup processes (e.g., archiving logs, terminating instances safely) are not part of Terraform's scope.

- **State File**: Terraform keeps track of your resources in a **state file** (`terraform.tfstate`). This file contains the current state of your infrastructure and is important for managing the lifecycle of your resources.
- **Plan vs. Apply**: Always use `terraform plan` before `apply` to ensure everything is correctly defined.
