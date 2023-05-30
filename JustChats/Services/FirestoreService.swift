//
//  FirestoreService.swift
//  JustChats
//
//  Created by Андрей Абакумов on 24.05.2023.
//

import Foundation
import Firebase
import FirebaseFirestore

protocol FirestoreServiceDelegate: AnyObject {
    func didReceiveMessages(_ databaseManager: FirestoreService, messages: [Message])
    func listenerDidReceiveMessages(_ databaseManager: FirestoreService, messages: [Message])
    func didReceiveError(_ databaseManager: FirestoreService, error: Error)
}

extension FirestoreServiceDelegate {
    func didReceiveMessages(_ databaseManager: FirestoreService, messages: [Message]) {}
    func didReceiveError(_ databaseManager: FirestoreService, error: Error) {}
    func listenerDidReceiveMessages(_ databaseManager: FirestoreService, messages: [Message]) {}
}

class FirestoreService {
    
    static let shared = FirestoreService()
    
    weak var delegate: FirestoreServiceDelegate?
    private let db = Firestore.firestore()
    
    private let collectionName = "chat"
    private let sortByDate = "created"
    
    private var cursor: DocumentSnapshot?
    private let pageSize = 10
    private var dataMayContinue = true
    
    // MARK: - function for sending data to server
    func sendMessage(_ message: Message) {
        let data = message.dictionary
        db.collection(collectionName).addDocument(data: data)
    }
    
    // MARK: - fetch messages from server on loading chat
//    func fetchLast(_ number: Int) {
//        db.collection(collectionName)
//            .order(by: sortByDate, descending: true)
//            .limit(to: pageSize)
//            .getDocuments { querySnapshot, error in
//                switch error {
//                case .some(let error):
//                    self.delegate?.didReceiveError(self, error: error)
//                case .none:
//                    guard let snapshot = querySnapshot else { return }
//
//                    if snapshot.count < self.pageSize {
//                        self.cursor = nil
//                    } else {
//                        self.cursor = snapshot.documents.last
//                    }
//
//                    let documents = snapshot.documents
//                    var messages: [Message] = []
//
//                    for document in documents {
//                        let message = Message(document: document)
//                        messages.append(message!)
//                    }
//
//                    self.delegate?.didReceiveMessages(self, messages: messages.reversed())
//                }
//            }
//    }
    
    // MARK: - fetch messages from history
    func fetchPrevious(_ number: Int) {
        
        guard dataMayContinue, let cursor = cursor else { return }
        dataMayContinue = false
        
        db.collection(collectionName)
            .order(by: sortByDate, descending: true)
            .start(afterDocument: cursor)
            .limit(to: pageSize)
            .getDocuments { querySnapshot, error in
                switch error {
                case .some(let error):
                    self.delegate?.didReceiveError(self, error: error)
                case .none:
                    guard let snapshot = querySnapshot else { return }
                    
                    if snapshot.count < self.pageSize {
                        self.cursor = nil
                    } else {
                        self.cursor = snapshot.documents.last
                    }
                    
                    self.dataMayContinue = true
                    
                    let documents = snapshot.documents
                    var messages: [Message] = []
                    
                    for document in documents {
                        let message = Message(document: document)
                        messages.append(message!)
                    }
                    
                    self.delegate?.didReceiveMessages(self, messages: messages.reversed())
                }
            }
    }
}
