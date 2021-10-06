//
//  CourseFolderDetails.swift
//  ItslearningAPI
//
//  Created by Mathias Gredal on 01/10/2021.
//

import Foundation

struct Resources: Codable {
    let EntityArray: [CourseResource]
    let Total, CurrentPageIndex, PageSize: Int
}

struct CourseFolderDetails: Codable {
    let Resources: Resources
    let AddElementUrl: String?
}
