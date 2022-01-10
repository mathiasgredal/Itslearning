//  SPDX-License-Identifier: CC-BY-NC-SA-4.0
//  Copyright (C) 2022 Mathias Gredal
//
//  EntityListOfPersonCourse.swift
//  ItslearningAPI

import Foundation

struct EntityListOfPersonCourse: Codable {
    let EntityArray: [PersonCourse];
    let Total: Int;
    let CurrentPageIndex: Int;
    let PageSize: Int;
}
