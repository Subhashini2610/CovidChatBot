//
//  DBManager.swift
//  CovidChatBot
//
//  Created by Narayanaswamy, Subhashini (623) on 11/05/20.
//  Copyright © 2020 Narayanaswamy, Subhashini (623). All rights reserved.
//

import Foundation
import SQLite3

class DBManager {
    
    public static var shared = DBManager()

    func readFromDB() {
        
        if let fileURL = Bundle.main.url(forResource: "Data", withExtension: "db") {
            // open database
            var db: OpaquePointer?
            guard sqlite3_open(fileURL.path, &db) == SQLITE_OK else {
                print("error opening database")
                sqlite3_close(db)
                db = nil
                return
            }
            var statement: OpaquePointer?
            if sqlite3_prepare_v2(db, "select * from CovidData where Country_Region = 'India'", -1, &statement, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing select: \(errmsg)")
            }

            while sqlite3_step(statement) == SQLITE_ROW {
                let id = sqlite3_column_int64(statement, 0)
                print("id = \(id); ", terminator: "")

                if let cString = sqlite3_column_text(statement, 1) {
                    let name = String(cString: cString)
                    print("name = \(name)")
                } else {
                    print("name not found")
                }
            }

            if sqlite3_finalize(statement) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error finalizing prepared statement: \(errmsg)")
            }

            statement = nil
            if sqlite3_close(db) != SQLITE_OK {
                print("error closing database")
            }

            db = nil
        }

        
        
    }
    
}
