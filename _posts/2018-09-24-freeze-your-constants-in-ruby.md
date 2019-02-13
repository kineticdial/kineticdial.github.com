---
layout: post
title:  "Freeze Your Constants in Ruby"
date:   2018-09-24
categories: ruby
---



Years ago I was working on a very large Ruby on Rails codebase that used
constants to hold lists of credit card transaction states. For example:

```ruby
# example 1
class Txn
  ACTIONABLE_STATES = [:authenticated, :to_settle]
  DONE_STATES = [:settled, :declined]

  # ...
end
```

However, we had a bug in which a settled transaction could pass a `txn.state.in? ACTIONABLE_STATES`
check. After hours of searching, we found the offending code in a completely different part of the
codebase.

```ruby
# example 2
all_states = ACTIONABLE_STATES.concat(DONE_STATES)

all_states.each do |state|
  # ...
end
```

If you're already knowledgeable of the Ruby `Array` class, you've probably spotted the offending line already.
`#concat` mutates the original list, even though it doesn't end with the idiomatic `!`, and because
`ACTIONABLE_STATES` is held statically in memory, when this code gets executed it changes
`ACTIONABLE_STATES` state for the rest of that Ruby virtual machine's life.

In other words, after `example 2` gets executed, `ACTIONABLE_STATES` becomes
`[:authenticated, :to_settle, :settled, :declined]` until you reboot the server.

If you have multiple Ruby boxes running behind a Load Balancer (as we did), this can further obfuscate
the problem. Because `example 2` might only have been run on certain boxes, you might get cases where one
request will not exhibit the bug while another identical one will.

The solution? **Freeze your constants.**

```ruby
# example 3
ACTIONABLE_STATES = [:authenticated, :to_settle].freeze
DONE_STATES = [:settled, :declined].freeze
```

This would cause `example 2` to produce a `can't modify frozen array (RuntimeError)`, and if you've unit tested
`example 2`, you would've hopefully caught this before it was ever even deployed.

_[Discuss on Lobste.rs](https://lobste.rs/s/9bxh5m/freeze_your_constants_ruby)_

_[This post is mirrored on Medium](https://medium.com/kinetic-dial/freeze-your-constants-in-ruby-49e3238c19ef)_
