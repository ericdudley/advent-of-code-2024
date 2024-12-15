
class Problem
    attr_accessor :target
    attr_accessor :nums

    def initialize(target:, nums:)
        @target = target
        @nums = nums
    end

    def print
        puts "#{@target} = #{@nums}"
    end

    def isPossible(ops:)
        total = @nums[0]
        ops.each_with_index { |op, idx|
        if op == "+"
            total += @nums[idx + 1]
        elsif op == "*"
            total *= @nums[idx + 1]
        elsif op == "||"
            total = Integer("#{total}#{@nums[idx + 1]}")
        end
    }


        if ops.length == @nums.length - 1
            return total == @target
        elsif total > @target
            return false
        else
            return self.isPossible(ops: ops + ["+"]) || 
                self.isPossible(ops: ops + ["*"]) ||
                self.isPossible(ops: ops + ["||"])
        end
    end
end

def parse_input(file_name)
    problems = []
    File.foreach(file_name) { |line| 
        parts = line.split(":")
        target = Integer(parts[0])
        nums_parts = parts[1].split(" ")
        nums = nums_parts.map(){ |num_string| num_string.to_i }
        problems.append(Problem.new(target: target, nums: nums))
    }
    return problems
end
 
problems = parse_input(ARGV[0])
puts "Part 1 (#{problems.length} problems)"
count = 0
possible_problems = problems.select { |problem| 
    puts "Running #{count} of #{problems.length}"
    count += 1
    problem.isPossible(ops: []) 
}
possible_target_sum = possible_problems.map { |problem| problem.target }.reduce(0, :+)
puts "Possible Target Sum: #{possible_target_sum}"