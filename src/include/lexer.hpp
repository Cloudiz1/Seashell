#pragma once
#include <iostream>
#include <vector>
#include "token.hpp"

using namespace std;

vector<Token> tokenize(string input);
int read_string(string input, int curr, string* buffer);
void print_tokens(vector<Token> input);