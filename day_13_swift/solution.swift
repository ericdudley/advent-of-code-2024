import Foundation

struct Button {
    var x = 0
    var y = 0
    var cost = 0
}

struct Prize {
    var x = 0
    var y = 0
}

class Machine: CustomStringConvertible {
    var a: Button
    var b: Button
    var prize: Prize

    init(a: Button, b: Button, prize: Prize) {
        self.a = a
        self.b = b
        self.prize = prize
    }

    var description: String {
        return "Machine(\n\tA: \(self.a)\n\tB: \(self.b)\n\tPrize: \(self.prize)\n)\n"
    }
}

func parseButton(txt: String, cost: Int) -> Button {
    let leftRight = txt.split(separator: ":")
    let right = leftRight[1]
    let xy = right.split(separator: ",")
    let x = xy[0]
    let y = xy[1]

    let xParts = x.split(separator: "+")
    let yParts = y.split(separator: "+")

    let xNumStr = xParts[1]
    let yNumStr = yParts[1]

    let xNum = Int(xNumStr)
    let yNum = Int(yNumStr)

    return Button(x: xNum ?? 0, y: yNum ?? 0, cost: cost)
}

func parsePrize(txt: String) -> Prize {
    let leftRight = txt.split(separator: ":")
    let right = leftRight[1]
    let xy = right.split(separator: ",")
    let x = xy[0]
    let y = xy[1]

    let xParts = x.split(separator: "=")
    let yParts = y.split(separator: "=")

    let xNumStr = xParts[1]
    let yNumStr = yParts[1]

    let xNum = Int(xNumStr)
    let yNum = Int(yNumStr)

    return Prize(x: xNum ?? 0, y: yNum ?? 0)
}

func parseInput(fileName: String) -> [Machine] {
    do {
        let fileURL = URL(fileURLWithPath: fileName)
        let data = try String(contentsOf: fileURL, encoding: .utf8)
        let lines = data.components(separatedBy: CharacterSet.newlines)

        var machines: [Machine] = []
        var i = 0
        while i < lines.count {
            while i < lines.count && !lines[i].starts(with: "Button A") {
                i += 1
            }
            if i == lines.count {
                break
            }
            let buttonA = parseButton(txt: lines[i], cost: 3)

            while i < lines.count && !lines[i].starts(with: "Button B") {
                i += 1
            }
            if i == lines.count {
                break
            }
            let buttonB = parseButton(txt: lines[i], cost: 1)

            while i < lines.count && !lines[i].starts(with: "Prize") {
                i += 1
            }
            if i == lines.count {
                break
            }
            let prize = parsePrize(txt: lines[i])

            let machine = Machine(a: buttonA, b: buttonB, prize: prize)
            machines.append(machine)
        }

        return machines
    } catch {
        print(error)
        return []
    }
}

/// Brute force solution, feasible since we are constrained to 100 max presses for each button.
func getTotalCostPart1(machines: [Machine]) -> Int {
    var totalCost = 0
    for machine: Machine in machines {
        var minCost = 1_000_000_000_000
        for aUse in 1...100 {
            for bUse in 1...100 {
                let totalCost = aUse * machine.a.cost + bUse * machine.b.cost
                let totalX = machine.a.x * aUse + machine.b.x * bUse
                let totalY = machine.a.y * aUse + machine.b.y * bUse

                if totalX == machine.prize.x && totalY == machine.prize.y && totalCost < minCost {
                    minCost = totalCost
                }
            }
        }

        if minCost < 1_000_000_000_000 {
            totalCost += minCost
        }
    }
    return totalCost
}

/// Solved for
/// ax + by = c
/// dx + ey = f
///
/// Where x is the number of times a is pressed, and y is the number of times b is pressed
/// c is the prize x and f is the prize y
func getTotalCostPart2(machines: [Machine]) -> Int {
    var totalCost = 0
    for machine in machines {
        let a = Double(machine.a.x)
        let b = Double(machine.b.x)
        let c = Double(machine.prize.x + 10_000_000_000_000)
        let d = Double(machine.a.y)
        let e = Double(machine.b.y)
        let f = Double(machine.prize.y + 10_000_000_000_000)
        let denom = a * e - b * d
        if denom == 0 { continue }

        let aPresses = (c * e - b * f) / denom
        let bPresses = (a * f - c * d) / denom
        let aPressesInt = Int(aPresses)
        let bPressesInt = Int(bPresses)
        if abs(aPresses - Double(aPressesInt)) < 1e-9 && abs(bPresses - Double(bPressesInt)) < 1e-9
            && aPresses >= 0 && bPresses >= 0
        {
            totalCost += aPressesInt * machine.a.cost + bPressesInt * machine.b.cost
        }
    }
    return totalCost
}

let machines = parseInput(fileName: CommandLine.arguments[1])
machines.forEach({
    machine in
    print(machine)
})

let totalCostPart1 = getTotalCostPart1(machines: machines)
print("Total Cost Part 1: \(totalCostPart1)")

let totalCostPart2 = getTotalCostPart2(machines: machines)
print("Total Cost Part 2: \(totalCostPart2)")
