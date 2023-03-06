//
//  PlayList.swift
//  rereplayer
//
//  Created by soojin jeong on 2023/01/19.
//

import Foundation
import RealmSwift

class RealmPlayList: Object {
    //@objc dynamic var id:Int = 0
    @objc dynamic var fileName:String = ""
    @objc dynamic var url:String = ""
    @objc dynamic var albumName:String = ""
    @objc dynamic var title:String = ""
    @objc dynamic var artist:String = ""
    //@objc dynamic var duration:Date
    
    // id 가 고유 값입니다.
    /*
    override static func primaryKey() -> String? {
      return "id"
    }
     */
}
