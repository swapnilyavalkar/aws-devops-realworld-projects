# 2. **Modules**

- **What it is**: Modules are standalone scripts or plugins that perform specific tasks, like installing packages, managing files, or interacting with services.
- **Purpose**: They are the building blocks of Ansible automation, handling tasks on target machines.
- **Why we use it**: They allow Ansible to perform actions like configuration management, software deployment, and service orchestration.
- **Real-life Example**: Like “tools in a toolbox,” each module performs a specific task, such as tightening a screw or hammering a nail.
  
## Hands-On Example

1. **Run a Shell Module from WSL:**

   ```bash
   ansible -i inventory.ini wsl -m shell -a "uptime"
   ```

   - This command uses the `shell` module to check the uptime of all web servers listed in the inventory.
