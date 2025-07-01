#!/bin/bash

# setup-env.sh - Create .env file with current user values for devenv

set -e

ENV_FILE=".env"
BACKUP_SUFFIX=".backup.$(date +%Y%m%d_%H%M%S)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_color() {
    printf "${1}${2}${NC}\n"
}

print_color $BLUE "🐳 Development Environment Setup for User Permissions"
print_color $BLUE "====================================================="

# Get current user info
USER_UID=$(id -u)
USER_GID=$(id -g)
USER_NAME=$(whoami)
GROUP_NAME=$(id -gn)

print_color $GREEN "Current user information:"
echo "  User: $USER_NAME"
echo "  UID:  $USER_UID"
echo "  GID:  $USER_GID"
echo "  Group: $GROUP_NAME"
echo ""

# Check if .env already exists
if [ -f "$ENV_FILE" ]; then
    print_color $YELLOW "⚠️  Existing $ENV_FILE found!"
    
    # Check if it already has the correct values
    if grep -q "USER_UID=$USER_UID" "$ENV_FILE" && grep -q "USER_GID=$USER_GID" "$ENV_FILE"; then
        print_color $GREEN "✅ $ENV_FILE already has correct values. Nothing to do!"
        exit 0
    fi
    
    # Create backup
    BACKUP_FILE="${ENV_FILE}${BACKUP_SUFFIX}"
    cp "$ENV_FILE" "$BACKUP_FILE"
    print_color $YELLOW "📁 Backed up existing $ENV_FILE to $BACKUP_FILE"
fi

# Create new .env file
print_color $BLUE "📝 Creating new $ENV_FILE..."

cat > "$ENV_FILE" << EOF
# Docker user permissions matching for devenv
# Generated on $(date)
# Host user: $USER_NAME ($GROUP_NAME)

USER_UID=$USER_UID
USER_GID=$USER_GID

# Development environment variables
COMPOSE_PROJECT_NAME=devenv
DOCKER_BUILDKIT=1

# Go environment
GOPROXY=https://proxy.golang.org,direct
GO111MODULE=on

# Node.js environment  
NODE_ENV=development
NPM_CONFIG_UPDATE_NOTIFIER=false
EOF

print_color $GREEN "✅ Created $ENV_FILE with the following content:"
echo "----------------------------------------"
cat "$ENV_FILE"
echo "----------------------------------------"
echo ""

# Validate docker-compose files
if [ -f "docker-compose.yaml" ] || [ -f "docker-compose.yml" ]; then
    COMPOSE_FILE=$([ -f "docker-compose.yaml" ] && echo "docker-compose.yaml" || echo "docker-compose.yml")
    print_color $GREEN "📋 Found $COMPOSE_FILE"
    
    # Check if the compose file uses the USER_UID/USER_GID variables
    if grep -q "USER_UID\|USER_GID" "$COMPOSE_FILE"; then
        print_color $GREEN "✅ $COMPOSE_FILE is configured to use UID/GID variables"
    else
        print_color $YELLOW "⚠️  $COMPOSE_FILE doesn't seem to use USER_UID/USER_GID variables"
        print_color $YELLOW "   You may need to update your compose file"
    fi
else
    print_color $RED "⚠️  Warning: No docker-compose.yaml found!"
    print_color $YELLOW "   Make sure you're in the right directory."
fi

# Create workspace directory if it doesn't exist
if [ ! -d "workspace" ]; then
    print_color $BLUE "📁 Creating workspace directory..."
    mkdir -p workspace
    print_color $GREEN "✅ Created workspace directory"
fi

# Provide next steps
echo ""
print_color $BLUE "📋 Next steps:"
echo "1. 🔨 Rebuild your container:"
echo "   docker-compose build --no-cache"
echo ""
echo "2. 🚀 Start the development environment:"
echo "   docker-compose up -d"
echo ""
echo "3. 🔍 Verify permissions are working:"
echo "   touch workspace/test-$(date +%s).txt"
echo "   docker exec devenv ls -la /workspace/"
echo ""
echo "4. 🖥️  Access your development environment:"
echo "   docker exec -it devenv bash"
echo ""
echo "5. 🧹 Clean up test files:"
echo "   rm workspace/test-*.txt"

print_color $GREEN "✨ Environment setup complete!"

# Optional: Ask if user wants to run the rebuild automatically
echo ""
read -p "Would you like to rebuild the container now? (y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_color $BLUE "🔨 Rebuilding container..."
    docker-compose build --no-cache
    print_color $GREEN "✅ Container rebuilt successfully!"
    
    read -p "Would you like to start the development environment? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_color $BLUE "🚀 Starting development environment..."
        docker-compose up -d
        print_color $GREEN "✅ Development environment started successfully!"
        
        print_color $BLUE "🖥️  You can now access your environment with:"
        print_color $BLUE "   docker exec -it devenv bash"
    fi
fi
