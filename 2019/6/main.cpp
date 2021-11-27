#include <iterator>
#include <algorithm>
#include <vector>
#include <map>
#include <set>
#include <iostream>
#include <fstream>

typedef std::string Tag;

class Body {
public:
	Tag parent;
	int depth;
	std::set<Tag> children;
};

void populateMap(std::map<Tag,Body>& orbitMap, std::ifstream& inputStream) {
	while(inputStream.good()) {
		std::string relation;
		std::getline(inputStream,relation);

		//std::cout << "Got Line: " << relation << std::endl;

		Tag parent, child;
		size_t i;

		for (i = 0; i < relation.size(); i++) {
			if (relation[i] == ')') {
				//std::cout << "Found )" << std::endl;
				break;
			}
			//std::cout << "parent[" << i << "] = " << relation[i] << std::endl;
			parent.push_back(relation[i]);
		}

		i++;

		for (; i < relation.size(); i++) {
			//std::cout << "child[" << i - offset << "] = " << relation[i] << std::endl;
			child.push_back(relation[i]);
		}

		//std::cout << "Parent: " << parent << " Child: " << child << std::endl;

		orbitMap[child].parent = parent;
	}
}

void addChildren(std::map<Tag,Body>& orbitMap) {
	for (const auto &pair : orbitMap) {
		orbitMap[pair.second.parent].children.insert(pair.first);
	}
}

void calculateDepth(std::map<Tag,Body>& orbitMap, Tag parent) {
	for (const auto& child : orbitMap[parent].children) {
		orbitMap[child].depth = orbitMap[parent].depth + 1;
		calculateDepth(orbitMap, child);
	}
}

int checkSum(std::map<Tag,Body>& orbitMap, Tag parent) {
	int sum = orbitMap[parent].depth;
	for (const auto& child : orbitMap[parent].children) {
		sum += checkSum(orbitMap, child);
	}
	return sum;
}

void printMap(std::map<Tag,Body>& orbitMap, Tag parent) {
	std::cout << "Body: " << parent << " ";
	std::cout << "Depth: " << orbitMap[parent].depth << " ";
	std::cout << "Children:";
	for (const auto& child : orbitMap[parent].children) {
		std::cout << " " << child;
	}
	std::cout << std::endl;
	for (const auto& child : orbitMap[parent].children) {
		printMap(orbitMap, child);
	}
}

void findPathSet(std::map<Tag,Body>& orbitMap, std::set<Tag>& path, Tag body) {
	path.insert(body);
	if (body == "COM") return;
	findPathSet(orbitMap, path, orbitMap[body].parent);
}

void printPathSet(std::set<Tag> path) {
	std::cout << "Path:";
	for (const auto& body : path) {
		std::cout << " " << body;
	}
	std::cout << std::endl;
}

int main(int argc, char** argv) {
	if (argc < 2) {
		std::cerr << "Please provide an input file" << std::endl;
		return EXIT_FAILURE;
	}

	std::ifstream inputStream(argv[1], std::ifstream::in);

	std::map<Tag,Body> orbitMap;

	populateMap(orbitMap, inputStream);
	addChildren(orbitMap);
	orbitMap["COM"].depth = 0;
	calculateDepth(orbitMap, "COM");
	//printMap(orbitMap, "COM");
	std::cout << "CheckSum: " << checkSum(orbitMap, "COM") << std::endl;

	std::set<Tag> sanPathSet, youPathSet;
	findPathSet(orbitMap, sanPathSet, "SAN");
	//printPathSet(sanPathSet);
	findPathSet(orbitMap, youPathSet, "YOU");
	//printPathSet(youPathSet);
	std::set<Tag> commonPath;
	//printPathSet(commonPath);
	std::set_difference(sanPathSet.begin(), sanPathSet.end(), youPathSet.begin(), youPathSet.end(), std::inserter(commonPath, commonPath.end()));
	//printPathSet(commonPath);
	std::set_difference(youPathSet.begin(), youPathSet.end(), sanPathSet.begin(), sanPathSet.end(), std::inserter(commonPath, commonPath.end()));
	commonPath.erase("SAN");
	commonPath.erase("YOU");
	printPathSet(commonPath);
	std::cout << "Transfers: " << commonPath.size() << std::endl;
}
