#pragma once
#include <iostream>

typedef enum {
    DoubleQuote,
    SingleQuote,
    Bang, 
    Pipe,
    Space,
    EscapedCharacter,
    StringLiteral
} TokenType;

typedef struct {
    TokenType type;
    std::string val;
} Token;