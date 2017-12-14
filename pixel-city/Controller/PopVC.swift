//
//  PopVC.swift
//  pixel-city
//
//  Created by 張書涵 on 2017/12/14.
//  Copyright © 2017年 AliceChang. All rights reserved.
//

import UIKit

class PopVC: UIViewController,UIGestureRecognizerDelegate {

    @IBOutlet weak var popImageView: UIImageView!
    var passImage:UIImage!
    //用PopVC.initData把MapVC的相片傳到這個VC
    func initData(forimage image:UIImage){
        self.passImage = image
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popImageView.image = passImage
        addDoubleTap()//記得addDoubleTap

    
    }
    //按兩下就會收起來
    func addDoubleTap(){
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(screenWasDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        view.addGestureRecognizer(doubleTap)
        
    }
    
    @objc func screenWasDoubleTap(){
        dismiss(animated: true, completion: nil)
    }
}
