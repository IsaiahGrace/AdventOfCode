#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>

typedef struct {
	uint64_t pt1;
	uint64_t pt2;
} score_t;

// These two structs are kinda confusing... But here's what they do:
// The objective is to create a linked list of scores for part 2, but to reduce the number of malloc calls
// So we'll create a scoreBlock_t that can hold several autoScore_t entries.
// We'll maintain the autoScores in a sorted linked list, so they may need shuffling, but that's what pointers are for.
// The autoScore_t next field ALWAYS points either to NULL, or to another score with a LOWER score.
// I've intentionally left the size of the array of autoScore_t small because I want to make sure that I trigger the block behavior.

#define SCORE_BLOCK_SIZE 10

typedef struct autoScore_t {
	uint64_t score;
	struct autoScore_t* next;
} autoScore_t;

typedef struct scoreBlock_t {
	autoScore_t scores[SCORE_BLOCK_SIZE];
	int count;
	struct scoreBlock_t* next;
} scoreBlock_t;

typedef struct {
	scoreBlock_t* firstScoreBlock;
	autoScore_t* maxScore;
} scoreList_t;

char* read_file(char* file_path) {
	FILE* fp = fopen(file_path, "r");
	char* buffer = NULL;

	if (fp == NULL) {
		printf("Error opening file %s\n", file_path);
		return NULL;
	}

	fseek(fp, 0L, SEEK_END);

	size_t size = ftell(fp);

	if (size == -1) {
		printf("Error determining size of input file.\n");
		return NULL;
	}

	buffer = malloc(sizeof(char) * (size + 2));

	if (buffer == NULL) {
		printf("Error, could not malloc space for file. Tried to malloc %ld bytes.", size + 2);
		return NULL;
	}

	fseek(fp, 0L, SEEK_SET);

	size_t bytes_read = fread(buffer + 1, sizeof(char), size, fp);

	if (ferror(fp)) {
		printf("Error reading file.\n");
		free(buffer);
		return NULL;
	}

	// Ensure that the buffer data is null-terminated
	buffer[bytes_read + 1] = '\0';

	// We'll also insert a '\n' at the beginning of the first line, so that when we're going backwards through the first line, we'll know when we've reached the beginning.
	buffer[0] = '\n';

	fclose(fp);

	return buffer;
}

void erase(scoreBlock_t* scoreBlock) {
	scoreBlock_t* next;
	while (scoreBlock != NULL) {
		next = scoreBlock->next;
		free(scoreBlock);
		scoreBlock = next;
	}
}

scoreList_t insert(scoreList_t scoreList, uint64_t score) {
	scoreBlock_t* scoreBlock = scoreList.firstScoreBlock;
	autoScore_t* maxScore = scoreList.maxScore;

	if (scoreBlock == NULL) {
		// printf("Creating first scoreBlock.\n");
		scoreBlock = malloc(sizeof(scoreBlock_t));
		// If malloc fails, then it's time to stop programming for the day..
		scoreBlock->next = NULL;
		scoreBlock->count = 0;
	}

	// printf("Finding tail of scoreBlock.\n");
	// First up, find a spot in the scoreBlock linked list to put the score:
	scoreBlock_t* currentBlock = scoreBlock;
	while (currentBlock->count == SCORE_BLOCK_SIZE) {
		currentBlock = currentBlock->next;
	}

	// printf("Storing newScore in scoreBlock.\n");
	currentBlock->scores[currentBlock->count].score = score;
	autoScore_t* newScore = &currentBlock->scores[currentBlock->count];

	currentBlock->count++;

	// If we just inserted the last score in the scoreBlock_t, malloc another one!
	// This way there is ALWAYS room for one more score.
	if (currentBlock->count == SCORE_BLOCK_SIZE) {
		// printf("Creating a new scoreBlock because we need space.\n");
		currentBlock->next = malloc(sizeof(scoreBlock_t));
		currentBlock->next->count = 0;
		currentBlock->next->next = NULL;
	}

	// Okay, now that we've safely found a place to store the newScore,
	// insert newScore into the sorted linked list of autoScore_t.
	autoScore_t* largerScore = NULL;
	autoScore_t* smallerScore = scoreList.maxScore;
	// printf("Inserting newScore into linked list\n");
	while (smallerScore != NULL && smallerScore->score >= score) {
		largerScore = smallerScore;
		smallerScore = smallerScore->next;
	}
	newScore->next = smallerScore;

	if (largerScore != NULL) {
		largerScore->next = newScore;
	} else {
		maxScore = newScore;
	}

	scoreList.firstScoreBlock = scoreBlock;
	scoreList.maxScore = maxScore;
	return scoreList;
}

