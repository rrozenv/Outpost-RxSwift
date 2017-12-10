
import Foundation
import UIKit
import RxSwift
import RxCocoa
import Action
import SnapKit

enum AuthError: Error, CustomStringConvertible {
    case registerError(String)
    case loginError(String)
    
    var title: String {
        switch self {
        case .registerError(_):
            return "Registration Error"
        case .loginError(_):
            return "Login Error"
        }
    }
    
    var description: String {
        switch self {
        case .registerError(let desc):
            return "\(desc)"
        case .loginError(let desc):
            return "\(desc)"
        }
    }
}

class LoginViewController: UIViewController, BindableType {
    
    var emailTextField = UITextField()
    var usernameTextField = UITextField()
    var passwordTextField = UITextField()
    var registerButton = UIButton()
    var loginButton = UIButton()
    
    var engine: LoginEngine!
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setupFields()
        
        //Register
        
        registerButton.rx.tap
            .withLatestFrom(engine.userInput)
            .bind(to: engine.registerAction.inputs)
            .disposed(by: disposeBag)
        
        engine.registerAction
            .elements
            .subscribe(onNext: { [weak self] (user) in
                self?.displayRegistrationSuccessAlertFor(user: user)
            })
            .disposed(by: disposeBag)
        
        engine.registerAction
            .errors
            .subscribe(onError: { (error) in
                print(error.localizedDescription)
            })
            .disposed(by: disposeBag)
       
        //Login
        
        loginButton.rx.tap
            .withLatestFrom(engine.userInput)
            .bind(to: engine.loginAction.inputs)
            .disposed(by: disposeBag)
        
        engine.loginAction
            .elements
            .subscribe(onNext: { (user) in
                if let user = user {
                   print("Welcome back \(user.userName)!")
                }
            })
            .disposed(by: disposeBag)
        
        engine.loginAction
            .errors
            .subscribe(onError: { (error) in
                self.showError(error)
            })
            .disposed(by: disposeBag)
        
        
//        registerButton.rx.tap
//            .map { [unowned self] _ -> UserInput in
//                return self.currentInput()
//            }
//            .flatMapLatest { [unowned self] (userInput) -> Observable<User> in
//                return self.engine.registerAction.execute(userInput)
//            }
//            .observeOn(MainScheduler.instance)
//            .subscribe(onNext: { user in
//                print("Successfully created \(user.userName)!")
//            }, onError: { (error) in
//                print(error.localizedDescription)
//            })
//            .disposed(by: disposeBag)
//
//        loginButton.rx.tap
//            .map { [unowned self] _ -> UserInput in
//                return self.currentInput()
//            }
//            .flatMapLatest { [unowned self] (userInput) -> Observable<User?> in
//                return self.engine.loginAction.execute(userInput)
//            }
//            .observeOn(MainScheduler.instance)
//            .subscribe(onNext: { user in
//                if let user = user {
//                    print("Welcome back \(user.userName)!")
//                } else {
//                    print("error")
//                }
//            }, onError: { (error) in
//                self.showError(error)
//            })
//            .disposed(by: disposeBag)
    
    }
    
    deinit {
        print("Login VC deinitalized")
    }
    
    func bindEngine() {
        engine.userInputIsValid
            .drive(onNext: { [unowned self] (isValid) in
                self.registerButton.isEnabled = isValid ? true : false
                self.registerButton.backgroundColor = isValid ? UIColor.red : UIColor.gray
            })
            .disposed(by: disposeBag)
        
        emailTextField.rx.text
            .orEmpty
            .bind(to: engine.email)
            .disposed(by: disposeBag)
        
        usernameTextField.rx.text
            .orEmpty
            .bind(to: engine.username)
            .disposed(by: disposeBag)
        
        passwordTextField.rx.text
            .orEmpty
            .bind(to: engine.password)
            .disposed(by: disposeBag)
    }
    
    func displayRegistrationSuccessAlertFor(user: User) {
        let alertController = UIAlertController(title: "Registration Successful", message: "Welcome to Outpost \(user.userName)!", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default) { [weak self] (action) in
            self?.engine.routeToPromptsListAction().execute(())
        }
        alertController.addAction(alertAction)
        self.showDetailViewController(alertController, sender: nil)
    }
    
    fileprivate func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}

extension LoginViewController {
    
    fileprivate func setupFields() {
        usernameTextField.placeholder = "username"
        emailTextField.placeholder = "email"
        passwordTextField.placeholder = "password"
        registerButton.setTitle("Register", for: .normal)
        registerButton.backgroundColor = UIColor.red
        loginButton.setTitle("Login", for: .normal)
        loginButton.backgroundColor = UIColor.blue
        
        let fields: [UIView] = [usernameTextField, emailTextField, passwordTextField, loginButton, registerButton]
        let stackView = UIStackView(arrangedSubviews: fields)
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 10
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(view)
            make.height.equalTo(300)
        }
    }
    
}
