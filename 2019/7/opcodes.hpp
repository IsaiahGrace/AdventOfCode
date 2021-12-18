#ifndef _OPCODES_HPP_
#define _OPCODES_HPP_

typedef enum opcode {
	ADD = 1,
	MUL = 2,
	READ = 3,
	WRITE = 4,
	JNZ = 5,
	JZ = 6,
	LT = 7,
	CMP = 8,
	HALT = 99,
} opcode_t;

#endif // _OPCODES_HPP_
