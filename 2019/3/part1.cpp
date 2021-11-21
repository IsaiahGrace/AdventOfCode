#include <cstddef>
#include <cstdlib>
#include <sstream>
#include <map>
#include <stdexcept>
#include <vector>
#include <iostream>
#include <fstream>
#include <climits>

void drawCircuit(std::map<std::pair<int,int>,char>& pcb, const std::vector<std::pair<char,int>>& circuit, const char layer) {
	int x = 0;
	int y = 0;
	for (const auto& path : circuit) {
		for (int i = 0; i < path.second; i++) {
			switch(path.first) {
				case 'U': {
					y++;
					break;
				}
				case 'D': {
					y--;
					break;
				}
				case 'L': {
					x--;
					break;
				}
				case 'R': {
					x++;
					break;
				}
				default: {
					std::string error ("Unknown Direction: ");
					error.push_back(path.first);
					throw std::logic_error(error);
				}
			}
			std::pair<int,int> coordinate(x,y);
			pcb[coordinate] |= layer;
		}
	}
}

void constructCircuit(std::ifstream& inputStream, std::vector<std::pair<char,int>>& circuit) {
	std::string input;
	getline(inputStream, input);
	std::stringstream ss(input);
	while (ss.good()) {
		std::string line;
		getline(ss,line,',');
		char dir = line[0];
		int len = stoi(line.substr(1));
		circuit.push_back(std::pair<char,int>(dir,len));
	}
}

void findIntersections(const std::map<std::pair<int,int>,char>& pcb, std::vector<std::pair<int,int>>& intersections, char layers) {
	for (const auto& point : pcb) {
		if ((point.second & layers) == layers) {
			intersections.push_back(point.first);
		}
	}
}

int getClosest(const std::vector<std::pair<int,int>>& intersections) {
	int min = INT_MAX;
	for (const auto& intersection : intersections) {
		int distance = abs(intersection.first) + abs(intersection.second);
		if (distance < min) {
			min = distance;
		}
	}
	return min;
}

void printPCB(const std::map<std::pair<int,int>,char>& pcb) {
	for (const auto& coordinate : pcb) {
		std::cout << "(" << coordinate.first.first << "," << coordinate.first.second << ") = " << std::hex << int(coordinate.second) << std::dec << std::endl;
	}
}

int main (int argc, char** argv) {
	if (argc < 2) {
		std::cerr << "Please provide an input file" << std::endl;
		return EXIT_FAILURE;
	}

	std::ifstream inputStream(argv[1], std::ifstream::in);

	std::vector<std::pair<char,int>> c1;
	std::vector<std::pair<char,int>> c2;

	constructCircuit(inputStream, c1);
	constructCircuit(inputStream, c2);

	std::map<std::pair<int,int>,char> pcb;

	char layer1 = 0x01;
	char layer2 = 0x02;

	drawCircuit(pcb, c1, layer1);
	drawCircuit(pcb, c2, layer2);

	std::vector<std::pair<int,int>> intersections;

	findIntersections(pcb,intersections, layer1 | layer2);

	int closest = getClosest(intersections);

	std::cout << "Closest intersection: " << closest << std::endl;
}
