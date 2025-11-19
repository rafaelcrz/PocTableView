import UIKit

class ChatViewController: UIViewController {
    
    // MARK: - Properties
    
    private var messages: [Message] = []
    
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
        addInitialMessages()
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
        tableView.dataSource = self
        tableView.register(MessageTableViewCell.self, forCellReuseIdentifier: MessageTableViewCell.identifier)
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
    
    private func addInitialMessages() {
        let welcomeMessage = Message(text: "Olá! Bem-vindo ao chat. Como posso ajudar?", isFromUser: false)
        messages.append(welcomeMessage)
        tableView.reloadData()
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
        
        // Reload table and scroll
        tableView.reloadData()
        scrollToBottom()
        
        // Simulate automatic response after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.sendAutomaticResponse(to: text)
        }
    }
    
    private func sendAutomaticResponse(to userMessage: String) {
        let responses = [
            "Entendi! Obrigado por compartilhar.",
            "Isso é interessante! Conte-me mais.",
            "Resposta automática: Recebi sua mensagem.",
            "Legal! Posso ajudar com mais alguma coisa?",
            "Boa! Vou processar isso.",
            "Compreendo. Alguma outra dúvida?"
        ]
        
        let randomResponse = responses.randomElement() ?? "Resposta automática"
        let botMessage = Message(text: randomResponse, isFromUser: false)
        
        messages.append(botMessage)
        tableView.reloadData()
        scrollToBottom()
    }
    
    private func scrollToBottom() {
        guard !messages.isEmpty else { return }
        
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MessageTableViewCell.identifier,
            for: indexPath
        ) as? MessageTableViewCell else {
            return UITableViewCell()
        }
        
        let message = messages[indexPath.row]
        cell.configure(with: message)
        return cell
    }
}

// MARK: - UITextFieldDelegate

extension ChatViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage()
        return true
    }
}

