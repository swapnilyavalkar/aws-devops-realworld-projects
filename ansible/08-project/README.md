# 8. **Facts**

- **What it is**: Facts are variables automatically collected by Ansible from target hosts, providing system information like OS, IP, etc.
- **Purpose**: They provide dynamic information about target systems that can be used in playbooks for decision-making.
- **Why we use it**: Facts help in making playbooks more intelligent, adapting to the actual state of the target machines.
- **Real-life Example**: Like a “health check” that gathers vital signs before treatment, helping in better decision

-making.

## Hands-On Example

1. **Create a Playbook to Gather Facts in VS Code:**
   - Create `gather-facts.yml`:

     ```yaml
     ---
     - name: Gather facts from webservers
       hosts: webservers
       tasks:
         - name: Display OS version
           debug:
             var: ansible_distribution_version
     ```

2. **Run the Playbook from WSL:**

   ```bash
   ansible-playbook -i inventory.ini gather-facts.yml
   ```
