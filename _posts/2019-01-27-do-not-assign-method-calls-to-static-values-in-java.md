---
layout: post
title:  "Don’t assign method calls to static values in Java"
date:   2019-01-27
categories: java
---

Assigning method calls to static values can be perilous. Let’s take a look at an example Java class to examine exactly why:

```java
/**
 * Foo.java
 */

public class Foo {
    public static String foo = Config.getInstance().getFoo();
}
```

Seems pretty innocuous in itself, but ostensibly we’re just assigning a `Config` singleton call to a static value in `Foo`. For our purposes, assume `Config` has both setters and getters for values we want to store configurations for. In my experience, these configuration objects are a pretty common pattern and can be handily dependency injected for ease of testing (note how we’re _not_ doing that here).

However, this code can behave quite unexpectedly if you’re not careful. The below test suite exemplifies this:

```java
/**
 * FooTest.java
 */

import org.junit.Test;

public class FooTest {
    @Test
    public void TestSetFooA() {
        Config.getInstance().setFooConfig("bar");
        assert Foo.foo == "bar";
    }

    @Test
    public void TestSetFooB() {
        Config.getInstance().setFooConfig("fizz");
        assert Foo.foo == "fizz";
    }
}
```

Each test does performs the exact same behavior:

1. Set the `foo` configuration to a string value.
2. Tests to see if that configuration is properly read from `Foo.foo`.

These tests pass if you run each test in isolation. Unfortunately, when we run the entire suite we get a failure on the second test case.

This is because `Foo.foo` still contains the value that the first test case set for it (specifically, `"bar"`). Because `Foo.foo` is a static value, it is only set the first time the Foo class is put in memory (in our case, the second line of the first test case). For as long as the JVM exists thereafter, that value will always be the same. Why? Well, because it’s _static_.

So what if we want the `Foo.foo` value to read from its configuration each time? We have two options that I like.

Firstly, we could use a static _method_ instead of a static _value_.

```java
/**
 * Foo.java
 */

public class Foo {
    public static String foo() {
        return Config.getInstance().getFoo();
    }
}
```

A static method will perform the logic inside of it each time it is called, therefore picking up any change to our configuration object. However, I still don’t think this is the best possible solution.

I foreshadowed dependency injection above, which in my opinion, is the most elegant solution. Here’s an example of what I mean:

```java
/**
 * Foo.java
 */

public class Foo {
    public static String foo(Config config) {
        return config.getFoo();
    }
}
```

This allows us to inject a mock of the `Config` object in our tests which also gives us the benefit of not having to mutate global state in a singleton (an anti-pattern in itself. Our test suite gets a much-needed facelift after this change:

```java
/**
 * FooTest.java
 */

import org.junit.Test;
import static org.mockito.Mockito.*;

public class FooTest {
    @Test
    public void TestSetFooA() {
        Config mockedConfig = mock(Config.class);
        when(mockedConfig.getFoo()).thenReturn("bar");

        assert Foo.foo(mockedConfig) == "bar";
    }

    @Test
    public void TestSetFooB() {
        Config mockedConfig = mock(Config.class);
        when(mockedConfig.getFoo()).thenReturn("fizz");

        assert Foo.foo(mockedConfig) == "fizz";
    }
}
```

To summarize:
- Never assign a method call to a static value. Use static values for exactly that: _values_ (strings, integers, etc).
- Consider using dependency injection for configuration objects. Mock these objects in your tests.
- Consider avoiding using singletons when possible. [Here’s a great Stack Overflow thread on exactly why][so].

_[This post is mirrored on Medium](https://medium.com/kinetic-dial/dont-assign-method-calls-to-static-values-in-java-35563304fc4d)_.

[so]: https://stackoverflow.com/questions/137975/what-is-so-bad-about-singletons
