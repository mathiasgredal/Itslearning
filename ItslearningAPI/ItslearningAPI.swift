//
//  ItslearningAPI.swift
//  ItslearningAPI
//
//  Created by Mathias Gredal on 15/09/2021.
//

import OAuth2

protocol Resource { }

extension PersonCourse: Resource { }
extension CourseResource: Resource { }

public class ItslearningAPI {
    public static let shared = ItslearningAPI();
    
    private init() {
        print("Initializing Itslearning API")
    }
    
    
}
