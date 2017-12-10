
import Foundation
import RxSwift
import RxCocoa
import Action
import RealmSwift

struct UserInput {
    let userName: String
    let email: String
    let password: String
}

struct LoginEngine {
    
    let userDataController: UserDataController
    let sceneCoordinator: SceneCoordinatorType
    
    //MARK: - Input
    let username = Variable<String>("")
    let email = Variable<String>("")
    let password = Variable<String>("")
    
    //MARK: - Output
    let userInput: Observable<UserInput>
    let userInputIsValid: Driver<Bool>
    
    init(userDataController: UserDataController, coordinator: SceneCoordinatorType) {
        self.userDataController = userDataController
        self.sceneCoordinator = coordinator
        
        let usernameValid = username.asObservable()
            .distinctUntilChanged()
            .map { $0.count > 3 }
        
        let passwordValid = password.asObservable()
            .distinctUntilChanged()
            .map { $0.count > 3 }
        
        self.userInputIsValid = Observable.combineLatest(usernameValid, passwordValid, resultSelector: { (use, pass) in
            return use && pass
        })
        .asDriver(onErrorJustReturn: false)
        
        self.userInput = Observable.combineLatest(username.asObservable(), email.asObservable(), password.asObservable(), resultSelector: { (username, email, password) in
            return UserInput(userName: username, email: email.lowercased(), password: password.lowercased())
        })
       
    }
    
    func routeToPromptsListAction() -> CocoaAction {
        return CocoaAction {
            let promptDataController = PromptDataController()
            let promptListEngine = PromptListEngine(dataController: promptDataController, coordinator: self.sceneCoordinator)
            let promptListScene = Scene.prompts(promptListEngine)
            return self.sceneCoordinator.transition(to: promptListScene, type: .root)
        }
    }
    
    lazy var registerAction: Action<UserInput, User> = { me in
        return Action { (userInput) in
            return RealmLoginManager
                .register(email: userInput.email, password: userInput.password)
                .flatMap { _ -> Observable<User> in
                    return me.userDataController.create(name: userInput.userName, email: userInput.email)
                }
        }
    }(self)
    
    lazy var loginAction: Action<UserInput, User?> = { me in
        return Action { (userInput) in
            return RealmLoginManager
                .login(email: userInput.email, password: userInput.password)
//                .flatMap { _ -> Observable<Void> in
//                    return RealmLoginManager.initializeCommonRealm()
//                }
                .flatMap { syncUser -> Observable<User?> in
                    return me.userDataController.fetchCurrentUser(syncUser: syncUser)
                }
        }
    }(self)
    
}
