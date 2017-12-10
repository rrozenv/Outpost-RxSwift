
import Foundation
import RxSwift
import RealmSwift

enum RealmServiceError<T>: Error {
    case creationFailed
    case updateFailed(T)
    case deletionFailed(T)
    case toggleFailed(T)
}

protocol RealmServicable {
    associatedtype ModelType: Object
    
    @discardableResult
    func create(with values: [String: Any]) -> Observable<ModelType>
    
    @discardableResult
    func delete(object: ModelType) -> Observable<Void>
    
    @discardableResult
    func update(object: ModelType, action: (ModelType) -> Void) -> Observable<ModelType>
    
    @discardableResult
    func fetchAll() -> Observable<Results<ModelType>>
}



