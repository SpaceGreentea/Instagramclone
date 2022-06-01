//
//  PostTableViewCell.swift
//  Instagram
//
//  Created by 矢野俊作 on 2022/05/19.
//

import UIKit
import SDWebImage
import FirebaseStorageUI
import Firebase //課題要件用に追加
import FirebaseFirestore //課題要件用に追加
import SVProgressHUD //課題要件用に追加

class PostTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    
    // 課題要件：コメントと投稿者名
    @IBOutlet weak var commentsTextField: UITextField!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var contributorLabel: UILabel!
    
    var postDataid = ""
    
    // 課題要件：投稿ボタンをタップしたときのメソッド
    @IBAction func postButton(_ sender: Any) {
        // コメントの保存場所を定義する
        let postRef = Firestore.firestore().collection(Const.PostPath).document(postDataid)
        // HUDで投稿処理中の表示を開始
        SVProgressHUD.show()
        
        // 課題用 日付の取得
        let date = Date()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let strDate = formatter.string(from: date)
        
        // FireStoreにコメントと投稿者名を保存する
        let contributorLabel = strDate + Auth.auth().currentUser!.displayName!
//        let contributorLabel = strDate + Auth.auth().currentUser?.displayName
//        let postDic = [
//            "contributor": contributorLabel!,
//            "comments": self.commentsTextField.text!,
//        ] as [String : Any]
//        postRef.updateData(postDic)
        
        //let commentUpdateValue = FieldValue.arrayUnion([self.commentsTextField.text!])
        let commentUpdateValue = FieldValue.arrayUnion([strDate + self.commentsTextField.text!])
        let contributorUpdateValue = FieldValue.arrayUnion([contributorLabel])
        
        postRef.updateData(["comments": commentUpdateValue, "contributor": contributorUpdateValue])
        
        // HUDで投稿完了を表示する
        SVProgressHUD.showSuccess(withStatus: "投稿しました")
        // 投稿後キーボードを閉じる
        self.commentsTextField.endEditing(true)
        // 投稿後テキストフィールドの文字を消す
        self.commentsTextField.text = ""
    }
    
    // 課題用：コメント入力中にキーボードを閉じれるようにするメソッド
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        commentsTextField.endEditing(true)
    }
    
    // PostDataの内容をセルに表示
    func setPostData(_ postData: PostData) {
        
        postDataid = postData.id //課題用
        
        // 画像の表示
        //print("postImageView \(postImageView)")
        postImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postData.id + ".jpg")
        postImageView.sd_setImage(with: imageRef)
        
        // キャプションの表示
        self.captionLabel.text = "[投稿者]\n\(postData.name!) : \(postData.caption!)"
        
        // 日時の表示
        self.dateLabel.text = ""
        if let date = postData.date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            let dateString = formatter.string(from: date)
            self.dateLabel.text = dateString
        }
        
        // いいね数の表示
        let likeNumber = postData.likes.count
        print("likeNumber \(likeNumber)")
        likeLabel.text = "\(likeNumber)"
        
        // いいねボタンの表示
        if postData.isLiked {
            let buttonImage = UIImage(named: "like_exist")
            self.likeButton.setImage(buttonImage, for: .normal)
        } else {
            let buttonImage = UIImage(named: "like_none")
            self.likeButton.setImage(buttonImage, for: .normal)
        }
        
        // 課題要件：コメントと投稿者名を表示
//        let commentsArray = postData.comments
//        print("postData \(postData)")
//        print("commentsArray \(commentsArray)")
//        var commentsContents = ""
//        for comment in commentsArray {
//            commentsContents += "\(comment)\n"
//        }
//        print("commentsContents \(commentsContents)")
//
//        let contributorArray = postData.contributor
//        var contributorContents = ""
//        for contributor in contributorArray {
//            contributorContents += "\(contributor)\n"
//        }
//        self.contributorLabel.text = "\(contributorContents) : \(commentsContents)"
        
        var comments = ""
        
        for (i, text) in postData.comments.enumerated() {
            
            //print(text)
            //print(type(of: text))
            
            var comment = text
            comment.removeFirst(19)
            
            var contributor = postData.contributor[i]
            contributor.removeFirst(19)
            
            comments += "\(contributor) : \(comment)\n"
        }
        
        self.contributorLabel.text = "[投稿者へのコメント]\n\(comments)"
    }
}
