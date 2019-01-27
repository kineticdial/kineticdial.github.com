---
layout: post
title:  "How Quasa.rs Utilizes Blue/Green Deployments"
date:   2019-01-18
categories: ruby
---

I am the creator and administrator of [quasa.rs][quasars], a social
link-sharing web application (like reddit or hackernews) for
astrophysics. It’s a fun side project that keeps me from getting rusty
with Ruby on Rails because, sadly, I don’t use Ruby for my day job
anymore. Plus I get to talk and think about space! What’s more fun
than that?

Because quasa.rs is a side project, it was important to keep its
server costs low. However, just having a single box wasn’t an
acceptable solution either: Quasa.rs does have some users, so I need
to have some way to prevent downtime during deployments. With that in
mind, I thought that Blue/Green Deployments would be the best
deployment strategy for quasa.rs.

[Martin Fowler explains Blue/Green Deployments better than I could
ever do here][fowler], but i’ll try to explain it briefly here for the
unaware. Essentially, you have two production environments—one “green”
and one “blue.” A floating IP or load balancer would route production
traffic to whichever environment was “active,” therefore making the
other environment the “idle” environment. Whenever you start a
deployment, you deploy to whichever environment is currently the
“idle” one, verify that the deployment was successful, and then toggle
your floating IP or load balancer to start routing production traffic
to it and thereby making it the “active” environment. When you make
the switch, of course, the old “active” environment becomes “idle.”

Let me show you how quasa.rs specifically does this and hopefully
that’ll make things clearer.

![Quasars' infrastructure](https://cdn-images-1.medium.com/max/1600/1*6VFphOxxewUvRcoPhnI6iw.png)

As you can see, requests to `quasa.rs` get routed to a floating IP that
currently points to the `quasars-app-green` box. If we were to start a
new deployment, we would deploy to `quasars-app-blue`, run any
verifications we deem necessary, and then toggle the floating IP to
point to `quasars-app-blue`.

This has several advantages.

* If the deploy goes badly, we can always flip the floating IP back to the
  original box while keeping the bad deployment in an unaltered state to
  investigate.
* Both our “production” and “staging” environments take
  turns receiving real production traffic, assuring that our staging
  environment will never be stale or deviate from production.
* In our case, we can run migrations and verifications on the box we
  deployed to without interrupting user traffic.
* If I suddenly need scale, I can always swap out the floating IP with a
  load balancer and serve requests to both environments (does require manually
  asserting that both environments have the same deployment version which is
  less-than-ideal).
* For roughly $15/month I can have an active-active setup.

You may have noticed that both `quasars-app-green` and
`quasars-app-blue` connect to the same database `quasars-db`. While
Martin Fowler mentions this strategy as a provision, it is not the
standard way he diagrams it. Instead, he has two separate databases,
one for each environment. However, I decided against this for a couple
reasons.

For starters, adding another database would increase my monthly costs
by another $5, which was not ideal for a hobby project. If I felt like
it was necessary to have it anyways, though, I would also have to
figure out how to reconcile the two databases in an
eventually-consistent manner. Something I felt was out of scope for a
small web application. For my purposes, just having one database has
been perfect.

I still have a few corners to button up—for example, I still manually
toggle the floating IP in DigitalOcean’s dashboard instead of having
that step be automated—but otherwise this deployment strategy has
worked great for a small project. In fact, I suspect that this would
be a great way to get a startup’s application off the ground in a
relatively inexpensive manner. It scales well too, as you can have
each environment be a self-contained cluster of boxes behind a load
balancer instead of a solitary box.

Thanks for reading and feel free to sign up at [quasa.rs][quasars] if
astrophysics and space interest you!

_[This post is mirrored on Medium][medium]._

---

**Update:** I recently made changes so that floating IP assignment is
completely automated during deployments. [Check out the PR here][pr]!

[quasars]: https://quasa.rs
[fowler]: https://martinfowler.com/bliki/BlueGreenDeployment.html
[pr]: https://github.com/kineticdial/quasars/pull/36/files
[medium]: https://medium.com/kinetic-dial/how-quasa-rs-utilizes-blue-green-deployments-d5557a0a12b8
