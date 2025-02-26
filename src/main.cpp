#include "include/token.hpp"
#include "include/lexer.hpp"
#include "include/parser.hpp"
#include "include/print.hpp"

using namespace std;

int main(void) {
    string input = "ls -la '/usr/bin'";
    vector<Token> tokens = tokenize(input);
    print_tokens(tokens);
    Command command = parse(tokens);
    print_command(command);
}