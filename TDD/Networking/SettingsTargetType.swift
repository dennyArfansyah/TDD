//
//  SettingsTargetType.swift
//  TDD
//
//  Created by Denny Arfansyah on 28/01/25.
//

import Foundation
import Moya

enum SettingsTargetType: TargetType {
    case getSettings
    
    var baseURL: URL { URL(string: "https://octomobile-uat.cimbniaga.co.id/staging/api/")! }
    var path: String { "parameter/biller/menus" }
    var method: Moya.Method { .get }
    var task: Moya.Task { .requestPlain }
    var headers: [String : String]? {
        [
            "X-Device-Info": "iOS",
            "Content-Type" : "application/vnd.api.v4+json",
            "Application-Version": "3.1.40",
            "X-Device-ID": "24629109-0F53-4B93-9614-659C4209C344"
        ]
    }
}
