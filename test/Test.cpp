#include "../cpp/include/jbuff/jbuff.hpp"

#include <iostream>
using namespace std;

int main() {
    JBuffReader reader("helloworld.jbuff");

    cout << "version: " << reader.version  << endl;
    cout << "magic: " << reader.magic << endl;
    cout << "data_length_raw: " << reader.data_length_raw << endl;
    cout << "data_length_zip: " << reader.data_length_zip << endl;
    cout << "data_payload: " << reader.data_payload << endl;
    
    return 0;
}