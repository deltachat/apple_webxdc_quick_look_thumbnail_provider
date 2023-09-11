//
//  documentapptestApp.swift
//  documentapptest
//
//  Created by bb on 10.09.23.
//

import SwiftUI

@main
struct documentapptestApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: documentapptestDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}
