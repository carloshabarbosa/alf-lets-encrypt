Content-Type: multipart/mixed; boundary="//"
MIME-Version: 1.0

--//
Content-Type: text/cloud-config; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="cloud-config.txt"

#cloud-config
cloud_final_modules:
- [scripts-user, always]

--//
Content-Type: text/x-shellscript; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="userdata.txt"

#!/usr/bin/env bash

yum update -y
amazon-linux-extras install docker
service docker start
usermod -a -G docker ec2-user

curl -L https://github.com/docker/compose/releases/download/1.20.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
source /.nvm/nvm.sh
nvm install node
ln -s /usr/bin/nodejs /usr/bin/node
node -e "console.log('Running Node.js ' + process.version)"
npm install
# remove volume which create a permission denied issue
sed -i '\|logs/postgres|d' ./docker-compose.yml

# put in auto start
# cp ./scripts/alfresco /etc/init.d
--//
