//
//  ConversationsViewController.swift
//  MessengerApp
//
//  Created by administrator on 04/01/2022.
//

import FirebaseAuth
import JGProgressHUD
class ConversationsViewController: UIViewController {
    // root view controller that gets instantiated when app launches
    // check to see if user is signed in using ... user defaults
    // they are, stay on the screen. If not, show the login screen
    
    private let spinner = JGProgressHUD(style: .dark)
    private var conversations = [Conversation]()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true // first fetch the conversations, if none (don't show empty convos)
        table.register(ConversationTableViewCell.self,
                              forCellReuseIdentifier: ConversationTableViewCell.identifier)
        
        return table
    }()
    
    private let noConversationsLabel: UILabel = {
        let label = UILabel()
        label.text = "No conversations"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapComposeButton))
        view.addSubview(tableView)
        view.addSubview(noConversationsLabel)
        setupTableView()
        fetchConversations()
        startListeningForCOnversations()
      }

      private func startListeningForCOnversations() {
          guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
              return
          }
          print("starting conversation fetch...")

          let safeEmail = DatabaseManger.safeEmail(emailAddress: email)

          DatabaseManger.shared.getAllConversations(for: safeEmail, completion: { [weak self] result in
              switch result {
              case .success(let conversations):
                  print("successfully got conversation models")
                  guard !conversations.isEmpty else {
                      return
                  }

                  self?.conversations = conversations

                  DispatchQueue.main.async {
                      self?.tableView.reloadData()
                  }
              case .failure(let error):
                  print("failed to get convos: \(error)")
              }
          })
      }
    @objc private func didTapComposeButton(){
        // present new conversation view controller
        // present in a nav controller
        let vc = NewConversationViewController()
        vc.completion = { [weak self] result in
                    guard let strongSelf = self else {
                        return
                    }

                    let currentConversations = strongSelf.conversations

                    if let targetConversation = currentConversations.first(where: {
                        $0.otherUserEmail == DatabaseManger.safeEmail(emailAddress: result.email)
                    }) {
                        let vc = ChatViewController(with: targetConversation.otherUserEmail, id: targetConversation.id)
                        vc.isNewConversation = false
                        vc.title = targetConversation.name
                        vc.navigationItem.largeTitleDisplayMode = .never
                        strongSelf.navigationController?.pushViewController(vc, animated: true)
                    }
                    else {
                        strongSelf.createNewConversation(result: result)
                    }
                }
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC,animated: true)
    }
    private func createNewConversation(result: SearchResult) {
        let name = result.name
        let email = DatabaseManger.safeEmail(emailAddress: result.email)
        
        // check in datbase if conversation with these two users exists
               // if it does, reuse conversation id
               // otherwise use existing code
               DatabaseManger.shared.conversationExists(iwth: email, completion: { [weak self] result in
                   guard let strongSelf = self else {
                       return
                   }
                   switch result {
                   case .success(let conversationId):
                       let vc = ChatViewController(with: email, id: conversationId)
                       vc.isNewConversation = false
                       vc.title = name
                       vc.navigationItem.largeTitleDisplayMode = .never
                       strongSelf.navigationController?.pushViewController(vc, animated: true)
                   case .failure(_):
                       let vc = ChatViewController(with: email, id: nil)
                       vc.isNewConversation = true
                       vc.title = name
                       vc.navigationItem.largeTitleDisplayMode = .never
                       strongSelf.navigationController?.pushViewController(vc, animated: true)
                   }
               })
           }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
    }
    
    private func validateAuth(){
        // current user is set automatically when you log a user in
        if FirebaseAuth.Auth.auth().currentUser == nil {
            // present login view controller
            let logInVC = storyboard?.instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
            logInVC.modalPresentationStyle = .fullScreen
            //navigationController?.pushViewController(logInVC, animated: true)
            present(logInVC, animated: false)
        }
    }
    
    private func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func fetchConversations(){
        // fetch from firebase and either show table or label
        tableView.isHidden = false
    }
}
extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = conversations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier,
                                                 for: indexPath) as! ConversationTableViewCell
        cell.configure(with: model)
        return cell
    }
    
    // when user taps on a cell, we want to push the chat screen onto the stack
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = conversations[indexPath.row]
        //        let model = conversations[indexPath.row]
        //               openConversation(model)
        let vc = ChatViewController(with: model.otherUserEmail, id: model.id)
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    func openConversation(_ model: Conversation) {
        
    }
}
