# Managing Services on Remote Hosts

This playbook stops, starts, or restarts a service on remote hosts.

**Playbook: `manage_service.yml`**

```yaml
---
- name: Manage Apache Service
  hosts: webservers
  become: yes

  tasks:
    - name: Ensure Apache is installed
      apt:
        name: apache2
        state: present

    - name: Restart Apache service
      service:
        name: apache2
        state: restarted
```

## **How to Run the Playbook**

1. Save it as `manage_service.yml`.
2. Execute it with:

   ```bash
   ansible-playbook -i <inventory_file> manage_service.yml
   ```
