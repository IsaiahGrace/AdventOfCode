#include <cstddef>
#include <cstdlib>
#include <sstream>
#include <string>
#include <vector>
#include <iostream>
#include <fstream>

#include "opcodes.hpp"
#include "spdlog/spdlog.h"
#include "spdlog/cfg/env.h"

void initMem(std::vector<size_t>& mem, std::ifstream& inputStream) {
	while (inputStream.good()) {
		std::string dataString;
		getline(inputStream, dataString, ',');
		size_t data = stoi(dataString);
		mem.push_back(data);
	}
}

void logMem(std::vector<size_t>& mem, std::string opcode, size_t pc, size_t num) {
	std::stringstream info;
	info << opcode << ": ";
	for (size_t i = 0; i < num; i++) {
		info << mem[pc + i] << " ";
	}
	spdlog::info(info.str());
}

size_t exec(std::vector<size_t>& mem, size_t pc) {
	size_t opcode = mem[pc] % 100;
	size_t options = mem[pc] / 100;

	char optA = options % 10;
	char optB = (options / 10) % 10;
	//char optC = options / 100;

	std::stringstream info;
	switch (opcode) {
		case ADD: {
			size_t a = optA ? mem[pc + 1] : mem[mem[pc + 1]];
		 	size_t b = optB ? mem[pc + 2] : mem[mem[pc + 2]];
			size_t dest = mem[pc + 3];
			mem[dest] = a + b;
			logMem(mem, "ADD", pc, 4);
			pc += 4;
			break;
		}
		case MUL: {
			size_t a = optA ? mem[pc + 1] : mem[mem[pc + 1]];
			size_t b = optB ? mem[pc + 2] : mem[mem[pc + 2]];
			size_t dest = mem[pc + 3];
			mem[dest] = a * b;
			logMem(mem, "MUL", pc, 4);
			pc += 4;
			break;
		}
		case READ: {
			std::cout << "Enter a number: ";
			std::cin >> (optA ? mem[pc + 1] : mem[mem[pc + 1]]);
			logMem(mem, "READ", pc, 2);
			pc += 2;
			break;
		}
		case WRITE: {
			std::cout << (optA ? mem[pc + 1] : mem[mem[pc + 1]]) << std::endl;
			logMem(mem, "WRITE", pc, 2);
			pc += 2;
			break;
		}
		case JNZ: {
			size_t a = optA ? mem[pc + 1] : mem[mem[pc + 1]];
			size_t dest = optB ? mem[pc + 2] : mem[mem[pc + 2]];
			logMem(mem, "JNZ", pc, 2);
			if (a) {
				pc = dest;
			} else {
				pc += 3;
			}
			break;
		}
		case JZ: {
			size_t a = optA ? mem[pc + 1] : mem[mem[pc + 1]];
			size_t dest = optB ? mem[pc + 2] : mem[mem[pc + 2]];
			logMem(mem, "JZ", pc, 2);
			if (a) {
				pc += 3;
			} else {
				pc = dest;
			}
			break;
		}
		case LT: {
			size_t a = optA ? mem[pc + 1] : mem[mem[pc + 1]];
			size_t b = optB ? mem[pc + 2] : mem[mem[pc + 2]];
			mem[mem[pc + 3]] = (a < b);
			logMem(mem, "LT", pc, 4);
			pc += 4;
			break;
		}
		case CMP: {
			size_t a = optA ? mem[pc + 1] : mem[mem[pc + 1]];
			size_t b = optB ? mem[pc + 2] : mem[mem[pc + 2]];
			mem[mem[pc + 3]] = (a == b);
			logMem(mem, "CMP", pc, 4);
			pc += 4;
			break;
		}
		case HALT: {
			break;
		}
		default: {
			spdlog::error("exec unknown instruction: pc = {} opcode = {}", pc, opcode);
			break;
		}
	}
	return pc;
}

void dumpMem(const std::vector<size_t>& mem) {
	size_t i = 0;
	for ( ; i < mem.size() - 1; i++) {
		std::cout << mem[i] << ',';
	}
	std::cout << mem[i] << std::endl;
}

void run(std::vector<size_t>& mem) {
	size_t pc = 0;
	size_t npc = 0;
	do {
		pc = npc;
		npc = exec(mem, pc);
	} while (pc != npc);
}

int main (int argc, char** argv) {
	if (argc < 2) {
		std::cerr << "Please provide an input file" << std::endl;
		return EXIT_FAILURE;
	}

	spdlog::cfg::load_env_levels();

	std::ifstream inputStream(argv[1], std::ifstream::in);
	std::vector<size_t> mem;
	initMem(mem, inputStream);
	run(mem);
	//dumpMem(mem);
}