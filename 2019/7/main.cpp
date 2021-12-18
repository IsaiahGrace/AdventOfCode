#include <cstddef>
#include <cstdlib>
#include <ios>
#include <sstream>
#include <string>
#include <vector>
#include <iostream>
#include <fstream>

#include "opcodes.hpp"
#include "spdlog/spdlog.h"
#include "spdlog/cfg/env.h"

void initMem(std::vector<long>& mem, std::ifstream& inputStream) {
	while (inputStream.good()) {
		std::string dataString;
		getline(inputStream, dataString, ',');
		long data = stoi(dataString);
		mem.push_back(data);
	}
}

void logMem(std::vector<long>& mem, std::string opcode, long pc, long num) {
	std::stringstream info;
	info << opcode << ": ";
	info << "PC: " << pc << " | ";
	for (long i = 0; i < num; i++) {
		info << mem[pc + i] << " ";
	}
	spdlog::info(info.str());
}

long exec(std::vector<long>& mem, long pc) {
	long opcode = mem[pc] % 100;
	long options = mem[pc] / 100;

	char optA = options % 10;
	char optB = (options / 10) % 10;
	//char optC = options / 100;

	std::stringstream info;
	switch (opcode) {
		case ADD: {
			logMem(mem, "ADD  ", pc, 4);
			long a = optA ? mem[pc + 1] : mem[mem[pc + 1]];
		 	long b = optB ? mem[pc + 2] : mem[mem[pc + 2]];
			long dest = mem[pc + 3];
			mem[dest] = a + b;
			pc += 4;
			break;
		}
		case MUL: {
			logMem(mem, "MUL  ", pc, 4);
			long a = optA ? mem[pc + 1] : mem[mem[pc + 1]];
			long b = optB ? mem[pc + 2] : mem[mem[pc + 2]];
			long dest = mem[pc + 3];
			mem[dest] = a * b;
			pc += 4;
			break;
		}
		case READ: {
			logMem(mem, "READ ", pc, 2);
			std::cerr << "Enter a number: ";
			std::cin >> (optA ? mem[pc + 1] : mem[mem[pc + 1]]);
			pc += 2;
			break;
		}
		case WRITE: {
			logMem(mem, "WRITE", pc, 2);
			std::cout << (optA ? mem[pc + 1] : mem[mem[pc + 1]]) << std::endl;
			pc += 2;
			break;
		}
		case JNZ: {
			logMem(mem, "JNZ  ", pc, 2);
			long a = optA ? mem[pc + 1] : mem[mem[pc + 1]];
			long dest = optB ? mem[pc + 2] : mem[mem[pc + 2]];
			if (a) {
				pc = dest;
			} else {
				pc += 3;
			}
			break;
		}
		case JZ: {
			logMem(mem, "JZ   ", pc, 2);
			long a = optA ? mem[pc + 1] : mem[mem[pc + 1]];
			long dest = optB ? mem[pc + 2] : mem[mem[pc + 2]];
			if (a) {
				pc += 3;
			} else {
				pc = dest;
			}
			break;
		}
		case LT: {
			logMem(mem, "LT   ", pc, 4);
			long a = optA ? mem[pc + 1] : mem[mem[pc + 1]];
			long b = optB ? mem[pc + 2] : mem[mem[pc + 2]];
			mem[mem[pc + 3]] = (a < b);
			pc += 4;
			break;
		}
		case CMP: {
			logMem(mem, "CMP  ", pc, 4);
			long a = optA ? mem[pc + 1] : mem[mem[pc + 1]];
			long b = optB ? mem[pc + 2] : mem[mem[pc + 2]];
			mem[mem[pc + 3]] = (a == b);
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

void dumpMem(const std::vector<long>& mem) {
	size_t i = 0;
	for ( ; i < mem.size() - 1; i++) {
		std::cout << mem[i] << ',';
	}
	std::cout << mem[i] << std::endl;
}

void run(std::vector<long>& mem) {
	long pc = 0;
	long npc = 0;
	do {
		pc = npc;
		npc = exec(mem, pc);
	} while (pc != npc);
}

int main (int argc, char** argv) {
	if (argc < 2) {
		std::cerr << "Please provide a program file." << std::endl;
		return EXIT_FAILURE;
	}

	spdlog::cfg::load_env_levels();

	std::ifstream inputStream(argv[1], std::ifstream::in);
	std::vector<long> mem;
	initMem(mem,inputStream);
	run(mem);

	//std::vector<std::vector<long>> amps;
	//amps.reserve(5);

	/*
	for (int i = 0; i < 5; i++) {
		initMem(amps[i], inputStream);
		inputStream.clear();
		inputStream.seekg(0, std::ios::beg);
	}
	run(amps[0]);
	*/
}
