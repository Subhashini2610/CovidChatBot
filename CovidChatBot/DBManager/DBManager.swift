//
//  DBManager.swift
//  CovidChatBot
//
//  Created by Narayanaswamy, Subhashini (623) on 11/05/20.
//  Copyright © 2020 Narayanaswamy, Subhashini (623). All rights reserved.
//

import Foundation
import SQLite3
import GRDB

class DBManager {
    
    public static var shared = DBManager()
    
    let dbQueue: DatabaseQueue?

    init() {
        do {
            dbQueue = try DatabaseQueue(path: Bundle.main.path(forResource: "Data", ofType: "db")!)
        } catch  {
            dbQueue = DatabaseQueue()
            print("DB error")
        }
    }
    

//    func readFromDB() {
//
//        if let fileURL = Bundle.main.url(forResource: "Data", withExtension: "db") {
//            // open database
//            var db: OpaquePointer?
//            guard sqlite3_open(fileURL.path, &db) == SQLITE_OK else {
//                print("error opening database")
//                sqlite3_close(db)
//                db = nil
//                return
//            }
//            var statement: OpaquePointer?
//            if sqlite3_prepare_v2(db, "select * from CovidData where Country_Region = 'India'", -1, &statement, nil) != SQLITE_OK {
//                let errmsg = String(cString: sqlite3_errmsg(db)!)
//                print("error preparing select: \(errmsg)")
//            }
//
//            while sqlite3_step(statement) == SQLITE_ROW {
//                let id = sqlite3_column_int64(statement, 0)
//                print("id = \(id); ", terminator: "")
//
//                if let cString = sqlite3_column_text(statement, 1) {
//                    let name = String(cString: cString)
//                    print("name = \(name)")
//                } else {
//                    print("name not found")
//                }
//            }
//
//            if sqlite3_finalize(statement) != SQLITE_OK {
//                let errmsg = String(cString: sqlite3_errmsg(db)!)
//                print("error finalizing prepared statement: \(errmsg)")
//            }
//
//            statement = nil
//            if sqlite3_close(db) != SQLITE_OK {
//                print("error closing database")
//            }
//
//            db = nil
//        }
//
//
//
//    }
    
    func readValuesFromDB(subject: String, place: String) -> String? {
        var count: String?
        if let dbQueue = dbQueue {
            do {
                try dbQueue.read { db in
                    // Fetch for country
                    let rows = try Row.fetchCursor(db, sql: "SELECT \(subject) FROM CovidData where Country_Region = '\(place)' and AdminRegion1 = '' order by Updated desc limit 1")
                    while let row = try rows.next() {
                        count = row[subject]
                    }
                }
            } catch  {
                print("DB fetch error")
            }
        }
        return count
    }
    
}
