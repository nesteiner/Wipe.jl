#include "./termcolor.hpp"
#include <sstream>
#include <string>
#include <map>
#include <stdlib.h>
#include <string.h>
using std::stringstream;
using std::map;

typedef std::ostream & (* ftype)(std::ostream &);

map<std::string, ftype> color_map = {
    {"red", termcolor::red},
    {"green", termcolor::green},
    {"yellow", termcolor::yellow},
    {"blue", termcolor::blue},
    {"magenta", termcolor::magenta},
    {"cyan", termcolor::cyan},
    {"white", termcolor::white},
    {"grey", termcolor::grey}
};

map<std::string, ftype> backgroun_map = {
    {"red", termcolor::on_red},
    {"green", termcolor::on_green},
    {"yellow", termcolor::on_yellow},
    {"blue", termcolor::on_blue},
    {"magenta", termcolor::on_magenta},
    {"cyan", termcolor::on_cyan},
    {"white", termcolor::on_white},
    {"grey", termcolor::on_grey}
};

map<std::string, ftype> style_map = {
    {"bold", termcolor::bold},
    {"underline", termcolor::underline},
    {"italic", termcolor::italic}
};

const char * color(const char * s_color, const char * string) {
    ftype color = color_map[s_color];

    stringstream stream;

    if (color == nullptr) {
        stream << string;
    } else {
        stream << termcolor::colorize << color << string << termcolor::reset;
    }
    
    std::string result = stream.str();

    // char * buffer = new char[result.size() + 1];
    char * buffer = (char *) malloc(sizeof(char) * (result.size() + 1));
    std::copy(result.begin(), result.end(), buffer);
    buffer[result.size()] = '\0';

    return buffer;
}   

const char * background(const char * s_color, const char * string) {
    ftype color = backgroun_map[s_color];       

    stringstream stream;

    if (color == nullptr) {
        stream << string;
    } else {
        stream << termcolor::colorize << color << string << termcolor::reset;
    }
    
    std::string result = stream.str();

    // char * buffer = new char[result.size() + 1];
    char * buffer = (char *) malloc(sizeof(char) * (result.size() + 1));
    std::copy(result.begin(), result.end(), buffer);
    buffer[result.size()] = '\0';

    return buffer;
}

const char * style(const char * s_style, const char * string) {
    ftype style = style_map[s_style];

    stringstream stream;

    if (style == nullptr) {
        stream << string;
    } else {
        stream << termcolor::colorize << style << string << termcolor::reset;
    }
    
    std::string result = stream.str();

    char * buffer = (char *) malloc(sizeof(char) * (result.size() + 1));
    std::copy(result.begin(), result.end(), buffer);
    buffer[result.size()] = '\0';

    return buffer;
}
/* 
int main() {
    char * c_string = "red";
    ftype f = color_map[c_string];
    std::cout << (f == nullptr) << std::endl;
    const char * result = color(c_string, "hello");
    std::cout << result << std::endl;   
    free((void *) result);
    return 0;
} */