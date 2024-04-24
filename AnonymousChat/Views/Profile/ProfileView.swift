//
//  ProfileView.swift
//  AnonymousChat
//
//  Created by Chuen on 16/4/2024.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    @AppStorage("username") var username: String = "Please insert your name"
    @AppStorage("subtitle") var subtitle: String = ""
    @AppStorage("description") var description: String = ""
    @AppStorage("profileImageData") var imageData: Data =  UIImage(systemName: "person.circle.fill")?.jpeg(.highest) ?? Data()
    
    @State var isPresented = false
    @State var showImagePicker: Bool = false
    @State private var selectedItem: PhotosPickerItem?
    
    var body: some View {
        VStack {
            VStack {
                Text("Click below to change avatar")
                profileImageView
                    .onTapGesture {
                        showImagePicker = true
                    }
                profileText
            }
            Spacer()
            Button (
                action: { self.isPresented = true },
                label: {
                    Label("Edit Info", systemImage: "pencil")
            })
            .sheet(isPresented: $isPresented, content: {
                SettingsView()
            })
            Spacer()
        }
        .photosPicker(isPresented: $showImagePicker, selection: $selectedItem, matching: .any(of: [.images, .screenshots]))
        .onChange(of: selectedItem, { _, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    imageData = data
                }
            }
        })
    }
    
    var profileImageView: some View {
        ZStack(alignment: .top) {
            Circle()
                .fill(.white)
                .frame(width: 100, height: 100)
            
            Image(uiImage: UIImage(data: imageData) ?? UIImage.add)
                .resizable()
                .aspectRatio(1.0, contentMode: .fit)
                .frame(width: 100, height: 100)
                .clipShape(Circle())
        }
    }
    
    var profileText: some View {
        VStack(spacing: 15) {
            VStack(spacing: 5) {
                Text(username)
                    .bold()
                    .font(.title)
                Text(subtitle)
                    .font(.body)
                    .foregroundColor(.secondary)
            }.padding()
            Text(description)
                .multilineTextAlignment(.center)
                .padding()
            Spacer()
        }
    }
    
}

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("username") var username: String = "Please insert your name"
    @AppStorage("subtitle") var subtitle = ""
    @AppStorage("description") var description = ""

    var body: some View {
        NavigationView {
            List {
                nameSection
                subTitleSection
                desscriptionSection
            }
            .navigationBarTitle(Text("Settings"))
            .navigationBarItems(
                trailing:
                    Button (
                        action: {
                            dismiss()
                        },
                        label: {
                            Text("Done")
                        }
                    )
            )
        }
    }
    
    var nameSection: some View {
        Section(header: Text("Profile")) {
            TextField("Name", text: $username)
        }
    }
    
    var subTitleSection: some View {
        Section(header: Text("Subtitle")) {
            TextField("Subtitle", text: $subtitle)
        }
    }
    
    var desscriptionSection: some View {
        Section(header: Text("Description")) {
            TextField("Description", text: $description)
        }
    }
}
