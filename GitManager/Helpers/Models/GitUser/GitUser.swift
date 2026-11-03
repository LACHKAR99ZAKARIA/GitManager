//
//  GitUser.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 11/5/2026.
//

import Foundation
import CoreTransferable
internal import UniformTypeIdentifiers

struct GitUser: Codable, Identifiable, Hashable, Transferable {
    var id = UUID()
    var url: URL
    var token: String
    var showInfos = true
    var profileImage: URL?
    var username: String?
    var name: String?
    
    func addUser() {
//        AppState.shared.addUser(self)
    }
    
    func removeUser() {
//        AppState.shared.removeUser(self)
    }
    
    func updateUser() {
//        AppState.shared.updateUser(self)
    }
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .json) { item in
            try JSONEncoder().encode(item)
        }
    }
}
