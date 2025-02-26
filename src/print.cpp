#include "include/print.hpp"

void print_tokens(vector<Token> input) {
    for (int i = 0; i < (int) input.size(); i++)
    {
        string out;
        switch (input[i].type) {
        case TokenType::DoubleQuote: 
            out = "DOUBLEQUOTE";
            break;

        case TokenType::SingleQuote: 
            out = "SINGLEQUOTE";
            break;

        case TokenType::Bang: 
            out = "BANG";
            break;

        case TokenType::Pipe: 
            out = "PIPE";
            break;

        case TokenType::Space: 
            out = "SPACE";
            break;

        case TokenType::EscapedCharacter: 
            out = "ESCAPEDCHARACTER";
            break;

        case TokenType::StringLiteral: 
            out = "STRINGLITERAL";
            break;
        // printf("%i: %s; %s", i, input[i].type, input[i].val);
        // std::cout << i << input[i].type << input[i].val << std::endl;
        }

        string val = input[i].val;
        if (val == "") {
            val = "None";
        }

        // printf("{%s: %s}\n", out, val);
        cout << "{" << out << ": " << val << "}" << std::endl;
    }
}

void print_command(Command command) {
    string args_s = "[";
    for (int i = 0; i < (int) command.args.size(); i++) {
        args_s += command.args[i];

        if (i != (int) command.args.size() - 1) {
            args_s += ", ";
        }
    }

    args_s += "]";

    cout << "{" << command.command << ", " << args_s << "}" << endl;
}