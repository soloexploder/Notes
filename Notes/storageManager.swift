//
//  storageManager.swift
//  Notes
//
//  Created by MacBook on 19.03.2021.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
    
    static func saveObject(_ note: Note) {
        try! realm.write {
            realm.add(note)
        }
    }
    
    static func deleteObject(_ note: Note) {
        try! realm.write {
            realm.delete(note)
        }
    }
}
