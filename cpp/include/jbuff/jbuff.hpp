#pragma once


#include <string>

class JBuffReader {
public:
    std::string version;
    std::string magic;
    int data_length_raw;
    int data_length_zip;
    std::string data_payload;
    
    JBuffReader(const std::string &path);
    ~JBuffReader();

};