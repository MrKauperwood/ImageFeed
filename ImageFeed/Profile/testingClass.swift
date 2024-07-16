import Foundation

// Предположим, что у вас есть валидный токен
let token = "Px8gScKdEwhtmcwpMl6FNH5IjMggkHGaFXc-C393M1g"

// Создайте экземпляр ProfileService
let profileService = ProfileService()

// Вызовите метод fetchProfile
profileService.fetchProfile(token) { result in
    switch result {
    case .success(let profile):
        print("Profile fetched successfully:")
        print("Username: \(profile.username)")
        print("Name: \(profile.name)")
        print("Login Name: \(profile.loginName)")
        print("Bio: \(profile.bio ?? "No bio available")")
    case .failure(let error):
        print("Failed to fetch profile with error: \(error.localizedDescription)")
    }
}

