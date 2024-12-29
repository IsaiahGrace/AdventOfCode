from rich import print
import importlib
import os
import re
import sys


def import_days():
    days = dict()
    day_filter = re.compile(r"day(\d\d).py")
    for day in next(os.walk("."))[2]:
        match = day_filter.match(day)
        if not match:
            continue
        days[int(match[1])] = importlib.import_module(match[0].removesuffix(".py"))
    return days


def find_files():
    files = dict()
    files_filter = re.compile(r"(\d\d)-.*")
    input_filter = re.compile(r"..-input")
    for file in next(os.walk("inputs"))[2]:
        match = files_filter.match(file)
        if not match:
            continue
        n = int(match[1])

        if n not in files:
            files[n] = {"input": None, "tests": set()}

        if input_filter.match(file):
            files[n]["input"] = {file}
        else:
            files[n]["tests"].add(file)

    return files


def main(args):
    days = import_days()
    files = find_files()
    if not args:
        return

    day = int(args[0])
    if len(args) < 2:
        arg = "input"
    else:
        arg = "tests"

    for file in files[day][arg]:
        with open("inputs/" + file) as f:
            puzzle = f.read()

        print(file)
        solution = days[day].solve(puzzle)
        print(solution)


if __name__ == "__main__":
    main(sys.argv[1:])
