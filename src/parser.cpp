#include "include/parser.hpp"

Command parse(vector<Token> tokens) {
    Command command;
    command.command = tokens[0].val;

    for (int i = 1; i < (int) tokens.size(); i++) {
        switch (tokens[i].type) {
        case TokenType::DoubleQuote: 
        {
            string buffer;
            i += read_quoted_string(&buffer, tokens, i, TokenType::DoubleQuote);
            command.args.push_back(buffer);
            break;
        }
        case TokenType::SingleQuote:
        {
            string buffer;
            i += read_quoted_string(&buffer, tokens, i, TokenType::SingleQuote);
            command.args.push_back(buffer);
            break;
        }
        case TokenType::Bang:
            //idk do smth with this EVENTUALLY
            break;
        case TokenType::Pipe:
            //eventually set up piping
            break;
        case TokenType::StringLiteral:
        case TokenType::EscapedCharacter:
            command.args.push_back(tokens[i].val);
            break;
        case TokenType::Space:
            break; // we can ignore whitespace as they seperate args
        default:
            std::cout << "Unrecognized token. Literally no idea how but yknow." << std::endl;
            exit(-2);
        }
    }

    return command;
}

int read_quoted_string(string *buffer, vector<Token> tokens, int curr_index, TokenType delimiter) {
    for (int i = curr_index + 1; i < (int) tokens.size(); i++) { // curr_index + 1 as we know the current one must be singlequote or doublequote, wihch is irrelevant
        if (tokens[i].type == delimiter) {
            // cout << i - curr_index;
            return i - curr_index;
        }

        // cout << tokens[i].type;

        switch (tokens[i].type) {
        case TokenType::SingleQuote:
            *buffer += '\'';
            break;
        case TokenType::DoubleQuote:
            *buffer += '\"';
            break;
        case TokenType::Bang:
            *buffer += '!';
            break;
        case TokenType::Pipe:
            *buffer += '|';
            break;
        case TokenType::Space:
            *buffer += ' ';
            break;
        case TokenType::EscapedCharacter:
        case TokenType::StringLiteral:            
            *buffer += tokens[i].val;
            break;
        }
    }

    return tokens.size() - curr_index;
}