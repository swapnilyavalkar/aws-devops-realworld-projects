# 4. **Roles**

- **What it is**: Roles are a way to structure Ansible playbooks and tasks by organizing them into separate directories for easier management.
- **Purpose**: They provide reusable, modular components for deploying and managing configurations across multiple environments.
- **Why we use it**: Roles make playbooks more manageable, modular, and reusable across different projects or environments.
- **Real-life Example**: Like "sections of a recipe book," where each section contains related recipes for a specific type of cuisine.
  
## Hands-On Example

1. **Create a Role Structure in WSL:**

   ```bash
   mkdir -p roles/nginx-01/{tasks,handlers,templates}
   ```

2. **Add a Task File for Nginx in VS Code:**
   - Create a file named `roles/nginx/tasks/main.yml` with the following content:

     ```yaml
     ---
     - name: Install Nginx
       apt:
         name: nginx
         state: present
     ```

3. **Create a Playbook to Use the Role in VS Code:**
   - Create a file named `playbook.yml`:

     ```yaml
     ---
     - name: Apply Nginx role to webservers
       hosts: wsl
       roles:
         - nginx-01
     ```

4. **Run the Playbook from WSL:**

   ```bash
   ansible-playbook -i inventory.ini main.yml
   ```
