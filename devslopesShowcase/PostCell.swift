//
//  PostCell.swift
//  devslopesShowcase
//
//  Created by Evan on 3/18/16.
//  Copyright © 2016 Evan. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class PostCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var showcaseImage: UIImageView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var likeImage: UIImageView!
    
    var post: Post!
    var request: Request?
    var likeRef: Firebase!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: "likeTapped:")
        tap.numberOfTapsRequired = 1
        likeImage.addGestureRecognizer(tap)
        likeImage.userInteractionEnabled = true
        
    }
    
    override func drawRect(rect: CGRect) {
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.clipsToBounds = true
        
        showcaseImage.clipsToBounds = true 
    }

    func configureCell(post: Post, img: UIImage?) {
        self.post = post
        
        likeRef = DataService.ds.REF_USER_CURRET.childByAppendingPath("likes").childByAppendingPath(post.postKey)
        
        self.descriptionText.text = post.postDescription
        self.likesLabel.text = "\(post.likes)"
        
        if post.imageUrl != nil {
            
            if img != nil {
                self.showcaseImage.image = img
            } else {
                
                request = Alamofire.request(.GET, post.imageUrl!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                    
                    if err == nil {
                        let img = UIImage(data: data!)!
                        self.showcaseImage.image = img
                        FeedVC.imageCache.setObject(img, forKey: self.post.imageUrl!)
                    }
                    
                })
                
            }
        } else {
            self.showcaseImage.hidden = true
        }
        
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
        
            if let doesNotExist = snapshot.value as? NSNull {
                //this means we have not liked this specific post
                self.likeImage.image = UIImage(named: "heart-empty")
            } else {
                self.likeImage.image = UIImage(named: "heart-full")
            }
        })
        
    }

    
    func likeTapped(sender: UITapGestureRecognizer) {
        
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
        
        if let doesNotExist = snapshot.value as? NSNull {
            //this means we have not liked this specific post
            self.likeImage.image = UIImage(named: "heart-full")
            self.post.adjustLikes(true)
            self.likeRef.setValue(true)
        } else {
            self.likeImage.image = UIImage(named: "heart-empty")
            self.post.adjustLikes(false)
            self.likeRef.removeValue()
        }
    })
    
}


}