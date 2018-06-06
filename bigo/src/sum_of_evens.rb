def sum_of_evens(number)
    result = 0
    (0..number).each do |n|
        if n % 2 == 0
            result += n
        end
    end
    result
end

puts sum_of_evens(ARGV[0].to_i)