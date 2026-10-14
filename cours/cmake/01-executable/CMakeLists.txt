# ETAPE 1 : un seul executable
cmake_minimum_required(VERSION 3.16)

# Project name
project(Greeter LANGUAGES CXX)

# C++ standard used by all the targets
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Pass information known by CMake (system, compiler...) to the source code:
# generates greeter_config.h in the build folder
configure_file(cmake/greeter_config.h.in greeter_config.h)

# Executable greet, built from greet.cpp
add_executable(greet greet.cpp)

# greeter_config.h is generated in the build folder: tell the compiler to look there
target_include_directories(greet PRIVATE "${PROJECT_BINARY_DIR}")
