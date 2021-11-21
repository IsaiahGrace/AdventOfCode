low=234208
high=765869

firstFilter = []

for i in range(low,high):
	low2high = True
	prevDigit = 0
	for digit in str(i):
		x = int(digit)
		if x < prevDigit:
			low2high = False
			break
		prevDigit = x

	if low2high:
		firstFilter.append(i)

passwords = []

for password in firstFilter:
	two = False
	digits = [0,0,0,0,0,0,0,0,0,0]
	chars = str(password)
	for char in chars:
		digits[int(char)] = digits[int(char)] + 1
	for digit in digits:
		if digit == 2:
			two = True
			break
	if two:
		passwords.append(password)

print(len(passwords))
