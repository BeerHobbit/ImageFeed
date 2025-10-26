import Foundation
@testable import ImageFeed

final class ProfileLogoutServiceSpy: ProfileLogoutServiceProtocol {
    
    private(set) var logoutCalled: Bool = false
    
    func logout() {
        logoutCalled = true
    }
    
}
