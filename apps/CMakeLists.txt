# Executable greet, built from greet.cpp and using the library greeter
add_executable(greet greet.cpp)
target_link_libraries(greet PRIVATE greeter)
install(TARGETS greet DESTINATION bin)
