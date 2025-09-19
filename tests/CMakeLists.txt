cmake_minimum_required(VERSION 3.10)

if(NOT TARGET basic)
	# set the project name
	project(HelloProjTest)
	find_package(HelloProj)
	enable_testing()
endif()

#add the executable target named HelloWorld
add_executable(test_hello test-hello.cpp)
target_link_libraries(test_hello PRIVATE basic)
add_test(NAME test_hello COMMAND test_hello)


#add the executable target named HelloWorld
add_executable(test_version test-version.cpp)
target_link_libraries(test_version PRIVATE basic)
add_test(NAME test_version COMMAND test_version)
