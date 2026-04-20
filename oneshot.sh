#!/bin/bash

# 🚀 Trading System - One-Shot Build & Run Script
# This script compiles the C++ backend and runs the SwiftUI frontend

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

# Main build process
main() {
    print_header "🚀 Trading System Build"
    
    # Step 1: Verify project structure
    print_info "Verifying project structure..."
    if [ ! -f "Frontend/TradingApp/main.swift" ]; then
        print_error "Frontend/TradingApp/main.swift not found!"
        exit 1
    fi
    print_success "Project structure verified"
    
    # Step 2: Compile C++ Backend
    print_info "Compiling C++ Backend..."
    cd Backend
    mkdir -p build
    cd build
    cmake .. || { print_error "CMake configuration failed"; exit 1; }
    make || { print_error "C++ compilation failed"; exit 1; }
    cd ../..
    print_success "C++ Backend compiled"
    
    # Step 3: Compile and run SwiftUI Frontend
    print_info "Compiling SwiftUI Frontend..."
    swiftc -o TradingApp \
        -framework SwiftUI \
        -framework Foundation \
        -framework AppKit \
        Frontend/TradingApp/main.swift || { print_error "SwiftUI compilation failed"; exit 1; }
    print_success "SwiftUI Frontend compiled"
    
    # Step 4: Launch the application
    print_info "Launching Trading System..."
    ./TradingApp &
    
    print_header "✨ Build Complete!"
    echo ""
}

# Run main function
main