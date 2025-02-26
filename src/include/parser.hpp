#pragma once
#include <vector>
#include <iostream>

#include "lexer.hpp"
#include "token.hpp"

using namespace std;

typedef struct {
    string command;
    vector<string> args;
} Command;

Command parse(vector<Token> tokens);
int read_quoted_string(string *buffer, vector<Token> input, int curr_index, TokenType delimiter);