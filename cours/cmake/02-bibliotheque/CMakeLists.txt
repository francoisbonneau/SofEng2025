# ETAPE 2 : une bibliotheque et un executable
cmake_minimum_required(VERSION 3.16)

# Project name
project(Greeter LANGUAGES CXX)

# C++ standard used by all the targets
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Pass information known by CMake (system, compiler...) to the source code:
# generates greeter_config.h in the build folder
configure_file(cmake/greeter_config.h.in greeter_config.h)

# Libraries (one folder per library in src/)
add_subdirectory(src/greeter)                       # NOUVEAU

# Executables
# Options, to change with: cmake -DGREETER_BUILD_APPS=OFF ...
option(GREETER_BUILD_APPS "Compile apps" ON)        # NOUVEAU
if(GREETER_BUILD_APPS)                              # NOUVEAU
    message(STATUS "Configuring Greeter with executables")
    add_subdirectory(apps)                          # NOUVEAU
endif()
