# 7. **Handlers**

- **What it is**: Handlers are special tasks that are triggered by other tasks to perform actions like service restarts.
- **Purpose**: They allow for specific tasks to be triggered only when needed, reducing unnecessary actions.
- **Why we use it**: Handlers optimize task execution by only running when there are changes that require an action, like restarting a service.
- **Real-life Example**: Like a "fire alarm," which is triggered only when smoke is detected.

## Hands-On Example

1. **Add a Handler in the Nginx Role in VS Code:**
   - Create `roles/nginx/handlers/main.yml`:

     ```yaml
     ---
     - name: restart nginx
       service:
         name: nginx
         state: restarted
     ```

2. **Update the Task to Notify the Handler in VS Code:**
   - Modify `roles/nginx/tasks/main.yml`:

     ```yaml
     ---
     - name: Install Nginx
       apt:
         name: nginx
         state: present

     - name: Deploy Nginx config
       template:
         src: nginx.conf.j2
         dest: /etc/nginx/sites-available/default
       notify: restart nginx
     ```

3. **Run the Playbook from WSL:**

   ```bash
   ansible-playbook -i inventory.ini main.yml
   ```
