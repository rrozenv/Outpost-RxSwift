
import Foundation
import UIKit
import RxSwift

protocol BindableType {
    associatedtype EngineType
    var engine: EngineType! { get set }
    func bindEngine()
}

extension BindableType where Self: UIViewController {
    mutating func createEngine(with inputEngine: Self.EngineType) {
        engine = inputEngine
        loadViewIfNeeded()
        bindEngine()
    }
}
