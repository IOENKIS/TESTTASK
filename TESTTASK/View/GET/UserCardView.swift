//
//  UserCardView.swift
//  TESTTASK
//
//  Created by Ivan Kisilov on 14.05.2025.
//

import SwiftUI

struct UserCardView: View {
    let avatar: UIImage
    let fullName: String
    let job: String
    let email: String
    let phone: String
    
    var body: some View {
        HStack(spacing: 32){
            VStack{
                Image(uiImage: avatar)
                    .clipShape(Circle())
                    .frame(width: 50, height: 50)
            }
            .offset(y: -20)
            VStack(alignment: .leading){
                Text(fullName)
                    .body2()
                Text(job)
                    .body3()
                    .padding(.top, 4)
                    .padding(.bottom, 8)
                Text(email)
                    .body3()
                Text(phone)
                    .body3()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 24)
    }
}

#Preview {
    UserCardView(avatar: UIImage(imageLiteralResourceName: "catLogo"), fullName: "Ivan Kisilov", job: "iOS Developer", email: "ivankiselev660@gmail.com", phone: "+38 (073) 099 29 73")
}
