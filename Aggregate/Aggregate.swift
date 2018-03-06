import Foundation

/// A dynamic object which can disguise multiple objects as one whole unit.
///
/// This can be useful for dividing large protocol implementations into separate objects,
/// and then combining them here to pass to a client as a single delegate, data source, or object.
///
/// - note: `Aggregate` only works with Objective-C exposed classes, protocols, and methods.
@objc(AGGAggregate)
open class Aggregate: NSObject {
    private var needsUpdateConformingProtocols: Bool = true
    private var _conformingProtocols: [Protocol] = [] {
        didSet { needsUpdateConformingProtocols = false }
    }

    /// An array of objects that implement parts of the desired behavior of the whole aggregate.
    /// - note: The order of the targets in the array denotes the calling prioritization for
    ///         composed objects with duplicate method implementations, where the first target
    ///         has the highest prioritization.
    @objc open var targets: [NSObject] {
        didSet { needsUpdateConformingProtocols = true }
    }

    /// An array of all protocols implemented by this aggregate's targets.
    /// - note: This property's value will be lazily updated at some point after any change
    ///         to the `targets` property.
    @objc open var conformingProtocols: [Protocol] {
        guard needsUpdateConformingProtocols else { return _conformingProtocols }
        let dict = targets.reduce(into: [:] as [ObjectIdentifier : Protocol]) { dict, target in
            let count = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
            guard let targetClass = object_getClass(target) as AnyClass?,
                  let protocols = class_copyProtocolList(targetClass, count)
                else { return }
            (0 ..< count.pointee).forEach { index in
                let p = protocols[Int(index)]
                let identifier = ObjectIdentifier(p)
                if nil == dict[identifier] { dict[identifier] = p }
            }
        }
        _conformingProtocols = Array(dict.values)
        return _conformingProtocols
    }

    @objc public convenience override init() {
        self.init(of: [])
    }

    /// Create a new aggregate object, which will be composed of the behavior from the given
    /// targets array.
    /// - parameter targets: An array of objects that implement parts of the desired behavior of
    ///                      the resulting whole aggregate object.
    /// - note: The order of the targets in the array denotes the calling prioritization for
    ///         composed objects with duplicate method implementations, where the first target
    ///         has the highest prioritization.
    @objc public init(of targets: [NSObject]) {
        self.targets = targets
    }

    override open func conforms(to aProtocol: Protocol) -> Bool {
        for t in targets {
            if t.conforms(to: aProtocol) { return true }
        }
        return super.conforms(to: aProtocol)
    }

    override open func responds(to aSelector: Selector!) -> Bool {
        for t in targets {
            if t.responds(to: aSelector) { return true }
        }
        return super.responds(to: aSelector) || NSObject.instancesRespond(to: aSelector)
    }

    override open func forwardingTarget(for aSelector: Selector!) -> Any? {
        for t in targets {
            if t.responds(to: aSelector) { return t }
        }
        return super.forwardingTarget(for: aSelector)
    }

    override open var description: String {
        let targetNames = targets.map { $0.description }
        let protocolNames = conformingProtocols.map { String(cString: protocol_getName($0)) }
        return "<Aggregate of [\(targetNames.joined(separator: ", "))]" + " "
            + "conforms to [\( protocolNames.joined(separator: ", ") )]>"
    }
}
