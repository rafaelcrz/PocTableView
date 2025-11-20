import UIKit

class ChatViewController: UIViewController {
    
    // MARK: - Types
    
    enum Section: CaseIterable {
        case main
    }
    
    // MARK: - Properties
    
    private var messages: [Message] = []
    private var dataSource: UITableViewDiffableDataSource<Section, Message>!
    
    // MARK: - UI Components
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.separatorStyle = .none
        table.backgroundColor = .systemBackground
        table.translatesAutoresizingMaskIntoConstraints = false
        table.keyboardDismissMode = .interactive
        return table
    }()
    
    private let inputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let textField: UITextField = {
        let field = UITextField()
        field.placeholder = "Digite uma mensagem..."
        field.borderStyle = .roundedRect
        field.font = UIFont.systemFont(ofSize: 16)
        field.translatesAutoresizingMaskIntoConstraints = false
        field.returnKeyType = .send
        return field
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Enviar", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var inputContainerBottomConstraint: NSLayoutConstraint!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupActions()
        setupKeyboardObservers()
        
        // Add some initial messages
        //addInitialMessages()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        title = "Chat"
        view.backgroundColor = .systemBackground
        
        // Add subviews
        view.addSubview(tableView)
        view.addSubview(inputContainerView)
        inputContainerView.addSubview(separatorLine)
        inputContainerView.addSubview(textField)
        inputContainerView.addSubview(sendButton)
        
        // Setup constraints
        inputContainerBottomConstraint = inputContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        
        NSLayoutConstraint.activate([
            // TableView constraints
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor),
            
            // Input container constraints
            inputContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputContainerBottomConstraint,
            inputContainerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60),
            
            // Separator line
            separatorLine.topAnchor.constraint(equalTo: inputContainerView.topAnchor),
            separatorLine.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 0.5),
            
            // TextField constraints
            textField.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 16),
            textField.topAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: 8),
            textField.bottomAnchor.constraint(equalTo: inputContainerView.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            textField.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
            
            // Send button constraints
            sendButton.leadingAnchor.constraint(equalTo: textField.trailingAnchor, constant: 8),
            sendButton.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor, constant: -16),
            sendButton.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
            sendButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 60)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.register(MessageTableViewCell.self, forCellReuseIdentifier: MessageTableViewCell.identifier)
        
        // Configura altura automática das células para suportar múltiplas linhas
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableView.automaticDimension
        
        // Configura o DiffableDataSource
        dataSource = UITableViewDiffableDataSource<Section, Message>(tableView: tableView) { tableView, indexPath, message in
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: MessageTableViewCell.identifier,
                for: indexPath
            ) as? MessageTableViewCell else {
                return UITableViewCell()
            }
            
            cell.configure(with: message)
            return cell
        }
        
        // Adiciona contentInset inferior para criar espaço em branco embaixo
        // Isso permite que as mensagens subam naturalmente quando novas são adicionadas
        let screenHeight = UIScreen.main.bounds.height
        let bottomInset = screenHeight - 200 // 200 pontos reservados para as 2 últimas mensagens
