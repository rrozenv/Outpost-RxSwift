
import Foundation
import RxSwift
import UIKit

enum Scene {
    case login(LoginEngine)
    case prompts(PromptListEngine)
    case createPrompt(CreatePromptEngine)
}

extension Scene {
    
    func viewController() -> UIViewController {
        switch self {
        case .prompts(let engine):
            var rootVc = PromptListViewController()
            rootVc.createEngine(with: engine)
            let nav = UINavigationController(rootViewController: rootVc)
            return nav
        case .login(let engine):
            var vc = LoginViewController()
            vc.createEngine(with: engine)
            return vc
        case .createPrompt(let engine):
            var rootVc = CreatePromptViewController()
            rootVc.createEngine(with: engine)
            let nav = UINavigationController(rootViewController: rootVc)
            return nav
        }
    }
    
}
