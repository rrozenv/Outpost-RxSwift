
import Foundation
import RealmSwift
import RxDataSources

class User: Object {
    @objc dynamic var uid: String = ""
    @objc dynamic var userName: String = ""
    @objc dynamic var email: String = ""
    @objc dynamic var createdAt = Date()
    
    override class func primaryKey() -> String? {
        return "uid"
    }
    
    convenience init(syncUser: SyncUser, userName: String, email: String) {
        self.init()
        self.uid = syncUser.identity ?? ""
        self.userName = userName
        self.email = email
    }
    
    func set(values: [String: Any]) {
        self.setValue(values["name"], forKey: "name")
        self.setValue(values["email"], forKey: "email")
    }
}