//        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
//        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
    }
    
    private func setupActions() {
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        textField.delegate = self
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Keyboard Handling
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        let keyboardHeight = keyboardFrame.height
        inputContainerBottomConstraint.constant = -keyboardHeight
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
        
        scrollToBottom()
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        inputContainerBottomConstraint.constant = 0
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Message Handling
    
    private func updateSnapshot(animated: Bool = false, completion: (() -> Void)?) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Message>()
        snapshot.appendSections([.main])
        snapshot.appendItems(messages)
        dataSource.applySnapshotUsingReloadData(snapshot, completion: {
            completion?()
        })
    }
    
    private func addInitialMessages() {
        let welcomeMessage = Message(text: "Olá! Bem-vindo ao chat. Como posso ajudar?", isFromUser: false)
        messages.append(welcomeMessage)
        updateSnapshot {}
    }
    
    @objc private func sendButtonTapped() {
        sendMessage()
    }
    
    private func sendMessage() {
        guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else {
            return
        }
        
        // Add user message
        let userMessage = Message(text: text, isFromUser: true)
        messages.append(userMessage)
        
        // Clear text field
        textField.text = ""
        
        // Update snapshot and scroll
        updateSnapshot(animated: true) {
            self.scrollToBottom()
        }
        
        // Simulate automatic response after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.sendAutomaticResponse(to: text)
        }
    }
    
    private func sendAutomaticResponse(to userMessage: String) {
        let responses = [
            "Entendi! Obrigado por compartilhar.",
            "Isso é interessante! Conte-me mais.Isso é interessante! Conte-me mais.Isso é interessante! Conte-me mais.Isso é interessante! Conte-me mais.Isso é interessante! Conte-me mais.Isso é interessante! Conte-me mais.Isso é interessante! Conte-me mais.Isso é interessante! Conte-me mais.Isso é interessante! Conte-me mais.Isso é interessante! Conte-me mais.Isso é interessante! Conte-me mais.Isso é interessante! Conte-me mais.Isso é interessante! Conte-me mais.Isso é interessante! Conte-me mais.Isso é interessante! Conte-me mais.Isso é interessante! Conte-me mais.Isso é interessante! Conte-me mais.Isso é interessante! Conte-me mais.Isso é interessante! Conte-me mais.Isso é interessante! Conte-me mais.Isso é interessante! Conte-me mais.Isso é interessante! Conte-me mais.Isso é interessante! Conte-me mais.Isso é interessante! Conte-me mais.Isso é interessante! Conte-me mais.Isso é interessante! Conte-me mais.Isso é interessante! Conte-me mais.Isso é interessante! Conte-me mais.Isso é interessante! Conte-me mais.Isso é interessante! Conte-me mais.Isso é interessante! Conte-me mais.Isso é interessante! Conte-me mais.Isso é interessante! Conte-me mais.Isso é interessante! Conte-me mais.Isso é interessante! Conte-me mais.Isso é interessante! Conte-me mais.Isso é interessante! Conte-me mais.Isso é interessante! Conte-me mais.Isso é interessante! Conte-me mais.Isso é interessante! Conte-me mais.Isso é interessante! Conte-me mais.Isso é interessante! Conte-me mais.Isso é interessante! Conte-me mais.Isso é interessante! Conte-me mais.Isso é interessante! Conte-me mais.Isso é interessante! Conte-me mais.Isso é interessante! Conte-me mais.Isso é interessante! Conte-me mais.Isso é interessante! Conte-me mais.Isso é interessante! Conte-me mais.",
            "Resposta automática: Recebi sua mensagem.",
//            "Legal! Posso ajudar com mais alguma coisa?",
//            "Boa! Vou processar isso.",
//            "Compreendo. Alguma outra dúvida?"
        ]
        
        let randomResponse = responses.randomElement() ?? "Resposta automática"
        let botMessage = Message(text: randomResponse, isFromUser: false)
        
        messages.append(botMessage)
        updateSnapshot(animated: true) {
            self.scrollToBottom()
        }
    }
    
    private func scrollToBottom() {
        guard !messages.isEmpty else { return }
        
        // Força o layout da tableView para garantir que o contentSize está atualizado
        tableView.layoutIfNeeded()
        
        // Atualiza o contentInset dinamicamente para ter espaço suficiente
        // para scrollar todas as mensagens antigas para fora da tela
        updateContentInset()
        
        // Pega a última célula adicionada
        let lastIndexPath = IndexPath(row: messages.count - 2, section: 0)
        let lastCellRect = tableView.rectForRow(at: lastIndexPath)
        
        // Pega o contentOffset atual
        let currentOffset = tableView.contentOffset.y
        
        // Calcula o novo offset: offset atual + altura da última célula
        // Isso "empurra" a nova mensagem para cima de forma incremental
//        let newOffsetY = currentOffset + lastCellRect.height
        let newOffset = CGPoint(x: 0, y: lastCellRect.origin.y)
        
        self.tableView.setContentOffset(newOffset, animated: true)
    }
    
    private func updateContentInset() {
        guard messages.count >= 2 else {
            // Se tiver menos de 2 mensagens, usa contentInset mínimo
            let tableHeight = tableView.bounds.height
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: tableHeight, right: 0)
            tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: tableHeight, right: 0)
            return
        }
        
        // Calcula a soma da altura das 2 últimas células
        let lastIndexPath = IndexPath(row: messages.count - 1, section: 0)
        let secondToLastIndexPath = IndexPath(row: messages.count - 2, section: 0)
        
        let lastCellHeight = tableView.rectForRow(at: lastIndexPath).height
        let secondToLastCellHeight = tableView.rectForRow(at: secondToLastIndexPath).height
        
        let contentHeight = lastCellHeight + secondToLastCellHeight
        let tableHeight = tableView.bounds.height
        
        // ContentInset no bottom = altura da tela - altura das 2 últimas células
        // Isso deixa espaço para scrollar todas as mensagens antigas para cima
        let necessaryInset = max(tableHeight - contentHeight, 0)
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: max(necessaryInset, 0), right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: max(necessaryInset, 0), right: 0)
    }
}

// MARK: - UITableViewDelegate

extension ChatViewController: UITableViewDelegate {
    // Delegate methods can be added here if needed
}

// MARK: - UITextFieldDelegate

extension ChatViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage()
        return true
    }
}

