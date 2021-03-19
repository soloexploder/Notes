//
//  NoteModel.swift
//  TheNote
//
//  Created by MacBook on 18.03.2021.
//

import RealmSwift

class Note: Object {
    @objc dynamic var name = ""
    @objc dynamic var discription: String?
    @objc dynamic var imageData: Data?        
}
