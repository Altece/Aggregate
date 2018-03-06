import XCTest
@testable import Aggregate

class AggregateTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    @objc func testEmptyAggregate() {
        let agg = Aggregate(of: [])
        let message = "The empty aggregate shouldn't conform to anything except the NSObject protocol."
        XCTAssertFalse(agg.conforms(to: Animal.self), message)
        XCTAssertFalse(agg.conforms(to: EggLayer.self), message)
        XCTAssertTrue(agg.conforms(to: NSObjectProtocol.self), "The empty aggregate should always conform to the NSObject protocol.")
    }

    @objc func testOneTargetAggregate() {
        let dog = Dog()
        let agg = Aggregate(of: [dog])
        XCTAssertTrue(agg.conforms(to: Animal.self), "An aggregate of a target conforming to a protocol should also conform to that protocol.")
        XCTAssertFalse(agg.conforms(to: EggLayer.self), "Aggregates shouldn't conform to protocols they're targets don't conform to.")
        XCTAssertTrue(agg.conforms(to: NSObjectProtocol.self), "All aggregates should conform to the NSObject protocol.")

        XCTAssertTrue(agg.responds(to: #selector(getter: Animal.sound)), "Aggregates should respond to their targets' selectors.")
        XCTAssertFalse(agg.responds(to: #selector(EggLayer.layEgg)), "Aggregates should respond only to selectors for themselves or their targets.")

        guard let animal = agg as? Animal else {
            XCTFail("Casting an aggregate to its conforming protocol types should always succeed.")
            return
        }
        XCTAssertEqual(animal.sound, dog.sound, "Aggregates should forward calls to their targets.")
    }

    @objc func testTwoTargetAggregate() {
        let dog = Dog()
        let duck = Duck()
        let agg = Aggregate(of: [dog, duck])
        let message1 = "An aggregate of a target conforming to a protocol should also conform to that protocol."
        XCTAssertTrue(agg.conforms(to: Animal.self), message1)
        XCTAssertTrue(agg.conforms(to: EggLayer.self), message1)
        XCTAssertTrue(agg.conforms(to: NSObjectProtocol.self), "All aggregates should conform to the NSObject protocol.")

        let message2 = "Aggregates should respond to their targets' selectors."
        XCTAssertTrue(agg.responds(to: #selector(getter: Animal.sound)), message2)
        XCTAssertTrue(agg.responds(to: #selector(EggLayer.layEgg)), message2)

        guard let platypus = agg as? Animal & EggLayer else {
            XCTFail("Casting an aggregate to its conforming protocol types should always succeed.")
            return
        }
        let message3 = "Aggregates should forward calls the first target which responds to the called selector."
        XCTAssertEqual(platypus.sound, dog.sound, message3)
        XCTAssertNotEqual(platypus.sound, duck.sound, message3)
        XCTAssertEqual(platypus.layEgg(), duck.layEgg(), "Aggregates should forward calls to their targets.")
    }
}

// MARK: - Example Protocols

@objc protocol Animal {
    var sound: String { get }
}

@objc protocol EggLayer {
    func layEgg() -> String
}

// MARK: - Example Classes

@objc class Dog: NSObject, Animal {
    var sound: String { return "Bark!" }
}

@objc class Duck: NSObject, Animal, EggLayer {
    var sound: String { return "Quack!" }
    func layEgg() -> String { return "Five fresh eggs!" }
}
