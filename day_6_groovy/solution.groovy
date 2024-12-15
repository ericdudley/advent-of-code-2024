public class Solution {

    static void main(String[] args) {
        Solution solution = new Solution(args[0])

        // Part 1
        Map<Pos, boolean> visited = [:]
        println solution.getCount(visited)
        solution.printGrid(visited)

        // Part 2
        int loopCount = 0
        (new ArrayList<>(visited.keySet())).eachWithIndex { visitedPos, idx -> 

            Map<Pos, Boolean> tempVisited = [:]
            println "Testing position ${idx + 1} of ${visited.keySet().size()}"
            if(solution.getCount(tempVisited, [visitedPos]) == -1){
                // solution.printGrid(tempVisited)
                loopCount += 1
            }
        }
        println "Number of possible loops: $loopCount"
    }

    List<List<String>> grid;
    Pos initialPos;
    List<Pos> dirs = [
    new Pos(-1, 0),
    new Pos(0, 1),
    new Pos(1, 0),
    new Pos(0, -1)
    ]


    public Solution(String fileName) {
        List<List<Character>> grid = []

        File file = new File(fileName)
        file.eachLine { line, row ->
            grid[row - 1] = []
            line.eachWithIndex { c, col ->
                grid[row - 1][col] = c
            }
        }

        this.grid = grid;

        // Init first position
        this.grid.eachWithIndex { rowList, row ->
            rowList.eachWithIndex { val, col ->
                if (val == '^') {
                    this.initialPos = new Pos(row, col, this.dirs[0])
                }
            }
        }
    }
    
    int getCount(Map<Pos, Boolean> visited, List<Pos> extraBarriers = []) {
        Pos pos = this.initialPos.clone()
        int dirIdx = 0
        int count = 0
        boolean done = false
        Map<Pos, boolean> visitedWithDir = [:]
        while (true) {
            Pos posWithDir = new Pos(pos.row, pos.col, dirs[dirIdx])
            if (!visited.containsKey(pos)) {
                count += 1
            }

            if(visitedWithDir.containsKey(posWithDir)) {
                return -1
            }

            visited.put(pos.clone(), true)
            visitedWithDir.put(posWithDir, true)
            while (true) {
                Pos prevPos = pos.clone()
                pos.row += dirs[dirIdx].row
                pos.col += dirs[dirIdx].col

                if (pos.row < 0 || pos.col < 0 || pos.row >= this.grid.size() || pos.col >= this.grid[0].size()) {
                    done = true
                    break
                }

                if (this.grid[pos.row][pos.col] == '#' || extraBarriers.contains(pos)) {
                    pos = prevPos
                    dirIdx += 1
                    if (dirIdx == dirs.size()) {
                        dirIdx = 0
                    }
                    continue
                }

                break
            }
            if (done) {
                break
            }
        }

        return count
    }

    void printGrid(Map<Pos, Boolean> highlightedPositions) {
        this.grid.eachWithIndex { rowList, row ->
                    rowList.eachWithIndex { val, col ->
                        Pos testPos = new Pos(row, col)
                        if (highlightedPositions.get(testPos)) {
                            print '%'
                    } else {
                            print val
                        }
                    }
                    println '-'
        }
    }

}

class Pos {

    int row
    int col
    Pos dir

    public Pos(int row, int col, Pos dir = null) {
        this.row = row
        this.col = col
        this.dir = dir
    }

    public Pos clone() {
        return new Pos(row, col);
    }

    @Override
    String toString() {
        return "Pos(row: $row, col: $col)"
    }

    @Override
    boolean equals(Object o) {
        if (this.is(o)) { return true }
        if (getClass() != o.getClass()) { return false }
        Pos other = (Pos) o
        return this.row == other.row && this.col == other.col && this.dir == other.dir
    }

    @Override
    int hashCode() {
        return Objects.hash(row, col, dir)
    }

}
