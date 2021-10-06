//
//  EntityListOfPersonCourse.swift
//  ItslearningAPI
//
//  Created by Mathias Gredal on 01/10/2021.
//

import Foundation

struct EntityListOfPersonCourse: Codable {
    let EntityArray: [PersonCourse];
    let Total: Int;
    let CurrentPageIndex: Int;
    let PageSize: Int;
}
