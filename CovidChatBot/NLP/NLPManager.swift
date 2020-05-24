//
//  NLPManager.swift
//  CovidChatBot
//
//  Created by Narayanaswamy, Subhashini (623) on 10/05/20.
//  Copyright © 2020 Narayanaswamy, Subhashini (623). All rights reserved.
//

import Foundation
import UIKit

enum SubjectType: String {
    case confirmed = "Confirmed"
    case died = "Deaths"
    case recovered = "Recovered"
}

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
        } else if entityNames.contains("PlaceName") && (entityNames.contains("Verb") || entityNames.contains("OtherWord")){
            if let place = entities["PlaceName"]?.capitalized, let subject = mapEntities(entityName: entities["Verb"] ?? "") {
                if let message = processFromDB(subject: subject, place: place), message.count > 0 {
                    return message
                }
            } else if let place = entities["PlaceName"]?.capitalized, let sub = entities["OtherWord"], let subject = mapEntities(entityName: sub ) {
                if let message = processFromDB(subject: subject, place: place), message.count > 0 {
                    return message
                }
            }
        } else if entityNames.contains("OtherWord") || entityNames.contains("Adjective") {
            if let otherWord = entities["OtherWord"] {
                //for safety measures
                if otherWord.hasPrefix("safe") || otherWord.hasPrefix("measur") {
                    return "The motto during these difficult times is Stay Home Stay Safe. Please use sanitisers to keep your hands clean along with frequent washing of hands. Also, it is advisable to wear masks at all times when moving out of home.\n\nPlease use the Arogya Setu app to keep the Govt authorities informed in case of any health issues."
                }
            } else if let otherWord = entities["Adjective"] {
                //for safety measures
                if otherWord.hasPrefix("safe") || otherWord.hasPrefix("measur") {
                    return "The motto during these difficult times is Stay Home Stay Safe. Please use sanitisers to keep your hands clean along with frequent washing of hands. Also, it is advisable to wear masks at all times when moving out of home.\n\nPlease use the Arogya Setu app to keep the Govt authorities informed in case of any health issues."
                }
            }
        }
        return "Sorry... I could not understand that. I am still learning and my knowledge is limited to the subject of Covid. Please ask accordingly."
    }
    
    func processFromDB(subject: SubjectType, place: String) -> String? {
        if let count = DBManager.shared.readValuesFromDB(subject: subject.rawValue, place: place) {
            return getFinalString(count: count, subject: subject, place: place)
        }
        return nil
    }
    
    private func mapEntities(entityName: String) -> SubjectType? {
        if entityName.contains("onfirm") || entityName.contains("ffect") || entityName.contains("case") {
            //confirmed or affected
            return .confirmed
        } else if entityName.contains("ead") || entityName.contains("ie") || entityName.contains("eath") {
            //died or deaths or died
            return .died
        } else if entityName.contains("ecover") || entityName.contains("ure") {
            //recovered or cured
            return .recovered
        } else {
            return nil
        }
    }
    
    private func getFinalString(count: String, subject: SubjectType, place: String) -> String{
        switch subject {
        case .confirmed:
            return "The latest confirmed cases count stands at " + count + " in " + place
        case .died:
            return "The death count in " + place + " stands at " + count
        case .recovered:
            return count + " people have recovered in " + place
        }
    }
}
