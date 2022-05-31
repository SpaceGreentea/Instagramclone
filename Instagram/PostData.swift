//
//  PostData.swift
//  Instagram
//
//  Created by 矢野俊作 on 2022/05/19.
//

import UIKit
import Firebase
import FirebaseFirestore

class PostData: NSObject {
    var id: String
    var name: String?
    var caption: String?
    var date: Date?
    var likes: [String] = []
    var isLiked: Bool = false
    
    // 課題要件：コメント内容と投稿者名を追加
    var comments: [String] = []
    var contributor: [String] = []
    
    init(document: QueryDocumentSnapshot) {
        self.id = document.documentID //これはfirebase上のAyQDFIXBkZazCyeMvfrtなどのid
        
        let postDic = document.data() //これはfirebase上のname,caption,・・・などのデータ全て
        
        self.name = postDic["name"] as? String //postDic[なんとか]という書き方で目的のデータを取り出している
        
        self.caption = postDic["caption"] as? String
        
        let timestamp = postDic["date"] as? Timestamp
        self.date = timestamp?.dateValue()
        
        if let likes = postDic["likes"] as? [String] {
            self.likes = likes
        }
        if let myid = Auth.auth().currentUser?.uid {
            // likesの配列の中にmyidが含まれているかチェックすることで、自分がいいねを押しているかを判断
            if self.likes.firstIndex(of: myid) != nil {
                // myidがあれば、いいねを押していると認識する。
                self.isLiked = true
            }
        }
        
        // 課題要件：コメント内容と投稿者名を追加
        if let comments = postDic["comments"] as? [String] {
            self.comments = comments
        }
        
        if let contributor = postDic["contributor"] as? [String] {
            self.contributor = contributor
        }
        
    }
}
