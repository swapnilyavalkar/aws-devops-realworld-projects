# 6. **Templates**

- **What it is**: Templates are Jinja2 files that allow dynamic content generation, often used to create configuration files.
- **Purpose**: They enable the generation of customized files based on variables and templates, adapting to different environments.
- **Why we use it**: Templates allow dynamic configuration management, making it easy to deploy environment-specific files.
- **Real-life Example**: Like a “fill-in-the-blank form,” where blanks are filled with different values based on the context.

## Hands-On Example

1. **Create a Template File in VS Code:**
   - Create a file named `nginx.conf.j2` in the `roles/nginx/templates` directory with the following content:

     ```
     server {
       listen 80;
       server_name {{ ansible_hostname }};
       location / {
         root /var/www/html;
         index index.html;
       }
     }
     ```

2. **Add a Template Task in the Role in VS Code:**
   - Update `roles/nginx/tasks/main.yml`:

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
     ```

3. **Run the Playbook from WSL:**

   ```bash
   ansible-playbook -i inventory.ini main.yml
   ```
