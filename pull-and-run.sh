#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
IMAGE_NAME="fhatikaadr/tailore-integration-service"
CONTAINER_NAME="tailore-service"
PORT=5000

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Tailore Integration Service Deployment${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# 1. Check if Docker is installed
echo -e "${YELLOW}[1/7] Checking Docker installation...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker is not installed. Please install Docker first.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker is installed${NC}"
echo ""

# 2. Check if Docker is running
echo -e "${YELLOW}[2/7] Checking Docker service...${NC}"
if ! docker info &> /dev/null; then
    echo -e "${RED}Docker is not running. Please start Docker service.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker is running${NC}"
echo ""

# 3. Setup environment file
echo -e "${YELLOW}[3/7] Setting up environment...${NC}"
if [ ! -f .env ]; then
    if [ -f .env.example ]; then
        cp .env.example .env
        echo -e "${GREEN}✓ Created .env from .env.example${NC}"
    else
        echo -e "${YELLOW}! No .env.example found, using defaults${NC}"
    fi
else
    echo -e "${GREEN}✓ .env already exists${NC}"
fi
echo ""

# 4. Stop and remove old container
echo -e "${YELLOW}[4/7] Removing old container...${NC}"
if docker ps -a | grep -q $CONTAINER_NAME; then
    docker stop $CONTAINER_NAME 2>/dev/null
    docker rm $CONTAINER_NAME 2>/dev/null
    echo -e "${GREEN}✓ Old container removed${NC}"
else
    echo -e "${YELLOW}! No existing container found${NC}"
fi
echo ""

# 5. Pull latest image
echo -e "${YELLOW}[5/7] Pulling latest image from Docker Hub...${NC}"
if docker pull $IMAGE_NAME:latest; then
    echo -e "${GREEN}✓ Image pulled successfully${NC}"
else
    echo -e "${RED}✗ Failed to pull image${NC}"
    exit 1
fi
echo ""

# 6. Run new container
echo -e "${YELLOW}[6/7] Starting new container...${NC}"
docker run -d \
    --name $CONTAINER_NAME \
    --restart unless-stopped \
    -p $PORT:5000 \
    --env-file .env \
    $IMAGE_NAME:latest

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Container started successfully${NC}"
else
    echo -e "${RED}✗ Failed to start container${NC}"
    exit 1
fi
echo ""

# 7. Test application status
echo -e "${YELLOW}[7/7] Testing application status...${NC}"
sleep 3

# Check if container is running
if docker ps | grep -q $CONTAINER_NAME; then
    echo -e "${GREEN}✓ Container is running${NC}"
    
    # Check application health
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$PORT)
    if [ "$HTTP_CODE" -eq 200 ]; then
        echo -e "${GREEN}✓ Application is responding (HTTP $HTTP_CODE)${NC}"
    else
        echo -e "${YELLOW}! Application responded with HTTP $HTTP_CODE${NC}"
    fi
else
    echo -e "${RED}✗ Container is not running${NC}"
    echo -e "${YELLOW}Container logs:${NC}"
    docker logs $CONTAINER_NAME
    exit 1
fi
echo ""

# Display container info
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Deployment Summary${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "Container Name: ${GREEN}$CONTAINER_NAME${NC}"
echo -e "Image: ${GREEN}$IMAGE_NAME:latest${NC}"
echo -e "Port: ${GREEN}$PORT${NC}"
echo -e "Status: ${GREEN}Running${NC}"
echo -e "URL: ${GREEN}http://localhost:$PORT${NC}"
echo ""
echo -e "${GREEN}To view logs: ${NC}docker logs -f $CONTAINER_NAME"
echo -e "${GREEN}To stop: ${NC}docker stop $CONTAINER_NAME"
echo -e "${GREEN}To restart: ${NC}docker restart $CONTAINER_NAME"
echo ""
echo -e "${GREEN}✓ Deployment completed successfully!${NC}"
