#include <basic/message.h>
#include <iostream>

int main()
{
    const std::string expected = "1.0";
    if( get_version() != expected )
    {
        std::cerr << "Wrong version: got \"" << get_version()
                  << "\", expected \"" << expected << "\"" << std::endl;
        return 1;
    }
    return 0;
}
