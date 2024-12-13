# https://adventofcode.com/2024/day/1

from typing import Tuple, List, Dict
import sys

def parse_input(file_path: str) -> Tuple[List[int], List[int]]:
    list1 = []
    list2 = []

    # Build list1 and list2 from txt file lines
    with open(file_path, 'r') as file:
        for line in file:
            clean_line = line.strip()
            parts = clean_line.split()
            assert len(parts) == 2

            list1.append(int(parts[0]))
            list2.append(int(parts[1]))

    assert len(list1) == len(list2)

    return list1, list2

def part1_solution(list1: List[int], list2: List[int]) -> int:
    """
    Example input:
        3   4
        4   3
        2   5
        1   3
        3   9
        3   3
    Solution:
        11

    Idea is to sort both lists and then compare piece-wise to compute the total distance.

    Step 1: Sort both lists

    Step 2: Compute distance for each pair (absolute) and sum
    """
    list1.sort()
    list2.sort()

    total_distance = 0
    for i in range(len(list1)):
        total_distance += abs(list1[i] - list2[i])

    return total_distance



def part2_solution(list1: List[int], list2: List[int]) -> int:
    """
    Example input:
        3   4
        4   3
        2   5
        1   3
        3   9
        3   3
    Solution:
        31

    Idea is to sort both lists and then compare piece-wise to compute the total distance.

    Step 1: Build frequency dict for each value in list 2

    Step 2: Iterate through list 1 and compute multiplication using dict
    """

    # Build frequency dict that counts occurences of each value in list2
    frequencies: Dict[int, int] = dict()
    for x in list2:
        if x not in frequencies:
            frequencies[x] = 0
        frequencies[x] += 1


    similarity_score = 0
    for x in list1:
        frequency = frequencies[x] if x in frequencies else 0
        similarity_score += x * frequency

    return similarity_score




if __name__ == "__main__":
    list1, list2 = parse_input(sys.argv[1])
    print(part2_solution(list1, list2))
