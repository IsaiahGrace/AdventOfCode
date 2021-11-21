#include <cstddef>
#include <cstdlib>
#include <sstream>
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
	size_t opcode = mem[pc];

	size_t a;
	size_t b;
	size_t dest;

	switch (opcode) {
		case ADD: {
			a = mem[mem[pc + 1]];
			b = mem[mem[pc + 2]];
			dest = mem[pc + 3];
			//std::cout <<"mem[" << dest << "] = " << a << "+" << b << std::endl;
			mem[dest] = a + b;
			pc += 4;
			break;
		}
		case MUL: {
			a = mem[mem[pc + 1]];
			b = mem[mem[pc + 2]];
			dest = mem[pc + 3];
			//std::cout <<"mem[" << dest << "] = " << a << "*" << b << std::endl;
			mem[dest] = a * b;
			pc += 4;
			break;
		}
		case HALT: {
			break;
		}
		default: {
			std::cerr << "exec unknown instruction: pc = " << pc << " opcode = " << mem[pc] << std::endl;
			break;
		}
	}
	return pc;
}

void run(std::vector<size_t>& mem) {
	size_t pc = 0;
	size_t npc = 0;
	do {
		pc = npc;
		npc = exec(mem, pc);
	} while (pc != npc);
}

void dumpMem(const std::vector<size_t>& mem) {
	size_t i = 0;
	for ( ; i < mem.size() - 1; i++) {
		std::cout << mem[i] << ',';
	}
	std::cout << mem[i] << std::endl;
}

int main (int argc, char** argv) {
	if (argc < 2) {
		std::cerr << "Please provide an input file" << std::endl;
		return EXIT_FAILURE;
	}

	for (size_t verb = 0; verb < 100; verb++) {
		for (size_t noun = 0; noun < 100; noun++) {
			std::ifstream inputStream(argv[1], std::ifstream::in);
			std::vector<size_t> mem;
			initMem(mem, inputStream);
			mem[1] = noun;
			mem[2] = verb;
			try {
				run(mem);
			} catch (... ) {
				continue;
			}
			if (mem[0] == 19690720) {
				std::cout << "noun = " << noun << std::endl;
				std::cout << "verb = " << verb << std::endl;
				std::cout << "answer = " << 100 * noun + verb << std::endl;
				return EXIT_SUCCESS;
			}
		}
	}
	std::cout << "No solution found" << std::endl;
	return EXIT_FAILURE;
}