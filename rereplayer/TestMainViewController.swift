//
//  TestMainViewController.swift
//  rereplayer
//
//  Created by soojin jeong on 2023/02/04.
//

import Foundation
import UIKit
//test
class TestMainViewController: UIViewController{
    var paramRate: String? // 값을 전달받을 속성
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("TestMainViewController viewDidLoad")
        
    }
    // 화면에 표시될 때마다 실행되는 메소드
    override func viewWillAppear(_ animated: Bool) {
        if let rate = paramRate {
            print("test");
            print(rate);
        }
    }
    
    @IBAction func btnTestClick(_ sender: Any) {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "RateSettingViewController") as? RateSettingViewController else {return}
        nextVC.modalPresentationStyle = .fullScreen//전체화면(기본은 팝업형태)
        
        nextVC.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
        nextVC.labelText="이동 완료"
        self.present(nextVC, animated: true)

    }
    
}
