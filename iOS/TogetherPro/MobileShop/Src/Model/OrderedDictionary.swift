import Foundation

/// Ordered dictionary struct
struct OrderedDictionary<Key: Hashable, Value> {
    var keys: Array<Key> = []
    var values: Dictionary<Key,Value> = [:]
    
    var count: Int {
        return self.keys.count;
    }

    init() {}
    
    subscript(index: Int) -> Value? {
        get {
            let key = self.keys[index]
            return self.values[key]
        }
        set(newValue) {
            let key = self.keys[index]
            if newValue != nil {
                self.values[key] = newValue
            } else {
                self.values.removeValueForKey(key)
                self.keys.removeAtIndex(index)
            }
        }
    }
    
    subscript(key: Key) -> Value? {
        get {
            return self.values[key]
        }
        set(newValue) {
            if newValue == nil {
                self.values.removeValueForKey(key)
                self.keys = self.keys.filter {$0 != key}
            }
            
            let oldValue = self.values.updateValue(newValue!, forKey: key)
            if oldValue == nil {
                self.keys.append(key)
            }
        }
    }
}
