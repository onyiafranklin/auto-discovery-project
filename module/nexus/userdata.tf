locals {
  userdata = <<EOF
#!/bin/bash
set -e

# Install SSM Agent and Session Manager Plugin
sudo yum install -y dnf || true
sudo dnf install -y https://s3.eu-west-2.amazonaws.com/amazon-ssm-eu-west-2/latest/linux_amd64/amazon-ssm-agent.rpm
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm" -o "session-manager-plugin.rpm"
sudo yum install -y session-manager-plugin.rpm

# Update system and install dependencies
sudo yum update -y
sudo yum install -y wget java-1.8.0-openjdk unzip

# Create application directories
sudo mkdir -p /app/sonatype-work
cd /app

# Download and extract Nexus
sudo wget http://download.sonatype.com/nexus/3/nexus-3.23.0-03-unix.tar.gz
sudo tar -xvf nexus-3.23.0-03-unix.tar.gz
sudo mv nexus-3.23.0-03 nexus

# Create nexus user (non-interactive)
id nexus &>/dev/null || sudo useradd --system --home /app/nexus --shell /bin/bash nexus

# Set permissions
sudo chown -R nexus:nexus /app/nexus
sudo chown -R nexus:nexus /app/sonatype-work
sudo chmod +x /app/nexus/bin/nexus

# Configure Nexus to run as nexus user
echo 'run_as_user="nexus"' | sudo tee /app/nexus/bin/nexus.rc

# Adjust JVM options for lower memory usage
sudo sed -i '2s/-Xms2703m/-Xms512m/' /app/nexus/bin/nexus.vmoptions
sudo sed -i '3s/-Xmx2703m/-Xmx512m/' /app/nexus/bin/nexus.vmoptions
sudo sed -i '4s/-XX:MaxDirectMemorySize=2703m/-XX:MaxDirectMemorySize=512m/' /app/nexus/bin/nexus.vmoptions

# Create systemd service for Nexus (use /bin/sh for shell script)
sudo tee /etc/systemd/system/nexus.service > /dev/null <<EOT
[Unit]
Description=nexus service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
User=nexus
Group=nexus
ExecStart=/bin/sh /app/nexus/bin/nexus start
ExecStop=/bin/sh /app/nexus/bin/nexus stop
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOT

# Enable and start Nexus service
sudo systemctl daemon-reload
sudo systemctl enable nexus
sudo systemctl start nexus

# Set hostname
sudo hostnamectl set-hostname Nexus

#curl -Ls https://download.newrelic.com/install/newrelic-cli/scripts/install.sh | bash && sudo NEW_RELIC_API_KEY=${var.nr-key} NEW_RELIC_ACCOUNT_ID=${var.nr-id} /usr/local/bin/newrelic install -y
EOF
}