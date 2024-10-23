# Installing Nginx on Ubuntu Servers**

This playbook installs **Nginx** on specified servers.

**Playbook: `install_nginx.yml`**

```yaml
---
- name: Install Nginx on Ubuntu
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

    - name: Start Nginx
      service:
        name: nginx
        state: started
        enabled: yes
```

## **How to Run the Playbook**

1. Save the playbook as `install_nginx.yml`.
2. Run it using the `ansible-playbook` command:

   ```bash
   ansible-playbook -i <inventory_file> install_nginx.yml
   ```

   - Replace `<inventory_file>` with your inventory file that specifies the target hosts (e.g., `hosts` or `inventory`).
