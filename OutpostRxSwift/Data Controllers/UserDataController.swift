
import Foundation
import RealmSwift
import RxSwift
import RxRealm

protocol UserDataServiceType {
    @discardableResult
    func create(name: String, email: String) -> Observable<User>
    
    @discardableResult
    func fetchCurrentUser(syncUser: SyncUser) -> Observable<User?>
}

struct UserDataController {
    
    typealias ModelType = User
    
    fileprivate func withRealm<T>(_ operation: String, action: (Realm) throws -> T) -> T? {
        do {
            let realm = try Realm(configuration: RealmConfig.common.configuration)
            return try action(realm)
        } catch let err {
            print("Failed \(operation) realm with error: \(err)")
            return nil
        }
    }
    
}

extension UserDataController: UserDataServiceType {
   
    func create(name: String, email: String) -> Observable<User> {
        let result = withRealm("creating") { realm -> Observable<User> in
            guard let syncUser = SyncUser.current else {
                return .error(RealmServiceError<User>.creationFailed)
            }
            let user = User(syncUser: syncUser, userName: name, email: email)
            try realm.write {
                realm.add(user)
            }
            return .just(user)
        }
        return result ?? .error(RealmServiceError<User>.creationFailed)
    }
    
    func fetchCurrentUser(syncUser: SyncUser) -> Observable<User?> {
        let result = withRealm("getting current user") { realm -> Observable<User?> in
            //let realm = try Realm(configuration: RealmConfig.common.configuration)
            print("Sync user id: \(syncUser.identity!)")
            let count = realm.objects(User.self)
            print("user count: \(count.count)")
            let user = realm.object(ofType: User.self, forPrimaryKey: syncUser.identity!)
            //let user = realm.objects(User.self).filter(NSPredicate(format: "uid = %@", syncUser.identity!)).first
            print("\(String(describing: user?.email))")
            return .just(user)
        }
        return result ?? .empty()
    }
    
}
