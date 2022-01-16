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
		free(buffer);
		return NULL;
	}

	// Ensure that the buffer data is null-terminated
	buffer[bytes_read] = '\0';

	fclose(fp);

	return buffer;
}

int pop(char* position, char expected_opener) {
	// We'll use the buffer itself to keep track of which characters we've matched.
	// By setting the most significant bit in the character, we will signify that the character has already been matched.
	// This is a little bit like a stack. The matched characters are just ignored. We expect the stack head to be equal to the expected_opener.


	// The current position becomes matched:
	*position |= 0x80;

	// Skip over characters we've already matched:
	while (*position & 0x80) {
		position--;
	}

	// This is the most recent character that has not been matched.
	char opener = *position;

	// Set the most significatnt bit, matching it!
	*position |= 0x80;

	// Return true if the opener was expected.
	return (opener == expected_opener);
}

int pt1_answer(char *buffer) {
	if (buffer == NULL) {
		printf("Error, pt1_answer was given an input struct with a NULL pointer.\n");
		return 0;
	}

	// Start at the begining
	char *position = buffer;

	int score = 0;

	// Loop over all lines
	while (*position != '\0') {

		// Loop over characters in the lines
		while (*position != '\n') {

			char current = *position;
			//printf("%c", current);

			// if a closing symbol is found, find a match for it.
			switch (*position) {
				case ')': {
					if (!pop(position, '(')) {
						score += 3;
						//printf(" Corrupted line! Unexpected ).");
						// Fast forward to the end of the line
						while (*(position + 1) != '\n') position++;
					}
					break;
				}
				case ']': {
					if (!pop(position, '[')) {
						score += 57;
						//printf(" Corrupted line! Unexpected ].");
						while (*(position + 1) != '\n') position++;
					}
					break;
				}
				case '}': {
					if (!pop(position, '{')) {
						//printf(" Corrupted line! Unexpected }.");
						score += 1197;
						while (*(position + 1) != '\n') position++;
					}
					break;
				}
				case '>': {
					if (!pop(position, '<')) {
						//printf(" Corrupted line! Unexpected >.");
						score += 25137;
						while (*(position + 1) != '\n') position++;
					}
					break;
				}
			}
			position++;
		}
		position++;
		//printf("\n");
	}

	// We'll unset the highest bits in the buffer, resetting it.
	// It would be cool to try to use SIMD instructions here, but we don't know the length of the buffer...
	while (*buffer != '\0') {
		*buffer++ &= 0x7F;
	}

	return score;
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

	//printf("%s",input.buffer);

	int pt1 = pt1_answer(buffer);
	printf("Part 1 score: %d\n", pt1);
	//printf("%s",buffer);
}
