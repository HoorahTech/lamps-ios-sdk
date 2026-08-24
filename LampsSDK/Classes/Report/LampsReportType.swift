import Foundation

@objc enum LampsReportType: Int {
    case rm = 0
    case wm
    case cm
    case pm
    case rem

    var name: String {
        switch self {
        case .rm: return "RM"
        case .wm: return "WM"
        case .cm: return "CM"
        case .pm: return "PM"
        case .rem: return "REM"
        }
    }
}
