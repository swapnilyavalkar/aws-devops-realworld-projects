# 1. **Inventory**

- **What it is**: An inventory is a file that lists the hosts and groups of hosts where Ansible will run playbooks and tasks.
- **Purpose**: It acts as a source of truth for target machines and defines host variables.
- **Why we use it**: It helps organize target hosts, making it easier to manage them for automation tasks.
- **Real-life Example**: Like a "contact list," where each entry represents a person you want to call (a target machine).
  
## Hands-On Example

1. **Create an Inventory File in VS Code:**
   - Open VS Code and create a file named `inventory.ini`.
   - Add the following content to define hosts and groups:

     ```ini
     [webservers]
     192.168.1.10
     192.168.1.11

     [databases]
     192.168.1.20

     [all:vars]
     ansible_user=ubuntu
     ansible_ssh_private_key_file=~/.ssh/id_rsa
     ```

2. **Run a Ping Module from WSL:**

   ```bash
   ansible -i inventory.ini all -m ping
   ```

   - This command pings all the hosts in the inventory to verify connectivity.
