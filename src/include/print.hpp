#pragma once
#include <iostream>
#include <vector>
#include "token.hpp"
#include "parser.hpp"

using namespace std;

void print_tokens(vector<Token> input);
void print_command(Command command);