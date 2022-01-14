#include <stdlib.h>
#include <stdio.h>

char *read_file(char* file_path) {
	FILE *fp = fopen(file_path,"r");
	char *buffer = NULL;

	if (fp == NULL) {
		printf("Error opening file %s\n", file_path);
		return NULL;
	}

	fseek(fp, 0L, SEEK_END);

	long size = ftell(fp);

	if (size == -1) {
		printf("Error determining size of input file.\n");
		return NULL;
	}

	buffer = malloc(sizeof(char) * (size + 1));

	if (buffer == NULL) {
		printf("Error, could not malloc space for file. Tried to malloc %ld bytes.", size + 1);
		return NULL;
	}

	fseek(fp, 0L, SEEK_SET);

	size_t bytes_read = fread(buffer, sizeof(char), size, fp);

	if (ferror(fp)) {
		printf("Error reading file.\n");
	} else {
		buffer[bytes_read] = '\0';
	}

	fclose(fp);

	return buffer;
}


int main(int argc, char** argv) {
	if (argc < 2) {
		printf("Please specify an input file.\n");
		return EXIT_FAILURE;
	}

	char *buffer = read_file(argv[1]);
	if (buffer == NULL) {
		printf("Error. read_file returned NULL");
		return EXIT_FAILURE;
	}

	printf("%s",buffer);
}