void printScores(scoreList_t scoreList) {
	autoScore_t* autoScore = scoreList.maxScore;
	while (autoScore != NULL) {
		printf("%lu -> ", autoScore->score);
		autoScore = autoScore->next;
	}
	printf("NULL\n");
}

void printScoreBlocks(scoreList_t scoreList) {
	scoreBlock_t* scoreBlock = scoreList.firstScoreBlock;
	while (scoreBlock != NULL) {
		printf("scoreBlock_t:\n");
		for (int i = 0; i < scoreBlock->count; i++) {
			printf("%d: %lu\n", i, scoreBlock->scores[i].score);
		}
		printf("|\n");
		printf("V\n");
		scoreBlock = scoreBlock->next;
	}
	printf("NULL\n");
}

uint64_t autocomplete(char* position) {
	// Finds the autocomplete score of the line.
	// position points to the END of the line ('\n')
	// Because of some sneaky behavior in the read_file function, we know that even the first line starts with '\n'.

	uint64_t score = 0;

	// Sometimes I love C, but I would never do this in "real life"...
	while (*--position != '\n') {
		if (*position & 0x80) continue;
		score *= 5;
		switch (*position) {
			case '(': score += 1; break;
			case '[': score += 2; break;
			case '{': score += 3; break;
			case '<': score += 4; break;
		}
	}

	return score;
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

score_t solve(char* buffer) {
	score_t score;
	score.pt1 = 0;
	score.pt2 = 0;

	if (buffer == NULL) {
		printf("Error, pt1_answer was given an input struct with a NULL pointer.\n");
		return score;
	}

	// Start at the first character. buffer[0] is '\n'
	char* position = buffer + 1;

	// For part 2, we'll use the buffer to store an array of scores.
	// We'll use a linked list to strore the scores so we can use a running insertion sort without performing many swaps.
	// I think that for the linked list implementation, I'll try to malloc a bunch of space all at once, so we can avoid calling malloc for every new node created.

	int corrupt;
	int autocompleteCount = 0;
	scoreList_t scoreList;
	scoreList.firstScoreBlock = NULL;
	scoreList.maxScore = NULL;

	// Loop over all lines
	while (*position != '\0') {
		corrupt = 0;

		// Loop over characters in the lines
		while (*position != '\n') {
			char current = *position;
			// printf("%c", current);

			// if a closing symbol is found, find a match for it.
			switch (*position) {
				case ')': {
					if (!pop(position, '(')) {
						corrupt = 1;
						score.pt1 += 3;
						while (*(position + 1) != '\n') position++;
					}
					break;
				}
				case ']': {
					if (!pop(position, '[')) {
						corrupt = 1;
						score.pt1 += 57;
						while (*(position + 1) != '\n') position++;
					}
					break;
				}
				case '}': {
					if (!pop(position, '{')) {
						corrupt = 1;
						score.pt1 += 1197;
						while (*(position + 1) != '\n') position++;
					}
					break;
				}
				case '>': {
					if (!pop(position, '<')) {
						corrupt = 1;
						score.pt1 += 25137;
						while (*(position + 1) != '\n') position++;
					}
					break;
				}
			}
			position++;
		}
		// We are at the end of the line.
		// If the line is not corrupt, then we can autocomplete it:
		if (!corrupt) {
			uint64_t autoScore = autocomplete(position);
			scoreList = insert(scoreList, autoScore);
			autocompleteCount++;
			// printf("%u\n",autoScore);
		}

		position++;
		// printf("\n");
	}

	printScores(scoreList);
	printScoreBlocks(scoreList);

	autoScore_t* medianScore = scoreList.maxScore;
	for (int i = 0; i < autocompleteCount / 2; i++) {
		medianScore = medianScore->next;
	}
	score.pt2 = medianScore->score;

	erase(scoreList.firstScoreBlock);
	return score;
}

int main(int argc, char** argv) {
	if (argc < 2) {
		printf("Please specify an input file.\n");
		return EXIT_FAILURE;
	}

	char* buffer = read_file(argv[1]);
	if (buffer == NULL) {
		printf("Error. read_file returned NULL");
		return EXIT_FAILURE;
	}

	score_t score = solve(buffer);
	printf("Part 1 score: %lu\n", score.pt1);
	printf("Part 2 score: %lu\n", score.pt2);
	free(buffer);
}
