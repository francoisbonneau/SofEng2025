#include <basic/message.h>
#include <iostream>

int main()
{
    const std::string expected = "Hello World!";
    if( get_message() != expected )
    {
        std::cerr << "Wrong message: got \"" << get_message()
                  << "\", expected \"" << expected << "\"" << std::endl;
        return 1; // a non-zero return code means the test FAILED
    }
    return 0; // zero means the test PASSED
}
