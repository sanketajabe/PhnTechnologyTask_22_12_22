//
//  User.swift
//  PhnTechnologyTask_22_12_22
//
//  Created by Apple on 23/12/22.
//

import Foundation
struct ApiResponseForUser : Decodable{
    var  products : [Product]
}
struct Product : Decodable{
        let id: Int
        let title : String
        let price: Double
}
