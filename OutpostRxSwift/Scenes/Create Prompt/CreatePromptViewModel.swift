
import Foundation
import RxSwift
import RxCocoa
import Action
import RealmSwift

struct CreatePromptEngine {
    
    struct PromptInput {
        let title: String
        let body: String
    }
    
    let promptDataController: PromptDataController
    let sceneCoordinator: SceneCoordinatorType
    
    //MARK: - Input
    let title = Variable<String>("")
    let body = Variable<String>("")
    
    //MARK: - Output
    let promptInput: Observable<PromptInput>
    let promptInputIsValid: Driver<Bool>
    
    init(promptDataController: PromptDataController, coordinator: SceneCoordinatorType) {
        
        self.promptDataController = promptDataController
        self.sceneCoordinator = coordinator
        
        self.promptInputIsValid = Observable.combineLatest(title.asObservable(), body.asObservable(), resultSelector: { (title, body) in
            return title.count > 10 && body.count > 10
        })
        .asDriver(onErrorJustReturn: false)
        
        self.promptInput = Observable.combineLatest(title.asObservable(), body.asObservable(), resultSelector: { (title, body) in
            return PromptInput(title: title, body: body)
        })
        
    }
    
    lazy var createPrompt: Action<PromptInput, Prompt> = { me in
        return Action { (promptInput) in
            return me.promptDataController.createWith(promptInput: promptInput)
        }
    }(self)
    
    func routeToPromptListAction() -> CocoaAction {
        return CocoaAction { _ in
            return self.sceneCoordinator.pop()
        }
    }

}
