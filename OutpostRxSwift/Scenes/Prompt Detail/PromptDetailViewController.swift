
import Foundation
import RxSwift
import RxDataSources
import Action
//import NSObject_Rx

class PromptDetailViewController: UIViewController, BindableType {
    
    let disposeBag = DisposeBag()
    var tableView: UITableView!
    var createPromptButton: UIBarButtonItem!
    var engine: PromptListEngine!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        //bindEngine()
    }
    
    func bindEngine() {
        engine.allPrompts
            .bind(to: tableView.rx.items) { tableView, index, prompt in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: PromptTableCell.reuseIdentifier) as? PromptTableCell else { fatalError() }
                cell.configure(with: prompt)
                return cell
            }
            .disposed(by: disposeBag)
        //newTaskButton.rx.action = viewModel.onCreateTask()
    }
    
}

extension PromptDetailViewController {
    
    fileprivate func setupTableView() {
        //MARK: - tableView Properties
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.register(PromptTableCell.self, forCellReuseIdentifier: PromptTableCell.reuseIdentifier)
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        
        //MARK: - tableView Constraints
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
    }
    
}
