//
//  ItemID.swift
//  ItslearningAPI
//
//  Created by Mathias Gredal on 20/11/2021.
//

import Foundation


/// An item id is a underscore seperated path to the item from the root.
/// The first number is always the base course
/// The numbers before the last will always be folders
/// The last number may be a folder or an item

enum ItemIdError : Error {
    case numberFormatError;
    case EmptyListError;
    case noContainingFolderExists;
}

enum ItemType {
    case Course;
    case Resource;
}

struct ItemID : Codable {
    let itemId: [Int]
    
    /// Create from list
    init(idList: [Int]) {
        itemId = idList
    }
    
    /// Append item to itemid
    init(_itemId: ItemID, newItem: Int) {
        itemId = _itemId.itemId + [newItem]
    }
    
    /// Create from course id
    init(courseId: Int) {
        itemId = [courseId]
    }
    
    /// Create ItemID from string
    init(idString: String) throws {
        // The id format is seperated by underscores
        let idList = idString.split(separator: "_")
        
        // The list must contain at least one element
        if(idList.count == 0) {
            throw ItemIdError.EmptyListError
        }
        
        // Convert the list to integers
        var idParsedList: [Int] = []
        for id in idList {
            guard let idParsed = Int(id) else {
                throw ItemIdError.numberFormatError
            }
            idParsedList.append(idParsed)
        }
        
        // Assign attributes
        itemId = idParsedList
    }
    
    public var itemType: ItemType {
        return itemId.count == 1 ? ItemType.Course : ItemType.Resource
    }
    
    public func getContainingFolder() throws -> ItemID {
        if(itemId.count < 2) {
            throw ItemIdError.noContainingFolderExists
        }
                
        return ItemID(idList: itemId.dropLast())
    }
    
    public var baseItem: String {
        return String(itemId[itemId.count - 1])
    }
    
    /// Gets the course id, which will always be the first element
    public var courseId: String {
        return String(itemId[0])
    }
    
    /// Convert the item id to string representation
    public var description: String {
        return itemId.map{String($0)}.joined(separator: "_")
    }
}
