//
//  ChatViewController.swift
//  JustChats
//
//  Created by Андрей Абакумов on 11.05.2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import MessageKit
import InputBarAccessoryView

class ChatViewController: MessagesViewController {
    
#warning("Добавить логику загрузки прошлых сообщений при обновлении скролла")
    
    private var currentUser = Auth.auth().currentUser!
    private var messages: [Message] = []
    private var messageListener: ListenerRegistration?
    
    //    private let refreshControl = UIRefreshControl()
    //    private var newHistoryMessages: [Message] = []
    //    private var newMessages: [Message] = []
    
    deinit {
        messageListener?.remove()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupView()
    }
    
    @objc private func logOut() {
        let ac = UIAlertController(title: nil, message: "Вы точно хотите выйти из аккаунта?",
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        ac.addAction(UIAlertAction(title: "Выход", style: .destructive, handler: { _ in
            AuthService.shared.logOut()
        }))
        
        present(ac, animated: true)
    }
    
    @objc private func profileButtonTapped() {
        let setupProfileViewController = SetupProfileViewController()
        present(setupProfileViewController, animated: true)
    }
    
    //    @objc private func loadPreviousMessages() {
    //        FirestoreService.shared.fetchPrevious(20)
    //        refreshControl.endRefreshing()
    //    }
}

//MARK: - Private methods

extension ChatViewController {
    
    private func setupView() {
        configureMessageCollectionView()
        configureMessageInputBar()
        
        //        refreshControl.addTarget(self, action: #selector(loadPreviousMessages), for: .valueChanged)
        //        messagesCollectionView.refreshControl = refreshControl
        
        FirestoreService.shared.delegate = self
        //        FirestoreService.shared.fetchLast(20)
        
        messageListener = ListenerService.shared.messagesObserve(completion: { result in
            switch result {
            case .success(let message):
                self.insertNewMessage(message)
            case .failure(let error):
                self.showAlert(with: "Ошибка", and: error.localizedDescription)
            }
        })
    }
    
    private func setupNavBar() {
        title = "Just Chat"
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.shadowColor = .clear
        
        guard let navBar = navigationController?.navigationBar else { return }
        navBar.tintColor = .black
        navBar.standardAppearance = navBarAppearance
        navBar.scrollEdgeAppearance = navBarAppearance
        
        let logOutButton = UIBarButtonItem(title: "Log out",
                                           style: .done,
                                           target: self,
                                           action: #selector(logOut))
        navigationItem.rightBarButtonItem = logOutButton
        
        let profileButton = UIBarButtonItem(image: UIImage(systemName: "person.fill"),
                                            style: .plain,
                                            target: self,
                                            action: #selector(profileButtonTapped))
        navigationItem.leftBarButtonItem = profileButton
    }
    
    private func insertNewMessage(_ message: Message) {
        guard !messages.contains(message) else { return }
        
        messages.append(message)
        messages.sort()
        
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem()
    }
}

// MARK: - ConfigureMessageInputBar
extension ChatViewController {
    
    private func configureMessageInputBar() {
        messageInputBar.delegate = self
        
        messageInputBar.isTranslucent = true
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.backgroundView.backgroundColor = .white
        messageInputBar.inputTextView.backgroundColor = .white
        messageInputBar.inputTextView.placeholderTextColor = .lightGray
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 8)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 12, bottom: 0, right: 8)
        messageInputBar.inputTextView.layer.cornerRadius = 18.0
        
        configureSendButton()
    }
    
    private func configureSendButton() {
        let imageConfiguration = UIImage.SymbolConfiguration(pointSize: 72, weight: .medium)
        messageInputBar.sendButton.setImage(UIImage(systemName: "arrow.up.circle.fill", withConfiguration: imageConfiguration), for: .normal)
        messageInputBar.sendButton.title = ""
        messageInputBar.sendButton.tintColor = .black
    }
}

//MARK: - ConfigureMessageCollectionView

extension ChatViewController {
    
    func configureMessageCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        scrollsToLastItemOnKeyboardBeginsEditing = true
        maintainPositionOnInputBarHeightChanged = true
        showMessageTimestampOnSwipeLeft = true
        
        messagesCollectionView.backgroundColor = .white
    }
}

//MARK: - FirestoreServiceDelegate

extension ChatViewController: FirestoreServiceDelegate {
    
    func didReceiveMessages(_ databaseManager: FirestoreService, messages: [Message]) {
        
        //        if self.messages.isEmpty {
        //            self.messages = messages
        //            messagesCollectionView.reloadData()
        //            messagesCollectionView.scrollToLastItem(animated: false)
        //        } else {
        //            self.newHistoryMessages.append(contentsOf: messages)
        //            refreshControl.endRefreshing()
        //            self.messages.insert(contentsOf: self.newHistoryMessages, at: 0)
        //            messagesCollectionView.reloadData()
        //            self.newHistoryMessages = []
        //        }
        
        self.messages = messages
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem(animated: false)
    }
    
    func didReceiveError(_ databaseManager: FirestoreService, error: Error) {
        showAlert(with: "Ошибка", and: error.localizedDescription)
    }
}

//MARK: - InputBarAccessoryViewDelegate

extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let message = Message(id: UUID().uuidString, content: text, created: Timestamp(), senderID: currentUser.uid, senderName: currentUser.displayName!)
        
        FirestoreService.shared.sendMessage(message)
        
        inputBar.inputTextView.text = ""
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
    }
}

//MARK: - MessagesDataSource

extension ChatViewController: MessagesDataSource {
    
    var currentSender: MessageKit.SenderType {
        return ChatUser(senderId: currentUser.uid, displayName: currentUser.displayName ?? "ErrorName")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        if messages.count == 0 {
            print("There are no messages")
            return 0
        } else {
            return messages.count
        }
    }
}

//MARK: - MessagesDisplayDelegate

extension ChatViewController: MessagesDisplayDelegate {
    
    // Цвет сообщений
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .black : .lightGray
    }
    
    // Цвет текста сообщения
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .black
    }
    
    // Видимость View аватарки
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        return avatarView.isHidden = true
    }
    
    // Размер места для аватарки
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize? {
        return .zero
    }
    
    // Стиль хвоста облака сообщения
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight: .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    
    // Текст над сообщением
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
}

//MARK: - MessagesLayoutDelegate

extension ChatViewController: MessagesLayoutDelegate {
    
    func messageTopLabelAlignment(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LabelAlignment? {
        if isFromCurrentSender(message: message) {
            return LabelAlignment.init(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8))
        } else {
            return LabelAlignment.init(textAlignment: .left, textInsets: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0))
        }
    }
    
    // Отступ сообщения от нижней границы
    func footerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 0, height: 8)
    }
    
    // Высота текста над сообщением
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
}
