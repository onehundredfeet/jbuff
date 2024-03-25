#include <jbuff/jbuff.hpp>
#include <rapidjson/reader.h>
#include <iostream>
#include <fstream>

using namespace rapidjson;
using namespace std;

enum class Node : int
{
    NONE,
    UNKNOWN,
    BUFFERS,
    VIEWS,
    MAGIC,
    DATA_LENGTH_RAW,
    DATA_LENGTH_ZIP,
    DATA_PAYLOAD,
    VERSION,
    DOM
};

struct JBuffReaderHandler : public BaseReaderHandler<UTF8<>, JBuffReaderHandler>
{
    JBuffReader &Reader;
    Node _node = Node::NONE;
    int _depth = 0;
    JBuffReaderHandler(JBuffReader &Reader) : Reader(Reader) {}



    bool Null()
    {
        cout << "Null()" << endl;
        return true;
    }
    bool Bool(bool b)
    {
        cout << "Bool(" << boolalpha << b << ")" << endl;
        return true;
    }
    bool Int(int i)
    {
        cout << "Int(" << i << ")" << endl;
        return true;
    }
    bool Uint(unsigned u)
    {
        cout << "Uint(" << u << ")" << endl;
        return true;
    }
    bool Int64(int64_t i)
    {
        cout << "Int64(" << i << ")" << endl;
        return true;
    }
    bool Uint64(uint64_t u)
    {
        cout << "Uint64(" << u << ")" << endl;
        return true;
    }
    bool Double(double d)
    {
        cout << "Double(" << d << ")" << endl;
        return true;
    }
    bool String(const char *str, SizeType length, bool copy)
    {
        if (_depth == 1) {

        switch(_node)
        {
            case Node::VERSION:
                Reader.version = std::string(str, length);
                break;
            case Node::MAGIC:
                Reader.magic = std::string(str, length);
                break;
            case Node::DATA_PAYLOAD:
                Reader.data_payload = std::string(str, length);
                break;
            case Node::DATA_LENGTH_RAW:
                sscanf(str, "%d", &Reader.data_length_raw);
                break;
            case Node::DATA_LENGTH_ZIP:
                sscanf(str, "%d", &Reader.data_length_zip);
                break;
            default:
                break;
        }
        } else {
            cout << "String(" << str << ", " << length << ", " << boolalpha << copy << ")" << endl;

        }
        return true;
    }
    bool StartObject()
    {
        _depth++;
        cout << "StartObject(" << _depth << ")" << endl;
        return true;
    }

    //{"buffers":[{"desc":"","length":11,"name":"buffer_helloworld","offset":0,"type":""}],"data_length_raw":11,"data_length_zip":-1,"data_payload":"SGVsbG8gV29ybGQ=","dom":{"name":"helloworld","something":"nope"},"magic":"JBUFF","version":"1.0.0","views":[{"buffer":"buffer_helloworld","count":11,"desc":"","name":"view_helloworld","offset":0,"size":1,"stride":1,"type":""}]}
    bool Key(const char *str, SizeType length, bool copy)
    {
        if (_depth == 1)
        {
            if (strncmp(str, "buffers", length) == 0)
            {
                _node = Node::BUFFERS;
                cout << "buffers" << endl;
            }
            else if (strncmp(str, "dom", length) == 0)
            {
                _node = Node::DOM;
                cout << "dom" << endl;
            }
            else if (strncmp(str, "views", length) == 0)
            {
                _node = Node::VIEWS;
                cout << "views" << endl;
            }
            else if (strncmp(str, "magic", length) == 0)
            {
                _node = Node::MAGIC;
                cout << "magic" << endl;
            }
            else if (strncmp(str, "data_length_raw", length) == 0)
            {
                _node = Node::DATA_LENGTH_RAW;
                cout << "data_length_raw" << endl;
            }
            else if (strncmp(str, "data_length_zip", length) == 0)
            {
                _node = Node::DATA_LENGTH_ZIP;
                cout << "data_length_zip" << endl;
            }
            else if (strncmp(str, "data_payload", length) == 0)
            {
                _node = Node::DATA_PAYLOAD;
                cout << "data_payload" << endl;
            }
            else if (strncmp(str, "version", length) == 0)
            {
                _node = Node::VERSION;
                cout << "version" << endl;
            }
            else
            {
                _node = Node::UNKNOWN;
                cout << "Unknown root(" << str << ", " << length << ", " << boolalpha << copy << ")" << endl;
            }
        }
        else
        {
            cout << "Key(" << str << ", " << length << ", " << boolalpha << copy << ")" << endl;
        }
        return true;
    }
    bool EndObject(SizeType memberCount)
    {
        _depth--;
        cout << "EndObject(" << _depth << "," << memberCount << ")" << endl;
        return true;
    }
    bool StartArray()
    {
        cout << "StartArray()" << endl;
        return true;
    }
    bool EndArray(SizeType elementCount)
    {
        cout << "EndArray(" << elementCount << ")" << endl;
        return true;
    }
};

JBuffReader::JBuffReader(const std::string &path)
{
    std::ifstream fin(path, std::ifstream::in);
    // get pointer to associated buffer object
    std::filebuf &pbuf = *fin.rdbuf();
    // get file size using buffer's members
    std::size_t size = pbuf.pubseekoff(0, fin.end, fin.in);
    pbuf.pubseekpos(0, fin.in);
    // allocate memory to contain file data
    char *json = new char[size + 1];
    // get file data
    pbuf.sgetn(json, size);
    json[size] = '\0';
    fin.close();

    JBuffReaderHandler handler(*this);
    Reader reader;
    StringStream ss(json);
    reader.Parse(ss, handler);
}
JBuffReader::~JBuffReader()
{
}
