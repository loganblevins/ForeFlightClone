//
//  DetailViewModel.swift
//  ForeFlightClone
//
//  Created by Logan Blevins on 9/20/21.
//

import Foundation

final class DetailViewModel {
    enum ReportKeys: String {
        case report, conditions, forecast
    }
    
    func conditions(for json: String) -> String? {
        return specificReport(with: json, for: ReportKeys.conditions.rawValue)
    }
    
    func forecast(for json: String) -> String? {
        return specificReport(with: json, for: ReportKeys.forecast.rawValue)
    }
    
    private func specificReport(with json: String, for key: String) -> String? {
        guard let data = json.data(using: .utf8) else { return nil }
        let obj = try? JSONSerialization.jsonObject( with: data, options: [] ) as? [String: AnyObject]
        guard let parsed = obj?[ReportKeys.report.rawValue]?[key] as? [String: AnyObject] else { return nil }
        guard let jsonData = try? JSONSerialization.data(withJSONObject: parsed, options: .prettyPrinted) else { return nil }
        let report = String(data: jsonData, encoding: .utf8)
        return (report?.isEmpty ?? true) ? nil : report
    }
}
