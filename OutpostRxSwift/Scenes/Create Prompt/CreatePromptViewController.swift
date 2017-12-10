
import Foundation
import RxSwift
import RxDataSources
import Action
//import NSObject_Rx

class CreatePromptViewController: UIViewController, BindableType {
    
    let disposeBag = DisposeBag()
    var doneButton: UIBarButtonItem!
    
    var titleTextView: UITextView!
    var bodyTextView: UITextView!
    var engine: CreatePromptEngine!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doneButton = UIBarButtonItem(title: "Done", style: .done, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem = doneButton
        
        setupTitleTextView()
        setupBodyTextView()
        
        doneButton.rx.tap
            .withLatestFrom(engine.promptInput)
            .bind(to: engine.createPrompt.inputs)
            .disposed(by: disposeBag)
        
        engine.createPrompt
            .elements
            .subscribe(onNext: { [weak self] (user) in
                self?.engine.routeToPromptListAction().execute(())
            })
            .disposed(by: disposeBag)
    }
    
    func bindEngine() {
        engine.promptInputIsValid
            .drive(onNext: { [unowned self] (isValid) in
                self.doneButton.isEnabled = isValid ? true : false
                self.doneButton.tintColor = isValid ? UIColor.red : UIColor.gray
            })
            .disposed(by: disposeBag)
        
        titleTextView.rx.text
            .orEmpty
            .bind(to: engine.title)
            .disposed(by: disposeBag)
        
        bodyTextView.rx.text
            .orEmpty
            .bind(to: engine.body)
            .disposed(by: disposeBag)
    }
    
}

extension CreatePromptViewController {
    
    func setupTitleTextView() {
        titleTextView = UITextView()
        titleTextView.font = FontBook.AvenirHeavy.of(size: 14)
        titleTextView.isEditable = true
        titleTextView.isScrollEnabled = false
        titleTextView.backgroundColor = UIColor.yellow
        titleTextView.text = "Title"
        
        view.addSubview(titleTextView)
        titleTextView.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.top.equalTo(topLayoutGuide.snp.bottom).offset(10)
        }
    }
    
    func setupBodyTextView() {
        bodyTextView = UITextView()
        bodyTextView.font = FontBook.AvenirHeavy.of(size: 14)
        bodyTextView.isEditable = true
        bodyTextView.isScrollEnabled = false
        bodyTextView.backgroundColor = UIColor.yellow
        bodyTextView.text = "body"
        
        view.addSubview(bodyTextView)
        bodyTextView.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.top.equalTo(titleTextView.snp.bottom).offset(10)
        }
    }
  
}
