#pragma once
#include <iostream>
#include <vector>
#include "token.hpp"

using namespace std;

vector<Token> tokenize(string input);
Token create_token(TokenType type, string input);
int read_string(string* buffer, string input, int curr);
void print_tokens(vector<Token> input);