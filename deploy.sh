#!/bin/bash

# Clone NewsApp from Github
NEWSAPP_URL="https://github.com/ostenlun/NewsApp.git"
if [ ! -d "NewsApp" ]; then
    echo "Cloning NewsApp repository..."
    git clone $NEWSAPP_URL
    
    # Check the exit status of the last command
    if [ $? -ne 0 ]; then
        echo "Failed to clone repository. Exiting."
        exit 1
    fi
else
    echo "NewsApp repository already exists."
fi

# Clone MockStorage from Github
MOCKSTORAGE_URL="https://github.com/ostenlun/MockStorage.git"
if [ ! -d "MockStorage" ]; then
    echo "Cloning MockStorage repository..."
    git clone $MOCKSTORAGE_URL

    # Check the exit status of the last command
    if [ $? -ne 0 ]; then
        echo "Failed to clone repository. Exiting."
        exit 1
    fi
else
    echo "MockStorage repository already exists."
fi

# Build the NewsApp Docker image using Maven
echo "Building NewsApp Docker image with Maven..."
# mvn clean package docker:build

cd NewsApp
mvn clean install -Pdocker

if [ $? -ne 0 ]; then
    echo "NewsApp Maven build failed. Exiting."
    exit 1
fi
echo "NewsApp Docker image built successfully."

cd ..
cd MockStorage
mvn clean install -Pdocker

if [ $? -ne 0 ]; then
    echo "Mock Storage Maven build failed. Exiting."
    exit 1
fi
echo "NewsApp Docker image built successfully."

cd ..

# Start minikube if not running
if ! minikube status > /dev/null 2>&1; then
    echo "Starting minikube..."
    minikube start
else
    echo "Minikube is already running."
fi

# Load the NewsApp Docker image into minikube
echo "Loading NewsApp Docker image into minikube..."
NEWSAPP_IMAGE_TAR="NewsApp/target/newsapp-1.000.tar.gz"
minikube image load $NEWSAPP_IMAGE_TAR
if [ $? -ne 0 ]; then
    echo "Failed to load NewsApp Docker image into minikube. Exiting."
    exit 1
fi
echo "NewsApp Docker image loaded into minikube successfully."

# Load the MockStorage Docker image into minikube
echo "Loading MockStorage Docker image into minikube..."
MOCKSTORAGE_IMAGE_TAR="MockStorage/target/mockstorage-1.000.tar.gz"
minikube image load $MOCKSTORAGE_IMAGE_TAR
if [ $? -ne 0 ]; then
    echo "Failed to load NewsApp Docker image into minikube. Exiting."
    exit 1
fi
echo "NewsApp Docker image loaded into minikube successfully."

# Deploy the application to minikube using kubectl
echo "Deploying application to minikube..."
kubectl apply -f k8s/deployment.yaml
if [ $? -ne 0 ]; then
    echo "Failed to deploy application. Exiting."
    exit 1
fi
echo "Application deployed successfully."

# Expose the service
echo "Exposing the service..."
kubectl apply -f k8s/service.yaml
if [ $? -ne 0 ]; then
    echo "Failed to expose the service. Exiting."
    exit 1
fi
echo "Service exposed successfully."

# Get the URL of the service
SERVICE_URL=$(minikube service newsapp-service --url)
echo "Application is accessible at: $SERVICE_URL"
# End of script
