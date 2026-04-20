#!/bin/bash

# Set colors for output
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
RESET="\033[0m"

# Function to compile C++ backend using CMake
compile_cpp_backend() {
    echo -e "${YELLOW}Compiling C++ backend...${RESET}"
    mkdir -p build
    cd build || exit
    cmake ..
    if cmake --build .; then
        echo -e "${GREEN}C++ backend compiled successfully.${RESET}"
    else
        echo -e "${RED}C++ backend compilation failed.${RESET}"
        exit 1
    fi
    cd ..
}

# Function to compile and run SwiftUI frontend
run_swiftui_frontend() {
    echo -e "${YELLOW}Running SwiftUI frontend...${RESET}"
    if xcodebuild -scheme YourSwiftUIScheme -sdk macosx; then
        echo -e "${GREEN}SwiftUI frontend compiled successfully.${RESET}"
        open .build/YourAppBundle.app
    else
        echo -e "${RED}SwiftUI frontend compilation failed.${RESET}"
        exit 1
    fi
}

# Main script execution
compile_cpp_backend
run_swiftui_frontend
