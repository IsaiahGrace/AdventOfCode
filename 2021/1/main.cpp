#include <cstddef>
#include <cstdlib>
#include <ios>
#include <sstream>
#include <string>
#include <vector>
#include <iostream>
#include <fstream>

int main (int argc, char** argv) {
	if (argc < 2) {
		std::cerr << "Please provide a program file." << std::endl;
		return EXIT_FAILURE;
	}

	std::ifstream inputStream(argv[1], std::ifstream::in);
	std::vector<int> mem;
	
}
