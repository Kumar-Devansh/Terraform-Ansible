# Terraform Ansible

## Overview
This project integrates **Terraform** and **Ansible** to automate infrastructure provisioning and configuration management. Terraform is used to provision the required servers, and Ansible is used for configuring them.

## Prerequisites
Before you begin, ensure you have the following installed on your local machine:

- **Terraform** ([Installation Guide](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli))
- **Ansible** ([Installation Guide](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html))
- **AWS CLI** (if using AWS)
- **Git**
- **SSH Keys** configured for Ansible

## Installation
### 1. Update and Install Ansible
```bash
sudo apt-get update
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible
ansible --version  # Verify installation
```

### 2. Configure Ansible Inventory
Edit the **hosts** file to define the managed servers:
```bash
sudo vim /etc/ansible/hosts
```
Add your servers under a group:
```ini
[junoon_servers]
server1 ansible_host=IP_ADDRESS ansible_user=ubuntu ansible_ssh_private_key_file=/path/to/private/key
server2 ansible_host=IP_ADDRESS ansible_user=ubuntu ansible_ssh_private_key_file=/path/to/private/key
```

### 3. Create SSH Key and Set Permissions
```bash
mkdir ~/keys
cd ~/keys/
ssh-keygen -t rsa -b 4096 -f terra-key-ansible.pem
chmod 400 terra-key-ansible.pem
```

## Ansible Commands
### 1. Check Server Connectivity
```bash
ansible junoon_servers -m ping
```
### 2. Execute Commands on Servers
```bash
ansible server1 -a "free -h"  # Check memory usage
ansible junoon_servers -a "df -h"  # Check disk space
```

### 3. Install Nginx Using Ansible
Create a playbook **install_nginx.yml**:
```yaml
- name: Install Nginx
  hosts: junoon_servers
  become: yes
  tasks:
    - name: Update package cache
      apt:
        update_cache: yes
    - name: Install Nginx
      apt:
        name: nginx
        state: present
```
Run the playbook:
```bash
ansible-playbook install_nginx.yml
```

### 4. Install Docker Using Ansible
Create a playbook **install_docker.yml**:
```yaml
- name: Install Docker
  hosts: junoon_servers
  become: yes
  tasks:
    - name: Install dependencies
      apt:
        name:
          - apt-transport-https
          - ca-certificates
          - curl
          - software-properties-common
        state: present
    - name: Add Docker GPG key
      shell: curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    - name: Add Docker repository
      shell: add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
    - name: Install Docker
      apt:
        name: docker-ce
        state: present
```
Run the playbook:
```bash
ansible-playbook install_docker.yml
```
Verify Docker installation:
```bash
ansible server1 -a "docker --version"
```

## Inventory Management
To manage different environments, create an **inventories/** directory:
```bash
mkdir inventories
cd inventories/
vim prd  # Production Inventory
vim dev  # Development Inventory
```
Example content for `prd`:
```ini
[junoon_servers]
server1 ansible_host=IP_ADDRESS ansible_user=ubuntu ansible_ssh_private_key_file=/path/to/private/key
server2 ansible_host=IP_ADDRESS ansible_user=ubuntu ansible_ssh_private_key_file=/path/to/private/key
```
Run playbook with specific inventory:
```bash
ansible-playbook -i ../inventories/prd install_docker.yml
```

## Cloning the Repository
```bash
git clone https://github.com/LondheShubham153/terraform-ansible.git
mv playbooks/ terraform-ansible/
```

## Conclusion
This setup helps in automating infrastructure provisioning using Terraform and Ansible. You can extend it further with more configurations and optimizations.

---
**Maintainer:** [Shubham Londhe](https://github.com/LondheShubham153)
