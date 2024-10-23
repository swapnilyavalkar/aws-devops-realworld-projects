# 9. **Vault**

- **What it is**: Ansible Vault is used to encrypt sensitive data, like passwords or API keys, in playbooks and files.
- **Purpose**: It secures confidential information, making it safe to store sensitive data in version control.
- **Why we use it**: Vault ensures that sensitive data is encrypted, protecting it from unauthorized access.
- **Real-life Example**: Like a “safe,” which locks away valuables, only accessible with the right key.

## Hands-On Example

1. **Create a Vault File in WSL:**

   ```bash
   ansible-vault create secrets.yml
   ```

   - Add sensitive variables like:

     ```yaml
     db_password: "SuperSecretPassword"
     ```

2. **Use the Vault File in a Playbook:**
   - Update `webserver-setup.yml`:

     ```yaml
        ---
        - name: Use encrypted variable
        hosts: wsl
        become: yes
        vars_files:
        - secrets.yml
        tasks:
        - name: Show db password
            debug:
                var: db_password

     ```

3. **Run the Playbook with Vault Decryption:**

   ```bash
   ansible-playbook -i inventory.ini webserver-setup.yml --ask-vault-pass
   ```
