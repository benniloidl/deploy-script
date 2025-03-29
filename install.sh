#!/bin/bash

# Install Required Packages
echo "Installing Required Packages.."
sudo apt update && sudo apt install -y git nodejs npm
sudo npm install -g pm2

# Generate SSH Key (if none exists already)
if [[ ! -f "$file" ]] then
    echo "Generating SSH Key.."
    ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa
fi

# Prompt the User to Add the SSH Key to GitHub
echo "COPY FROM HERE >"
cat ~/.ssh/id_rsa.pub
echo "< COPY TO HERE"
echo "Copy the output and add it to GitHub → Settings → SSH and GPG keys → New SSH Key. Press Enter to continue (or Ctrl+C to exit).."

# Clone Your Repository
read -p "Enter the Name of your GitHub User: " github_username
read -p "Enter the Name of your GitHub Repository: " github_repository
echo "Cloning Your Repository.."
cd /var/www
git clone git@github.com:$github_username/$github_repository.git nextjs-app
echo "Clone successful!"
cd nextjs-app

# Install Dependencies & Build
echo "Installing Depencendies.."
npm install
echo "Building your App.."
npm run build

# Start the Application with PM2
echo "Starting the App with PM2.."
pm2 start npm --name "nextjs-app" -- start
pm2 save
pm2 startup

# Create the Deploy Script
echo "Creating the Deploy Script.."
cat > deploy.sh <<- "EOF"
#!/bin/bash
cd /var/www/nextjs-app
git pull origin main
npm install
npm run build
pm2 restart nextjs-app
EOF
chmod +x deploy.sh

# Running the Deploy Script
echo "Running the Deploy Script.."
bash ./deploy.sh
echo "Successfully Installed and Deployed Your GitHub Repository!"
