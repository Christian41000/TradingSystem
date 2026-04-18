cmake_minimum_required(VERSION 3.15)
project(TradingBackend VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Source files
set(SOURCES
    Sources/Account.cpp
    Sources/trading_bridge.cpp
)

# Header files
set(HEADERS
    Include/Order.hpp
    Include/Position.hpp
    Include/Account.hpp
    Include/trading_bridge.h
)

# Create shared library for Swift interop
add_library(TradingBackend SHARED ${SOURCES} ${HEADERS})

target_include_directories(TradingBackend PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/Include
)

# Set library properties
set_target_properties(TradingBackend PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
    ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)

# Installation rules
install(TARGETS TradingBackend
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(FILES ${HEADERS} DESTINATION include)
