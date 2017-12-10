
import Foundation
import RealmSwift
import RxDataSources

class Prompt: Object {
    @objc dynamic var uid: Int = 0
    @objc dynamic var title: String = ""
    @objc dynamic var body: String = ""
    @objc dynamic var imageUrl: String = ""
    @objc dynamic var createdAt = Date()
    
    override class func primaryKey() -> String? {
        return "uid"
    }

    convenience init(title: String, body: String, imageUrl: String) {
        self.init()
        self.title = title
        self.body = body
        self.imageUrl = imageUrl
    }
    
    func set(values: [String: Any]) {
        self.setValue(values["title"], forKey: "title")
        self.setValue(values["body"], forKey: "body")
        self.setValue(values["imageUrl"], forKey: "imageUrl")
    }
}

extension Prompt: IdentifiableType {
    var identity: Int {
        return self.isInvalidated ? 0 : uid
    }
}


