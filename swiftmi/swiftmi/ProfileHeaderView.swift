//
//  ProfileHeaderView.swift
//  swiftmi
//
//  Created by yangyin on 15/4/16.
//  Copyright (c) 2015年 swiftmi. All rights reserved.
//

import UIKit

class ProfileHeaderView: UIView,UIGestureRecognizerDelegate {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var following: UILabel!
    @IBOutlet weak var follower: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var userName: UILabel!
    
    internal var tapLoginCallBack:(()->Bool)?
    
    var hasLogin:Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatar.layer.cornerRadius = 50
        avatar.layer.borderWidth = 1
        avatar.layer.borderColor = UIColor.white.cgColor
        avatar.layer.masksToBounds = true;
        
        self.follower.text = "0"
        self.following.text = "0"
        self.userName.text = "未登录"
        self.score.text = "0"
        
        initialFrame = profileBg.frame;
        initialHeight = initialFrame.size.height;
        
        let tap = UITapGestureRecognizer(target:self,action:#selector(ProfileHeaderView.tapLogin(_:)))
        
        self.avatar.isUserInteractionEnabled = true
        self.avatar.addGestureRecognizer(tap)
        
        
        
        let tap2 = UITapGestureRecognizer(target:self,action:#selector(ProfileHeaderView.tapLogin(_:)))
        
        self.userName.isUserInteractionEnabled = true
        self.userName.addGestureRecognizer(tap2)

    }
    
    func tapLogin(_ recognizer:UITapGestureRecognizer) {
        
        if self.tapLoginCallBack != nil && hasLogin == false {
            self.tapLoginCallBack!()
        }
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
    @IBOutlet weak var profileBg: UIImageView!
    
    var initialFrame:CGRect!;
    var initialHeight:CGFloat!;

    func setData(_ user:Users){

      
        avatar.kf_setImage(with: URL(string: user.avatar!)!, placeholder: nil)
       
        self.follower.text = "\(user.follower_count)"
        self.following.text = "\(user.following_count)"
        self.userName.text = "\(user.username)"
        self.score.text = "\(user.points)"
        
        hasLogin = true
    }
    
    func resetData(){
        
        avatar.image = nil
        self.follower.text = "0"
        self.following.text = "0"
        self.userName.text = "点击登录"
        self.score.text = "0"
        hasLogin = false
    }

    
    func scrollViewDidScroll(_ scrollView: UIScrollView!){
        
        if scrollView.contentOffset.y < 0 {
            let OffsetY:CGFloat = scrollView.contentOffset.y + scrollView.contentInset.top
            initialFrame.origin.y = OffsetY;
            initialFrame.size.height = initialHeight + (OffsetY * -1)
            
            
            profileBg.frame = initialFrame
        }

    }
    


}

extension ProfileHeaderView {
    class func viewFromNib() -> ProfileHeaderView? {
        let views = UINib(nibName: "ProfileHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)
        for view in views {
            if (view as AnyObject).isKind(of: self) {
                return view as? ProfileHeaderView
            }
        }
        return nil
    }
}
