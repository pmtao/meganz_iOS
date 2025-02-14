import Foundation

extension Int {
    public func string(allowedUnits: NSCalendar.Unit,
                unitStyle: DateComponentsFormatter.UnitsStyle = .full) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = allowedUnits
        formatter.unitsStyle = unitStyle
        return formatter.string(from: TimeInterval(self))
    }
}
