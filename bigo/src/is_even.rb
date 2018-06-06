def is_even?(number)
    number % 2 == 0
end

puts is_even?(ARGV[0].to_i)