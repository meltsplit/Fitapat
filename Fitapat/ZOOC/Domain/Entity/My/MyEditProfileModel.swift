import Foundation

struct MyEditProfileModel {
    let name: String
    let breed: String?
    let profileImg: Data?
    
    init(name: String, breed: String?, profileImg: Data?) {
        self.name = name
        self.breed = breed
        self.profileImg = profileImg
    }
}
