#include "include/lexer.hpp"
using namespace std;

Token create_token(TokenType type, string input) {
    Token token;
    token.type = type;
    token.val = input;
    return token;
}

vector<Token> tokenize(string input) {
    vector<Token> output;
    int input_len = (int) input.length();
    for (int i = 0; i < input_len; i++) {
        switch(input[i]) {
        case '!':
            output.push_back(create_token(TokenType::Bang, ""));
            break;
        case '\'':
            output.push_back(create_token(TokenType::SingleQuote, ""));
            break;
        case '\"':
            output.push_back(create_token(TokenType::DoubleQuote, ""));
            break;
        case '|':
            output.push_back(create_token(TokenType::Pipe, ""));
            break;
        case ' ': 
            // output.push_back(create_token(TokenType::Space, ""));
            break;
        case '\\':
        {
            if (i >= input_len) {
                output.push_back(create_token(TokenType::EscapedCharacter, ""));
                break;
            }

            string escaped_c(1, input[i+1]);
            output.push_back(create_token(TokenType::EscapedCharacter, escaped_c));
            i++;
            break;
        }
        default:
            // int max_index = input_len - i;
            string buffer;
            i += read_string(input, i, &buffer) - 1; // -1 otherwise it skips the current char as it will end on that char, can be solved by peaking but thats like 2 microseconds slower
            output.push_back(create_token(TokenType::StringLiteral, buffer));
        }
    }

    return output;
}

int read_string(string input, int curr, string *buffer) {
    for (int i = curr; i < (int) input.length(); i++) {
        switch (input[i]) {
        case '\"':
        case '\'':
        case ' ':
            return i - curr;
        default:
            *buffer += input[i];
        }
    }

    return input.length() - curr;
}

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

// typedef enum {
//     DoubleQuote,
//     SingleQuote,
//     Bang, 
//     Pipe,
//     Space,
//     EscapedCharacter,
//     StringLiteral
// } TokenType;