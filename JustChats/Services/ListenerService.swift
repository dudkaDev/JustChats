//
//  ListenerService.swift
//  JustChats
//
//  Created by Андрей Абакумов on 28.05.2023.
//

import Firebase

class ListenerService {
    
    static let shared = ListenerService()
    
    private let db = Firestore.firestore()
    
    private var currentUserId: String {
        return Auth.auth().currentUser!.uid
    }
    
    func messagesObserve(completion: @escaping (Result<Message, Error>) -> Void) -> ListenerRegistration? {
        let ref = db.collection("chat")
        
        let messagesListener = ref.addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                completion(.failure(error!))
                return
            }
            
            snapshot.documentChanges.forEach { (diff) in
                guard let message = Message(document: diff.document) else { return }
                switch diff.type {
                case .added:
                    completion(.success(message))
                case .modified:
                    break
                case .removed:
                    break
                }
            }
        }
        return messagesListener
    }
}
