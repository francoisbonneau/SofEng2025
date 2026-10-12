#include <HelloProjConfig.h>
#include <basic/message.h>
#include <iostream>

std::string get_message()
{
    return "Hello World!";
}

std::string get_version()
{
    return std::to_string( HelloProj_VERSION_MAJOR ) + "."
           + std::to_string( HelloProj_VERSION_MINOR );
}

void hello_world()
{
    std::cout << get_message() << std::endl;
}

void print_version()
{
    std::cout << "project version is " << get_version() << std::endl;
}
