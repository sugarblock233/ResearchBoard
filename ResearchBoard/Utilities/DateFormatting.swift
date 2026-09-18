import Foundation

extension Date {
    var researchBoardShortDate: String {
        formatted(.dateTime.month(.abbreviated).day())
    }

    var researchBoardRelative: String {
        formatted(.relative(presentation: .named, unitsStyle: .abbreviated))
    }
}
