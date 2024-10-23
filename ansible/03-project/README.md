# 3. **Playbooks**

- **What it is**: A playbook is a YAML file that defines a set of tasks to run against hosts or groups of hosts.
- **Purpose**: It allows the user to define multiple tasks in a sequence, making complex workflows easier to manage.
- **Why we use it**: Playbooks help in orchestrating multiple tasks in one go, making configuration management more efficient.
- **Real-life Example**: Like a "recipe," where each step is followed to prepare a dish, ensuring consistency and order.

## Hands-On Example

1. **Create a Playbook in VS Code:**
   - Create a file named `webserver-setup.yml` and add the following content:

     ```yaml
     ---
     - name: Install Nginx on webservers
       hosts: webservers
       become: yes
       tasks:
         - name: Update apt cache
           apt:
             update_cache: yes

         - name: Install Nginx
           apt:
             name: nginx
             state: present

         - name: Start Nginx service
           service:
             name: nginx
             state: started
     ```

2. **Run the Playbook from WSL:**

   ```bash
   ansible-playbook -i inventory.ini webserver-setup.yml
   ```
