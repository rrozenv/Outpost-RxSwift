
import Foundation
import RxSwift
import RxDataSources
import Action
import RealmSwift

typealias TableSection = SectionModel<String, Prompt>

struct PromptListEngine {
    let sceneCoordinator: SceneCoordinatorType
    let promptDataController: PromptDataController
    
    //MARK: - Output
    var allPrompts: Observable<Results<Prompt>> {
        return self.promptDataController.fetchAllPrompts()
    }
    
    init(dataController: PromptDataController, coordinator: SceneCoordinatorType) {
        self.promptDataController = dataController
        self.sceneCoordinator = coordinator
    }
    
//    func onCreateTask() -> CocoaAction {
//        return CocoaAction { _ in
//            return self.taskService
//                .createTask(title: "")
//                .flatMap({ (task) -> Observable<Void> in
//                    let editViewModel =
//                        EditTaskViewModel(task: task, coordinator: self.sceneCoordinator, updateAction: self.onUpdateTitle(task: task), cancelAction: self.onDelete(task: task))
//                    return self.sceneCoordinator.transition(to: Scene.editTask(editViewModel), type: .modal)
//                })
//        }
//    }
    
    func routeToCreatePromptAction() -> CocoaAction {
        return CocoaAction { _ in
            let createPromptEngine = CreatePromptEngine(promptDataController: self.promptDataController, coordinator: self.sceneCoordinator)
            let createPromptScene = Scene.createPrompt(createPromptEngine)
            return self.sceneCoordinator.transition(to: createPromptScene, type: .modal)
        }
    }
    
    func onDelete(prompt: Prompt) -> CocoaAction {
        return CocoaAction { _ in
            return self.promptDataController.delete(object: prompt)
        }
    }

}
