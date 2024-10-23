# Copying Files to Remote Servers

This playbook copies a file from your local system to remote servers.

**Playbook: `copy_file.yml`**

```yaml
---
- name: Copy file to remote server
  hosts: all
  become: yes

  tasks:
    - name: Copy index.html to /var/www/html
      copy:
        src: ./index.html
        dest: /var/www/html/index.html
        mode: '0644'
```

## **How to Run the Playbook**

1. Save the playbook as `copy_file.yml`.
2. Run it:

   ```bash
   ansible-playbook -i <inventory_file> copy_file.yml
   ```
