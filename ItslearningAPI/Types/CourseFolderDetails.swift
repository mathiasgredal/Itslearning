//  SPDX-License-Identifier: CC-BY-NC-SA-4.0
//  Copyright (C) 2022 Mathias Gredal
//
//  CourseFolderDetails.swift
//  ItslearningAPI

import Foundation

struct Resources: Codable {
    let EntityArray: [CourseResource]
    let Total, CurrentPageIndex, PageSize: Int
}

struct CourseFolderDetails: Codable {
    let Resources: Resources
    let AddElementUrl: String?
}
