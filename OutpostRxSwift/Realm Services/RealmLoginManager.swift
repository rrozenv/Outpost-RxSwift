
import Foundation
import RealmSwift
import RxSwift

struct Constants {
    static let defaultSyncHost = "192.168.1.4"
    static let syncAuthURL = URL(string: "http://\(defaultSyncHost):9080")!
    static let syncServerURL = URL(string: "realm://\(defaultSyncHost):9080/")
    static let commonRealmURL = URL(string: "realm://\(defaultSyncHost):9080/CommonRealm")!
    static let privateRealmURL = URL(string: "realm://\(defaultSyncHost):9080/~/privateRealm")!
    static let temporaryRealmURL = URL(string: "realm://\(defaultSyncHost):9080/~/temporaryRealm")!
}

enum RealmConfig {
    
    case common
    case secret
    case temporary
    
    var configuration: Realm.Configuration {
        switch self {
        case .common:
            return RealmConfig.commonRealmConfig(user: SyncUser.current!)
        case .secret:
            return RealmConfig.privateRealmConfig(user: SyncUser.current!)
        case .temporary:
            return RealmConfig.temporaryRealmConfig(user: SyncUser.current!)
        }
    }
    
    private static func commonRealmConfig(user: SyncUser) -> Realm.Configuration  {
        let config = Realm.Configuration(syncConfiguration: SyncConfiguration(user: SyncUser.current!, realmURL: Constants.commonRealmURL), objectTypes: [Prompt.self, User.self])
        return config
    }
    
    private static func privateRealmConfig(user: SyncUser) -> Realm.Configuration  {
        let config = Realm.Configuration(syncConfiguration: SyncConfiguration(user: SyncUser.current!, realmURL: Constants.privateRealmURL), objectTypes: [])
        return config
    }
    
    private static func temporaryRealmConfig(user: SyncUser) -> Realm.Configuration  {
        let config = Realm.Configuration(syncConfiguration: SyncConfiguration(user: SyncUser.current!, realmURL: Constants.temporaryRealmURL), objectTypes: [])
        return config
    }
    
}


final class RealmLoginManager {
    
    class func isUserLoggedIn() -> SyncUser? {
        guard let syncUser = SyncUser.current else {
            return nil
        }
        return syncUser
    }
    
    class func resetDefaultRealm() {
        guard let user = SyncUser.current else { return }
        user.logOut()
    }
    
    class func register(email: String, password: String) -> Observable<Bool> {
        return Observable.create { (observer) -> Disposable in
            
            let credentials = SyncCredentials.usernamePassword(username: email, password: password, register: true)
            
            SyncUser.logIn(with: credentials, server: Constants.syncAuthURL, onCompletion: { (syncUser, error) in
                if let error = error {
                    observer.onError(AuthError.registerError("Error: \(error.localizedDescription)"))
                }
                
                if let _ = syncUser {
                    observer.onNext(true)
                    observer.onCompleted()
                }
            })
            
            return Disposables.create()
        }
    }
    
    class func login(email: String, password: String) -> Observable<SyncUser> {
        return Observable.create { (observer) -> Disposable in
            
            let credentials = SyncCredentials.usernamePassword(username: email, password: password, register: false)
            
            SyncUser.logIn(with: credentials, server: Constants.syncAuthURL, onCompletion: { (syncUser, error) in
                if let error = error {
                    observer.onError(AuthError.loginError("Error: \(error.localizedDescription)"))
                }
                
                if let user = syncUser {
                    observer.onNext(user)
                    observer.onCompleted()
                }
            })
            
            return Disposables.create()
        }
    }
    
    class func initializeCommonRealm() -> Observable<Void> {
        return Observable.create { (observer) -> Disposable in
            
            Realm.asyncOpen(configuration: RealmConfig.common.configuration, callback: { (realm, error) in
                if let realm = realm {
                    if SyncUser.current?.isAdmin == true {
                        self.setPermissionForRealm(realm, accessLevel: .write, personID: "*")
                    }
                    observer.onCompleted()
                }
                if let error = error {
                    observer.onError(error)
                }
            })
        
            return Disposables.create()
        }

    }
    
    class func setPermissionForRealm(_ realm: Realm?, accessLevel: SyncAccessLevel, personID: String) {
        if let realm = realm {
            let perm = SyncPermission(realmPath: realm.configuration.syncConfiguration!.realmURL.path,
                                      identity: personID,
                                      accessLevel: accessLevel)
            SyncUser.current?.apply(perm) { error in
                if let error = error {
                    print("Error when attempting to set permissions: \(error.localizedDescription)")
                    return
                } else {
                    print("Permissions successfully set")
                }
            }
        }
    }
    
//    class func register(email: String, password: String) -> Promise<SyncUser> {
//        let credentials = SyncCredentials.usernamePassword(username: email, password: password, register: true)
//        return Promise { fulfill, reject in
//            SyncUser.logIn(with: credentials, server: Constants.syncAuthURL) { syncUser, error in
//                if let user = syncUser {
//                    fulfill(user)
//                }
//                if let error = error {
//                    reject(error)
//                }
//            }
//        }
//    }
    
}
