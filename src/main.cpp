#include <iostream>
#include <vector>
#include "include/token.hpp"
#include "include/lexer.hpp"

using namespace std;

int main(void) {
    string input = "this is a test string to test my lexer ' \" \\n | !";
    vector<Token> tokens = tokenize(input);
    print_tokens(tokens);
}