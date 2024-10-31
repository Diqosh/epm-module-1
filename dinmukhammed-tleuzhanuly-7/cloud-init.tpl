#cloud-config

# Commands to run once the instance is booted
runcmd:
  - sudo su
  - sudo apt-get update
  - sudo apt-get upgrade -y
  - sudo wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
  - sudo dpkg -i packages-microsoft-prod.deb
  - sudo apt-get update
  - sudo apt-get install -y blobfuse fuse
  - sudo mkdir -p /mnt/resource/blobfusetmp
  - sudo chown adminuser /mnt/resource/blobfusetmp
  - sudo touch /etc/blobfuse.cfg
  - echo "accountName ${storage_account_name}" | sudo tee -a /etc/blobfuse.cfg
  - echo "accountKey ${storage_account_key}" | sudo tee -a /etc/blobfuse.cfg
  - echo "containerName ${container_name}" | sudo tee -a /etc/blobfuse.cfg
  - echo "authType Key" | sudo tee -a /etc/blobfuse.cfg
  - sudo chmod 600 /etc/blobfuse.cfg
  - sudo mkdir -p /mnt/mycontainer
  - sudo blobfuse /mnt/mycontainer --tmp-path=/mnt/resource/blobfusetmp --config-file=/etc/blobfuse.cfg -o attr_timeout=240 -o entry_timeout=240 -o negative_timeout=120 -o allow_other

# # Write the systemd service file
# write_files:
#   - path: /etc/systemd/system/blobfuse-mount.service
#     permissions: '0644'
#     owner: 'root:root'
#     content: |
#       [Unit]
#       Description=Mount Blobfuse on boot
#       After=network-online.target

#       [Service]
#       Type=simple
#       ExecStart=/usr/bin/blobfuse /mnt/mycontainer --tmp-path=/mnt/resource/blobfusetmp --config-file=/etc/blobfuse.cfg -o attr_timeout=240 -o entry_timeout=240 -o negative_timeout=120 -o allow_other
#       ExecStop=/bin/umount /mnt/mycontainer
#       RemainAfterExit=yes
#       Restart=always

#       [Install]
#       WantedBy=multi-user.target

# # Commands to run after writing the files
# runcmd:
#   - sudo systemctl daemon-reload
#   - sudo systemctl enable blobfuse-mount
#   - sudo systemctl start blobfuse-mount
