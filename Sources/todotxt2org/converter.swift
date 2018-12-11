//
//  converter.swift
//  todotxttoorg
//
//  Based on the todo.txt syntax defined at https://github.com/todotxt/todo.txt
//
//  Created by Matthew Kennard on 10/12/2018.
//  Copyright © 2018 Apps On The Move Limited. All rights reserved.
//

import Foundation

class TodoTxtConverter {
    let priorityRegex = try! NSRegularExpression(pattern: "\\(([A-Z])\\)", options: [])
    let projectTagRegex = try! NSRegularExpression(pattern: "(?:^|\\s)\\+([^\\s]+)", options: [])
    let contextTagRegex = try! NSRegularExpression(pattern: "(?:^|\\s)@([^\\s]+)", options: [])
    let keyValueTagRegex = try! NSRegularExpression(pattern: "(?:^|\\s)([^\\s\\:]+\\:[^\\s\\:]+)", options: [])
    let dateFormatter: DateFormatter
        
    init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
    }
    
    func convert(input: String) -> String {
        var projects = [String: [String]]()
        let separators = CharacterSet.whitespaces
        
        input.enumerateLines { [weak self] (line, _) in
            guard let self = self else { return }
            
            var components = line.split(whereSeparator: { (character) -> Bool in
                return !character.unicodeScalars.contains(where: { !separators.contains($0) })
            }).map { String($0) }
            
            // Determine if the task has been completed
            let done = components.first == "x"
            if done {
                _ = components.removeFirst()
            }
            
            // Grab the task priority
            let priority: String?
            if let possiblePriority = components.first {
                priority = self.priorityFrom(component: possiblePriority)
                if priority != nil {
                    _ = components.removeFirst()
                }
            } else {
                priority = nil
            }
            
            // See what dates there are (either none, just a creation date or a creation and completion date)
            let completionDate: Date?
            let creationDate: Date?
            if let possibleDate1 = components.first, let date1 = self.dateFrom(component: possibleDate1) {
                _ = components.removeFirst()
                if let possibleDate2 = components.first, let date2 = self.dateFrom(component: possibleDate2) {
                    _ = components.removeFirst()
                    completionDate = date1
                    creationDate = date2
                } else {
                    completionDate = nil
                    creationDate = date1
                }
            } else {
                completionDate = nil
                creationDate = nil
            }
            
            // The rest is just to be treated as one string
            let text = components.joined(separator: " ")
            
            // See which project this belongs to (only first project used)
            let project = self.projectFrom(text: text) ?? "Tasks"
            let tags = self.tagsFrom(text: text)
            let keyValues = self.keyValuesFrom(text: text)
            
            // Remove the above from the text
            let cleanedText = self.removeTodoTxtTags(text: text, project: project, tags: tags, keyValues: keyValues)
            
            let orgStatus = done ? "DONE" : "TODO"
            let orgPriority = priority == nil ? "" : "[#\(priority!)]"
            let orgTags = tags.count > 0 ? ":\(tags.joined(separator: ":")):" : ""
            let orgHeading = [orgStatus, orgPriority, cleanedText, orgTags].filter { $0 != "" }.joined(separator: " ")
            let orgNotes = self.notes(completionDate: completionDate, creationDate: creationDate, keyValues: keyValues)
            let node = ["** \(orgHeading)", orgNotes].filter { $0 != "" }.joined(separator: "\n")
            
            var projectTasks = projects[project] ?? []
            projectTasks.append(node)
            projects[project] = projectTasks
        }
        
        return projects.map { (key, value) in
            return (["* \(key)"] + value).joined(separator: "\n")
        }.joined(separator: "\n")
    }
    
    func matchedStrings(from string: String, with regEx: NSRegularExpression) -> [String] {
        return regEx.matches(in: string, options: [], range: NSRange(location: 0, length: string.count)).map { match in
            if match.range.location != NSNotFound, let substring = string.substring(with: match.range(at: 1)) {
                return String(substring)
            } else {
                return ""
            }
        }.filter { $0 != "" }
    }
    
    func priorityFrom(component: String) -> String? {
        return matchedStrings(from: component, with: priorityRegex).first
    }
    
    func stringFrom(date: Date?) -> String {
        if let date = date {
            return dateFormatter.string(from: date)
        } else {
            return ""
        }
    }
    
    func dateFrom(component: String) -> Date? {
        return dateFormatter.date(from: component)
    }
    
    func projectFrom(text: String) -> String? {
        return matchedStrings(from: text, with: projectTagRegex).first
    }
    
    func tagsFrom(text: String) -> [String] {
        return matchedStrings(from: text, with: contextTagRegex)
    }
    
    func keyValuesFrom(text: String) -> [String:String] {
        return matchedStrings(from: text, with: keyValueTagRegex)
            .map { $0.components(separatedBy: ":") }
            .reduce(into: [String: String]()) { dict, pair in
                if pair.count == 2 {
                    dict[pair[0]] = pair[1]
                }
            }
    }
    
    func notes(completionDate: Date?, creationDate: Date?, keyValues: [String: String]) -> String {
        var components = [String]()
        if let date = completionDate {
            components.append("CLOSED: [\(stringFrom(date: date))]")
        }
        if let date = creationDate {
            components.append("[\(stringFrom(date: date))]")
        }
        keyValues.forEach { [weak self] (key, value) in
            guard let self = self else { return }
            if key == "due", let date = self.dateFrom(component: value) {
                components.append("DEADLINE: <\(self.stringFrom(date: date))>")
            }
        }
        return components.joined(separator: "\n")
    }
    
    func removeTodoTxtTags(text: String, project: String, tags: [String], keyValues: [String: String]) -> String {
        var cleanedText = projectTagRegex.stringByReplacingMatches(in: text, options: [], range: NSRange(location: 0, length: text.count), withTemplate: "")
        cleanedText = contextTagRegex.stringByReplacingMatches(in: cleanedText, options: [], range: NSRange(location: 0, length: cleanedText.count), withTemplate: "")
        cleanedText = keyValueTagRegex.stringByReplacingMatches(in: cleanedText, options: [], range: NSRange(location: 0, length: cleanedText.count), withTemplate: "")
        return cleanedText.condenseWhitespace()
    }
}

extension String {
    func substring(with nsRange: NSRange) -> Substring? {
        guard let range = Range(nsRange, in: self) else { return nil }
        return self[range]
    }
    
    func condenseWhitespace() -> String {
        return self.components(separatedBy: .whitespaces).filter { !$0.isEmpty }.joined(separator: " ")
    }
}
