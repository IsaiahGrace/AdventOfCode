#include <cstddef>
#include <cstdlib>
#include <sstream>
#include <string>
#include <vector>
#include <iostream>
#include <fstream>

#include "opcodes.hpp"

void initMem(std::vector<size_t>& mem, std::ifstream& inputStream) {
	while (inputStream.good()) {
		std::string dataString;
		getline(inputStream, dataString, ',');
		size_t data = stoi(dataString);
		mem.push_back(data);
	}
}

size_t exec(std::vector<size_t>& mem, size_t pc) {
	size_t opcode = mem[pc] % 100;
	size_t options = mem[pc] / 100;

	char optA = options % 10;
	char optB = (options / 10) % 10;
	//char optC = options / 100;

	//std::cout << "A : " << (optA ? "Imm " : "Pos ");
	//std::cout << "B : " << (optB ? "Imm " : "Pos ");
	//std::cout << "OP: " << opcode << " ";

	switch (opcode) {
		case ADD: {
			size_t a = optA ? mem[pc + 1] : mem[mem[pc + 1]];
		 	size_t b = optB ? mem[pc + 2] : mem[mem[pc + 2]];
			size_t dest = mem[pc + 3];
			mem[dest] = a + b;
			//std::cout << "mem[" << dest << "] = " << a << " + " << b << std::endl;
			pc += 4;
			break;
		}
		case MUL: {
			size_t a = optA ? mem[pc + 1] : mem[mem[pc + 1]];
			size_t b = optB ? mem[pc + 2] : mem[mem[pc + 2]];
			size_t dest = mem[pc + 3];
			mem[dest] = a * b;
			//std::cout << "mem[" << dest << "] = " << a << " * " << b << std::endl;
			pc += 4;
			break;
		}
		case READ: {
			std::cout << "Enter a number: ";
			std::cin >> (optA ? mem[pc + 1] : mem[mem[pc + 1]]);
			//std::cout << "Read from io: " << (optA ? mem[pc + 1] : mem[mem[pc + 1]]) << std::endl;
			pc += 2;
			break;
		}
		case WRITE: {
			std::cout << (optA ? mem[pc + 1] : mem[mem[pc + 1]]) << std::endl;
			pc += 2;
			break;
		}
		case JNZ: {
			size_t a = optA ? mem[pc + 1] : mem[mem[pc + 1]];
			size_t dest = optB ? mem[pc + 2] : mem[mem[pc + 2]];
			//std::cout << "JNZ ";
			if (a) {
				//std::cout << "Jumping to " << dest;
				pc = dest;
			} else {
				//std::cout << "Not jumping";
				pc += 3;
			}
			//std::cout << std::endl;
			break;
		}
		case JZ: {
			size_t a = optA ? mem[pc + 1] : mem[mem[pc + 1]];
			size_t dest = optB ? mem[pc + 2] : mem[mem[pc + 2]];
			//std::cout << "JZ ";
			if (a) {
				//std::cout << "Not jumping";
				pc += 3;
			} else {
				//std::cout << "Jumping to " << dest;
				pc = dest;
			}
			//std::cout << std::endl;
			break;
		}
		case LT: {
			size_t a = optA ? mem[pc + 1] : mem[mem[pc + 1]];
			size_t b = optB ? mem[pc + 2] : mem[mem[pc + 2]];
			mem[mem[pc + 3]] = (a < b);
			//std::cout << "LT : (" << a << " < " << b << ") == " << (a < b) << std::endl;
			pc += 4;
			break;
		}
		case CMP: {
			size_t a = optA ? mem[pc + 1] : mem[mem[pc + 1]];
			size_t b = optB ? mem[pc + 2] : mem[mem[pc + 2]];
			mem[mem[pc + 3]] = (a == b);
			//std::cout << "CMP : (" << a << " == " << b << ") == " << (a == b) << std::endl;
			pc += 4;
			break;
		}
		case HALT: {
			//std::cout << std::endl;
			break;
		}
		default: {
			std::cerr << "exec unknown instruction: pc = " << pc << " opcode = " << opcode << std::endl;
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

	std::ifstream inputStream(argv[1], std::ifstream::in);
	std::vector<size_t> mem;
	initMem(mem, inputStream);
	run(mem);
	//dumpMem(mem);
}