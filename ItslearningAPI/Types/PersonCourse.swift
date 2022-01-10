//  SPDX-License-Identifier: CC-BY-NC-SA-4.0
//  Copyright (C) 2022 Mathias Gredal
//
//  PersonCourse.swift
//  ItslearningAPI

import Foundation
import SwiftUI

struct PersonCourse: Codable {
    var itemId: ItemID?;
    let Title: String;
    let LastUpdatedUtc: String;
    let NewNotificationsCount: Int;
    let NewBulletinsCount: Int;
    let Url: String;
    let HasAdminPermissions: Bool;
    let HasStudentPermissions: Bool?;
    let CourseId: Int;
    let FriendlyName: String?;
    let CourseColor: String;
    let CourseFillColor: String;
    let CourseCode: String;
}
