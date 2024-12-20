const fs = require('fs');

function parseInput(fileName) {
    try {
        const fileContent = fs.readFileSync(fileName, 'utf-8');
        const lines = fileContent.split('\n').map(line => line.trim()).filter(line => line.length > 0);
        const nums = lines.flatMap(line => line.split(' ')).map(val => Number(val))
        let head = createNode({ val: nums[0] });
        let cursor = head;
        for (let i = 1; i < nums.length; i += 1) {
            const newNode = createNode({ prev: cursor, val: nums[i] });
            cursor.next = newNode;
            cursor = newNode;
        }
        return head;
    } catch (error) {
        console.error(`Error reading the file: ${error.message}`);
        process.exit(1);
    }
}

function createNode(args = {
    prev: null,
    next: null,
    val: null
}) {
    let prev = args.prev;
    let next = args.next;
    let val = args.val;

    return {
        prev,
        next,
        val,
        print: function () {
            let strs = [this.val];
            let cursor = this.next;
            while (cursor) {
                strs.push(cursor.val);
                cursor = cursor.next;
            }
            console.log(`(${strs.length} stones) ${strs.join(' ').substring(0, 100)}`)
        },
        handleBlink: function () {

            let head = this;

            let cursor = this;
            while (cursor) {
                const stringVal = String(cursor.val);
                if (cursor.val === 0) {
                    cursor.val = 1;
                    cursor = cursor.next;
                } else if (stringVal.length % 2 === 0) {
                    let currentNext = cursor.next;

                    // Split string for number in 2 and create two new nodes, one for each half
                    const leftVal = Number(stringVal.substring(0, stringVal.length / 2))
                    const rightVal = Number(stringVal.substring(stringVal.length / 2));
                    const leftNode = createNode({ val: leftVal });
                    const rightNode = createNode({ val: rightVal });

                    // Update neighbors
                    if (cursor.prev) {
                        cursor.prev.next = leftNode;
                        leftNode.prev = cursor.prev;
                    }
                    if (cursor.next) {
                        cursor.next.prev = rightNode;
                        rightNode.next = cursor.next;
                    }

                    // Point at each other
                    leftNode.next = rightNode;
                    rightNode.prev = leftNode;

                    // Update head and cursor
                    if (cursor === this) {
                        head = leftNode;
                    }
                    cursor = currentNext;

                } else {
                    cursor.val = cursor.val * 2024;
                    cursor = cursor.next;
                }

            }

            return head;
        }
    }
}

function part1Solution() {
    const args = process.argv.slice(2);

    const fileName = args[0];
    let head = parseInput(fileName);
    head.print();

    const blinks = Number(args[1]);

    for (let i = 0; i < blinks; i += 1) {
        console.log(`Blink ${i + 1}:`)
        head = head.handleBlink();
        head.print();
    }
}

function part2Solution() {
    const args = process.argv.slice(2);

    const fileName = args[0];
    let head = parseInput(fileName);
    head.print();

    const blinks = Number(args[1]);

    const counts = {};
    let cursor = head;
    while (cursor) {
        counts[cursor.val] = 1;
        cursor = cursor.next
    }
    for (let i = 0; i < blinks; i += 1) {
        console.log(`Blink ${i + 1}:`)
        const keys = Array.from(Object.keys(counts));
        const originalCounts = {
            ...counts
        }
        for (let num of keys) {
            const testNode = createNode({ val: Number(num) })
            let cursor = testNode.handleBlink();
            while (cursor) {
                if (!counts[cursor.val]) {
                    counts[cursor.val] = 0;
                }
                counts[cursor.val] += originalCounts[num];
                cursor = cursor.next;
            }
            counts[num] -= originalCounts[num]
            if (counts[num] === 0) {
                delete counts[num]
            }
        }
        console.log(`(${Array.from(Object.keys(counts)).reduce((sum, num) => {
            return sum + counts[num]
        }, 0)} stones) ${JSON.stringify(counts).substring(0, 120)}`)
    }
}

part2Solution();
