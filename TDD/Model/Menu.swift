//
//  Menu.swift
//  TDD
//
//  Created by Denny Arfansyah on 28/01/25.
//

struct GeneralRespons: Decodable {
    let timestamp: String
    let traceId: String
    let sourceSystem: String
    let responseKey: String
    let message: MessageResponse
    let data: [MenuResponse]
}

struct MessageResponse: Decodable {
    let titleIdn: String
    let titleEng: String
    let descIdn: String
    let descEng: String
}

struct MenuResponse: Decodable {
    let menuBillerId: Int
    let categoryBillerId: String
    let labelEng: String
    let labelIdn: String
    let serviceCategory: Int
    let othersCategory: String
    let noOrder: Int
    let serviceRoute: String
    let menuBillerCode: String
    let icon1: String
    let icon2: String
    let icon3: String
}
