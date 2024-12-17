function parse_input(file_name)
    local buf = {}
    for line in io.lines(file_name) do
        for i = 1, #line do
            buf[i] = tonumber(line:sub(i, i))
        end
    end

    return buf
end

function print_arr(arr)
    for i = 1, #arr do
        if arr[i] < 0 then
            io.write('.', '|')
        else
            io.write(arr[i], '|')
        end
    end
    print('')
end

function expand_notation(buf)
    local exp = {}

    local id = 0
    for i = 1, #buf do
        if i % 2 == 0 then
            for _ = 1, buf[i] do
                table.insert(exp, -1)
            end
        else
            for _ = 1, buf[i] do
                table.insert(exp, id)
            end
            id = id + 1
        end
    end

    return exp
end

function compact_part1(exp)
    local com = {}
    for i = 1, #exp do
        table.insert(com, exp[i])
    end

    local left = 1
    local right = #com

    while true do
        if left >= right then
            return com
        end

        while left < right and com[left] >= 0 do
            left = left + 1
        end
        if left >= right then
            return com
        end

        while left < right and com[right] < 0 do
            right = right - 1
        end
        if left >= right then
            return com
        end

        com[left] = com[right]
        com[right] = -1
    end
end

function compact_part2(exp)
    local com = {}
    for i = 1, #exp do
        table.insert(com, exp[i])
    end

    local right = #com

    local next_moved_file = -1
    for i = #com, 1, -1 do
        if com[i] >= 0 then
            next_moved_file = com[i]
            break
        end
    end
    print("next_moved_file", next_moved_file)

    while next_moved_file >= 0 do
        print("\nnext_moved_file", next_moved_file)
        -- print_arr(com)
        if right < 1 then
            return com
        end

        local file_start = #com
        local file_end = 1
        while file_start > file_end and com[file_start] ~= next_moved_file do
            file_start = file_start - 1
        end
        while file_end < file_start and com[file_end] ~= next_moved_file do
            file_end = file_end + 1
        end

        local file_len = file_start - file_end + 1

        -- print("file_start", file_start, "file_end", file_end, "file_len", file_len)

        local free_start = 1
        while free_start <= file_end do
            while free_start <= #com and com[free_start] >= 0 do
                free_start = free_start + 1
            end

            local free_end = free_start
            while free_end <= #com and (free_end - free_start) < file_len and com[free_end] < 0 do
                free_end = free_end + 1
            end
            local free_len = free_end - free_start


            -- print("free_start", free_start, "free_end", free_end, "free_len", free_len)

            if free_len >= file_len and free_end <= file_start then
                for i = 0, free_len - 1 do
                    com[free_start + i] = com[file_start - i]
                    com[file_start - i] = -1
                end
                break
            else
                free_start = free_end
            end
        end
        next_moved_file = next_moved_file - 1
    end

    return com
end

function compute_sum(com)
    sum = 0
    for i = 1, #com do
        if com[i] < 0 then
            goto continue
        end

        sum = sum + (i - 1) * com[i]
        ::continue::
    end

    return sum
end

local buf = parse_input(arg[1])
print("\nInput:")
print_arr(buf)

local exp = expand_notation(buf)
print("\nExpanded:")
print_arr(exp)

local com1 = compact_part1(exp)
print("\nCompacted part 1:")
print_arr(com1)

local com2 = compact_part2(exp)
print("\nCompacted part 2:")
print_arr(com2)

local sum1 = compute_sum(com1)
print("\nSum part 1: ", sum1)

local sum2 = compute_sum(com2)
print("\nSum part 2: ", sum2)