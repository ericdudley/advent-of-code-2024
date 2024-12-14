package main

import (
	"fmt"
	"os"
	"strings"
)

func parse_file() [][]string {
	file, err := os.ReadFile(os.Args[1])
	if err != nil {
		os.Exit(1)
	}

	txt := string(file)
	lines := strings.Split(txt, "\n")

	width := len(lines[0])
	height := len(lines)

	grid := make([][]string, height)
	for i := range grid {
		grid[i] = make([]string, width)
	}

	for row, rowString := range lines {
		for col, char := range rowString {
			grid[row][col] = string(char)
		}
	}

	return grid
}

func main() {
	grid := parse_file()

	vectors := make([][]int, 0)

	checkString := "XMAS"

	// Straight
	for i := -1; i <= 1; i += 1 {
		for j := -1; j <= 1; j += 1 {
			if i == 0 && j == 0 {
				continue
			}
			vectors = append(vectors, []int{i, j})
		}
	}

	total := 0
	for row := range grid {
		for col := range grid[0] {
			for _, vector := range vectors {
				pos := [2]int{row, col}
				isGood := true
				for k := 0; k < len(checkString); k += 1 {
					if (pos[0] < 0 || pos[0] >= len(grid) || pos[1] < 0 || pos[1] >= len(grid[0])) || (string(checkString[k]) != grid[pos[0]][pos[1]]) {
						isGood = false
						break
					}
					pos[0] += vector[0]
					pos[1] += vector[1]
				}
				if isGood {
					total += 1
				}
			}
		}
	}

	crossTotal := 0
	for row := range grid {
		for col := range grid[0] {
			if row < 1 || row >= len(grid)-1 || col < 1 || col >= len(grid[0])-1 {
				continue
			}

			if grid[row][col] != "A" {
				continue
			}

			valid := []string{
				"MSMS",
				"SMSM",
				"MSSM",
				"SMMS",
			}
			actual := fmt.Sprintf("%s%s%s%s",
				grid[row-1][col-1],
				grid[row+1][col+1],
				grid[row-1][col+1],
				grid[row+1][col-1])

			for _, test := range valid {
				if test == actual {
					crossTotal += 1
					break
				}
			}

		}
	}
	fmt.Println("total:", total)
	fmt.Println("crossTotal:", crossTotal)
}
