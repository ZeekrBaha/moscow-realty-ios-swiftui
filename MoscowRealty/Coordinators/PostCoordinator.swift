import Observation
import SwiftUI

enum PostStep: Int, CaseIterable {
    case typeSelection = 0
    case location      = 1
    case details       = 2
    case photos        = 3
    case confirmation  = 4
}

@Observable
final class PostCoordinator {
    var path = NavigationPath()
    var isAuthRequired = false
    var currentStep: PostStep = .typeSelection

    func requireAuth() { isAuthRequired = true }

    func nextStep() {
        let allSteps = PostStep.allCases
        if let idx = allSteps.firstIndex(of: currentStep),
           idx + 1 < allSteps.count {
            currentStep = allSteps[idx + 1]
        }
    }

    func previousStep() {
        let allSteps = PostStep.allCases
        if let idx = allSteps.firstIndex(of: currentStep), idx > 0 {
            currentStep = allSteps[idx - 1]
        }
    }

    func resetToStart() {
        currentStep = .typeSelection
        path = NavigationPath()
    }
}
