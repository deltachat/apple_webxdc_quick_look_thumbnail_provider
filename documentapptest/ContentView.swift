//
//  ContentView.swift
//  documentapptest
//
//  Created by bb on 10.09.23.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: documentapptestDocument

    var body: some View {
        TextEditor(text: $document.text)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(documentapptestDocument()))
    }
}
