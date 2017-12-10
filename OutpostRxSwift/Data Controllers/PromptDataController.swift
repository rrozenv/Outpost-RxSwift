
import Foundation
import RealmSwift
import RxSwift
import RxRealm

protocol PromptDataServiceType {
    @discardableResult
    func createWith(promptInput: CreatePromptEngine.PromptInput) -> Observable<Prompt>
    
    @discardableResult
    func fetchAllPrompts() -> Observable<Results<Prompt>>
}

struct PromptDataController {
    
    typealias ModelType = Prompt
    
    init() {
        // create a few default tasks
//        do {
//            let realm = try Realm()
//            if realm.objects(Prompt.self).count == 0 {
//                let properties = ["title": "First Prompt", "body": "First prompt body", "imageUrl": "https://i.ytimg.com/vi/y4Ccm-kUDSM/hqdefault.jpg"]
//                self.create(with: properties)
//            }
//        } catch _ {
//        }
    }
    
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

extension PromptDataController: PromptDataServiceType {
    
    func createWith(promptInput: CreatePromptEngine.PromptInput) -> Observable<Prompt> {
        let result = withRealm("creating") { realm -> Observable<Prompt> in
            let prompt = Prompt(title: promptInput.title, body: promptInput.body, imageUrl: "")
            try realm.write {
                prompt.uid = (realm.objects(Prompt.self).max(ofProperty: "uid") ?? 0) + 1
                realm.add(prompt)
            }
            return .just(prompt)
        }
        return result ?? .error(RealmServiceError<Prompt>.creationFailed)
    }
    
    func fetchAllPrompts() -> Observable<Results<Prompt>> {
        let result = withRealm("getting tasks") { realm -> Observable<Results<Prompt>> in
            let prompts = realm.objects(Prompt.self)
            return Observable.collection(from: prompts)
        }
        return result ?? .empty()
    }

}

extension PromptDataController: RealmServicable {
    
    func create(with values: [String : Any]) -> Observable<Prompt> {
        let result = withRealm("creating") { realm -> Observable<Prompt> in
            let prompt = Prompt()
            prompt.set(values: values)
            try realm.write {
                prompt.uid = (realm.objects(Prompt.self).max(ofProperty: "uid") ?? 0) + 1
                realm.add(prompt)
            }
            return .just(prompt)
        }
        return result ?? .error(RealmServiceError<Prompt>.creationFailed)
    }
    
    func delete(object: Prompt) -> Observable<Void> {
        let result = withRealm("deleting") { realm -> Observable<Void> in
            try realm.write {
                realm.delete(object)
            }
            return .empty()
        }
        return result ?? .error(RealmServiceError<Prompt>.deletionFailed(object))
    }
    
    func update(object: Prompt, action: (Prompt) -> Void) -> Observable<Prompt> {
        let result = withRealm("updating title") { realm -> Observable<Prompt> in
            try realm.write {
                action(object)
            }
            return .just(object)
        }
        return result ?? .error(RealmServiceError<Prompt>.updateFailed(object))
    }
    
    func fetchAll() -> Observable<Results<Prompt>> {
        let result = withRealm("getting tasks") { realm -> Observable<Results<Prompt>> in
            let realm = try Realm()
            let prompts = realm.objects(Prompt.self)
            return Observable.collection(from: prompts)
        }
        return result ?? .empty()
    }
    
}
