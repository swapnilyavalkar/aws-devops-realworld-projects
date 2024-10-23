# 5. **Variables**

- **What it is**: Variables are used to store dynamic values that can be used in playbooks, tasks, templates, and roles.
- **Purpose**: They provide flexibility by allowing different values to be passed to the same tasks, making configurations dynamic.
- **Why we use it**: Variables help customize configurations for different hosts, making playbooks adaptable to various scenarios.
- **Real-life Example**: Like "ingredients in a recipe" that can be substituted based on availability (e.g., sugar vs. honey).

## Hands-On Example

1. **Define Variables in a Playbook in VS Code:**
   - Update `webserver-setup.yml`:

     ```yaml
     ---
     - name: Install Nginx with variables
       hosts: webservers
       become: yes
       vars:
         package_name: nginx
       tasks:
         - name: Install {{ package_name }}
           apt:
             name: "{{ package_name }}"
             state: present
     ```

2. **Run the Playbook from WSL:**

   ```bash
   ansible-playbook -i inventory.ini webserver-setup.yml
   ```
