/**
1. Recursively explore each region (keep a set of nodes that are already accounted for)
2. Accumulate the area and perimeter
 For each of 4 directions, if no node, or node is different value, add 1 to perimeter.
 Add 1 to area.
 Recurse on each neighbor of same value.
3. At top-level, have a for loop that checks each cell, but it is really O(r) where r is the number of regions.

 Part 2 next steps, need to refine isValid to work with both out of bounds or mismatching types.
 Then need to implement interior corner detection using diagonals.
 */

import java.io.File

data class Spot(
    val row: Int,
    val col: Int,
    val type: Char = '_',
) {
    fun add(other: Spot): Spot = Spot(row + other.row, col + other.col)
}

data class Validity(
    val isValid: Boolean,
    val isOutOfBounds: Boolean,
    val isDifferentType: Boolean,
)

fun parseInput(fileName: String): List<List<Spot>> {
    val garden: MutableList<MutableList<Spot>> = mutableListOf()
    val file = File(fileName)
    val fileTxt = file.readText()

    file.useLines { lines ->
        lines.forEachIndexed { row, line ->
            val rowSpots: MutableList<Spot> = mutableListOf()
            line.forEachIndexed { col, type ->
                val spot = Spot(row = row, col = col, type = type)
                rowSpots.add(spot)
            }
            garden.add(rowSpots)
        }
    }

    return garden
}

fun getValidity(
    garden: List<List<Spot>>,
    spot: Spot,
    expectedType: Char,
): Validity {
    val isOutOfBounds =
        !(
            spot.row >= 0 &&
                spot.row < garden.size &&
                spot.col >= 0 &&
                spot.col < garden[0].size
        )
    var isDifferentType = false
    if (!isOutOfBounds) {
        isDifferentType = garden[spot.row][spot.col].type != expectedType
    }

    return Validity(isOutOfBounds = isOutOfBounds, isDifferentType = isDifferentType, isValid = !isOutOfBounds && !isDifferentType)
}

val dirs =
    listOf(
        Spot(-1, 0),
        Spot(0, 1),
        Spot(1, 0),
        Spot(0, -1),
    )

fun getFenceDataPart1(
    garden: List<List<Spot>>,
    spot: Spot,
    visited: MutableSet<Spot>,
): List<Int> {
    visited.add(spot)

    var localEdges = 0
    var returns: MutableList<List<Int>> = mutableListOf()
    for (dir in dirs) {
        var pos = spot.add(dir)
        var validity = getValidity(garden, pos, spot.type)
        if (!validity.isValid) {
            localEdges += 1
            continue
        }

        val matchingSpot = garden[pos.row][pos.col]
        if (visited.contains(matchingSpot)) {
            continue
        }

        returns.add(getFenceDataPart1(garden, matchingSpot, visited))
    }

    var totalEdges = localEdges
    var totalArea = 1
    for (x in returns) {
        totalEdges += x[0]
        totalArea += x[1]
    }

    return listOf(totalEdges, totalArea)
}

fun part1Solution(garden: List<List<Spot>>): Int {
    var totalPrice = 0
    val handled: MutableSet<Spot> = mutableSetOf()
    garden.forEachIndexed { row, rowSpots ->
        rowSpots.forEachIndexed { col, spot ->
            if (!handled.contains(spot)) {
                val fenceData =
                    getFenceDataPart1(
                        garden,
                        spot,
                        handled,
                    )
                println("$spot: perimeter=${fenceData[0]}, area=${fenceData[1]}")
                totalPrice += fenceData[0] * fenceData[1]
            }
            handled.add(spot)
        }
    }
    return totalPrice
}

fun getFenceDataPart2(
    garden: List<List<Spot>>,
    spot: Spot,
    visited: MutableSet<Spot>,
): List<Int> {
    visited.add(spot)

    var localSides = 0
    var returns: MutableList<List<Int>> = mutableListOf()
    dirs.forEachIndexed { dirIdx, dir ->
        val nextDirIdx = (dirIdx + 1) % dirs.size
        val nextDir = dirs[nextDirIdx]

        val pos = spot.add(dir)
        val nextPos = spot.add(nextDir)
        val diagPos = spot.add(dir).add(nextDir)

        val validity = getValidity(garden, pos, spot.type)
        val nextValidity = getValidity(garden, nextPos, spot.type)
        val diagValidity = getValidity(garden, diagPos, spot.type)

        // External corners (two adjacent spots 90 degrees apart are both invalid)
        if (!validity.isValid && !nextValidity.isValid) {
            localSides += 1
        }

        // Internal corners (two adjacent spots 90 degrees apart are both valid, but the diagonal between is not)
        if (validity.isValid && nextValidity.isValid && !diagValidity.isValid) {
            localSides += 1
        }

        if (!validity.isValid) {
            return@forEachIndexed
        }

        val matchingSpot = garden[pos.row][pos.col]
        if (visited.contains(matchingSpot)) {
            return@forEachIndexed
        }
        returns.add(getFenceDataPart2(garden, matchingSpot, visited))
    }

    var totalSides = localSides
    var totalArea = 1
    for (x in returns) {
        totalSides += x[0]
        totalArea += x[1]
    }

    return listOf(totalSides, totalArea)
}

fun part2Solution(garden: List<List<Spot>>): Int {
    var totalPrice = 0
    val handled: MutableSet<Spot> = mutableSetOf()
    garden.forEachIndexed { row, rowSpots ->
        rowSpots.forEachIndexed { col, spot ->
            if (!handled.contains(spot)) {
                val fenceData =
                    getFenceDataPart2(
                        garden,
                        spot,
                        handled,
                    )
                println("$spot: sides=${fenceData[0]}, area=${fenceData[1]}")
                totalPrice += fenceData[0] * fenceData[1]
            }
            handled.add(spot)
        }
    }
    return totalPrice
}

val garden = parseInput(args[0])
println("Part 1: ${part1Solution(garden)}")
println("Part 2: ${part2Solution(garden)}")
