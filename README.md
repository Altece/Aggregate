Aggregate
=========

`Aggregate` is an object which can compose protocol implementations from various objects
This can be useful for dividing large protocol implementations into separate objects,
and then combining them here to pass to a client as a single delegate, data source, or object.

```swift
import Aggregate

@objc protocol Foo {
    func doThis()
}

@objc protocol Bar {
    func doThat()
}

@objc EagerBeaver: NSObject, Foo {
    func doThis() {
        print("I did this!")
    }
}

@objc Underachiever: NSObject, Foo, Bar {
    func doThis() {
        print("Do I have to do this?")
    }

    func doThat() {
        print("Do I have to do that?")
    }
}

let averageJoe = Aggregate(of: [EagerBeaver(), Underachiever()]) as! Foo & Bar

averageJoe.doThis() // prints "I did this!"
averageJoe.doThat() // prints "Do I have to do that?"
```

It is important to note that the order of objects in the `targets` array denotes the calling 
order for composed objects with duplicate method implementations, where the first target
has the highest prioritization. This is why `Underachiever`'s `doThis` implementation wasn't
called in the previous example.
