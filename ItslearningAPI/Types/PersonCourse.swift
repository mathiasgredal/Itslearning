//
//  Course.swift
//  ItslearningAPI
//
//  Created by Mathias Gredal on 25/09/2021.
//

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
