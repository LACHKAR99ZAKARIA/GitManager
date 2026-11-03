//
//  String+GitLabDate.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 3/11/2026.
//

import Foundation

extension Optional where Wrapped == String {
    /// Date relative courte (« 8h », « 3 d ») à partir d'une date ISO 8601 GitLab.
    var gitLabRelativeDate: String? {
        guard let value = self else { return nil }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = formatter.date(from: value) ?? ISO8601DateFormatter().date(from: value) else { return nil }
        let relative = RelativeDateTimeFormatter()
        relative.unitsStyle = .abbreviated
        return relative.localizedString(for: date, relativeTo: Date())
    }
}
