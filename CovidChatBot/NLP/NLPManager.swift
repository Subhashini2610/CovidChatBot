//
//  NLPManager.swift
//  CovidChatBot
//
//  Created by Narayanaswamy, Subhashini (623) on 10/05/20.
//  Copyright © 2020 Narayanaswamy, Subhashini (623). All rights reserved.
//

import Foundation

import UIKit

class NLPManager {
    
    public static var shared = NLPManager()
    var recordsArray = Array<Any>()

    let tagger = NSLinguisticTagger(tagSchemes: [.tokenType, .language, .lexicalClass, .nameType, .lemma], options: 0)

    let options: NSLinguisticTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]

    func languageIdentification(input: String) {
        tagger.string = input
        print(tagger.dominantLanguage!)
    }

    func tokenizeString(input: String) {
        tagger.string = input
        
        let range = NSRange(location: 0, length: (tagger.string?.utf16.count)!)
        
        tagger.enumerateTags(in: range, unit: .word, scheme: .tokenType, options: options) { (tag, tokenRange, _) in
            let word = (input as NSString).substring(with: tokenRange)
            print(word)
        }
    }

    func lemmatizeString(input: String) {
        tagger.string = input
        
        let range = NSRange(location: 0, length: tagger.string!.count)
        
        tagger.enumerateTags(in: range, unit: .word, scheme: .lemma, options: options) { (tag, range, _) in
            if let lemma = tag?.rawValue {
                print(lemma)
            }
        }
    }

    func partOfSpeech(input: String) {
        tagger.string = input
        
        let range = NSRange(location: 0, length: tagger.string!.count)
        
        tagger.enumerateTags(in: range, unit: .word, scheme: .lexicalClass, options: options) { (tag, tokenRange, _) in
            if let tag = tag {
                let word = (input as NSString).substring(with: tokenRange)
                print("\(tag.rawValue) -> \(word)")
            }
        }
    }

    func namedEntity(input: String) -> [String: String] {
        tagger.string = input
        var entities = [String: String]()
        
        let range = NSRange(location: 0, length: tagger.string!.count)
        
        tagger.enumerateTags(in: range, unit: .word, scheme: .lexicalClass, options: options) { (tag, tokenRange, _) in
            if let tag = tag {
                let name = (input as NSString).substring(with: tokenRange)
                if tag == .noun {
                    tagger.enumerateTags(in: tokenRange, unit: .word, scheme: .nameType, options: options) { (nameTag, nameTokenRange, _) in
                        if let name = nameTag {
                            entities[name.rawValue] = (input as NSString).substring(with: tokenRange)
                        }
                    }
                } else {
                    entities[tag.rawValue] = name
                }
            }
        }
        return entities
    }
    
    func processText(message: String) -> String? {
        let entities = namedEntity(input: message)
        let replyMessage = processEntities(entities: entities)
        return replyMessage
    }
    
    private func processEntities(entities: [String: String]) -> String? {
        let entityNames = Array(entities.keys)
        if entityNames.contains("PersonalName") {
            if let username = entities["PersonalName"] {
                return "Hi \(username)! How can I help you?"
            }
        } else if entityNames.contains("PlaceName") && entityNames.contains("Verb"){
            DBManager.shared.readFromDB()
        } else {
            return "Sorry... I could not understand that. My knowledge is limited to the subject of Covid. Please ask accordingly."
        }
        return nil
    }
}

//languageIdentification()
//print("*****************************************************")
//tokenizeString()
//print("*****************************************************")
//lemmatizeString()
//print("*****************************************************")
//partOfSpeech()
//print("*****************************************************")
//namedEntity(str: "Gayathri works at Apple Inc")
