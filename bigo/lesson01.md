A Pragmatist’s Guide to Big O Notation
======================================

Lesson 1: Introduction
----------------------

In this lesson:
- You'll understand why Big O is useful to programmers
- Get some basic understanding of **constant time** versus **linear time**

---

**Your co-workers:** A bunch of Computer Science grads who graduated from various impressive universities. Software Engineering is something they only learned in theory at first but have applied those abstract concepts to real-world applications with good effect.

**You:** A smart person who, through sheer force of will, have established yourself as a Pretty Okay® self-taught developer. To you, Software Development is less of a field of a study and more of a trade. Nails? That’s your programming language. Hammer? That’s git. When things don’t work you have no qualms with rolling up your sleeves and diving deep into the inner workings of codebases. You might not know exactly why things are the way they are, but you have great intuition. 

If this sound familiar, give yourself a pat on the back. You took the hard route. Don’t diminish your accomplishments only because the School of Life doesn’t give out framed pieces of paper. This paper is for people like you. It’s goal is to be an easy-to-digest guide to Big O Notation for self-taught developers. Explicitly: 

- I'll be using mathematical terminology only when absolutely necessary. I'm not here to impress you, I'm here to teach you. 
- When I do use mathematical terminology, I'll do my best to explain it. 
- Always use a concrete example when explaining a concept with runnable code. Sometimes its easier to learn by doing. 
- Give examples of how certain concepts are useful in your day-to-day job. 

Now, let’s learn about Big O Notation. 

---

Let me propose a problem to you: Let's say you had the following piece of code and your boss wanted to know how fast it was. 

```ruby
# is_even.rb
def is_even?(number)
    number % 2 == 0
end

puts is_even?(ARGV[0].to_i)
```

Easy! So you fire up your terminal and run the following.

```
$ time ruby is_even.rb 2
true
ruby is_even.rb 2  0.06s user 0.01s system 84% cpu 0.084 total
```

Great! You send your findings to your boss and call it a day. Unfortunately, next morning you come into the office to an email.

```
to: The Reader <the.reader@megacorp.co>
from: Big Boss <big.boss@megacorp.co>
subject: is_even.rb performance

Reader,

You said that is_even.rb takes only 0.084 seconds to run, but I've got
DevOps telling me we're getting drastically different numbers from our
live servers. Do you mind telling me what could've gone wrong?

- Big Boss
```

Damn, Big Boss is right. As a self-taught developer you know intuitively that this code will never be extremely slow (it only does one thing!), but it's hard to describe exactly what your boss can expect without factoring the discrepancy of performance between computers.

This is where Big O comes in. **Big O generically describes the time it takes an algorithm to run, without factoring in individual CPU speed.** It can also measure space, but we'll get into that later.

The code above is O(1) in Big O notation, which is often referred to as **constant time**. This is because the code only does one thing, so hence the "1." Alternatively, if your boss had given you this code instead:

```ruby
# sum_of_evens.rb
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
```

You can immediately see that it does more than one thing (it iterates between 0 and the number passed into `ARGV`). In this case, the Big O notation would be O(n), because it does `n` things. O(n) is also called **linear time**.

Let's run a few comparative tests between `is_even?` and `sum_of_evens`.

```
$ time ruby is_even.rb 1
false
ruby is_even.rb 1  0.06s user 0.01s system 92% cpu 0.075 total

$ time ruby is_even.rb 100
true
ruby is_even.rb 100  0.06s user 0.01s system 96% cpu 0.077 total

$ time ruby is_even.rb 1000000
true
ruby is_even.rb 1000000  0.06s user 0.01s system 96% cpu 0.081 total

$ time ruby sum_of_evens.rb 1
0
ruby sum_of_evens.rb 1  0.06s user 0.01s system 88% cpu 0.076 total

$ time ruby sum_of_evens.rb 100
2550
ruby sum_of_evens.rb 100  0.06s user 0.01s system 97% cpu 0.084 total

$ time ruby sum_of_evens.rb 1000000
250000500000
ruby sum_of_evens.rb 1000000  0.13s user 0.01s system 92% cpu 0.153 total
```

Whoa, what the heck happened? When we passed 1,000,000 to `sum_of_evens` it almost doubled in runtime, whereas it remained relatively **constant** with `is_even?`. This underscores the most important and useful feature of Big O; **Big O describes how the runtime of an algorithm grows as its input gets bigger.** (Again, it can also describe how space grows, but don't worry about this now.)

Have you ever written a feature that totally busted once your website had 100,000 users versus 100? You probably didn't take into consideration how a particular piece of code (most likely a database query) would grow as you got more users.

---

Key takeaways:
- Big O generically describes the time it takes an algorithm to run, without factoring in individual CPU speed
- Big O describes how the runtime of an algorithm grows as its input gets bigger
- O(1), or constant time, is code that doesn't take longer to run on larger inputs
- O(n), or linear time, is code in which runtime grows linearly with larger inputs

---

In Lesson 2 we'll be diving into all the different categories of runtimes for Big O, from O(1) to O(n!). In the meantime, let me give you this teaser problem:

Is the following code O(1), O(n), or something else?

**Hint:** Is *constant* and not growing? Is it growing *linearly*?

```ruby
# fib.rb
def fib(n)
    if n < 2
        n
    else
        fib(n - 2) + fib(n - 1)
    end  
end

puts fib(ARGV[0].to_i)
```

```
$ time ruby fib.rb 1
1
ruby fib.rb 1  0.07s user 0.01s system 96% cpu 0.082 total

$ time ruby fib.rb 10
55
ruby fib.rb 10  0.06s user 0.01s system 96% cpu 0.078 total

$ time ruby fib.rb 20
6765
ruby fib.rb 20  0.07s user 0.01s system 96% cpu 0.083 total

$ time ruby fib.rb 30
832040
ruby fib.rb 30  0.15s user 0.01s system 98% cpu 0.168 total

$ time ruby fib.rb 40
102334155
ruby fib.rb 40  11.12s user 0.02s system 99% cpu 11.152 total
```
