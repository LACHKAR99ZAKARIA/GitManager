//
//  LoaderManager.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 3/11/2026.
//

import UIKit

/// Affiche un loader UIKit par-dessus la fenêtre active.
/// La vue ne capte aucun touch (`isUserInteractionEnabled = false`), donc le
/// swipe back de la navigation et les autres gestes restent actifs.
final class LoaderManager {
    static let shared = LoaderManager()
    
    private var overlayView: UIView?
    
    private init() {}
    
    @MainActor
    func show() {
        guard overlayView == nil, let window = keyWindow else { return }
        
        let overlay = UIView(frame: window.bounds)
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlay.backgroundColor = UIColor(named: "bg35")?.withAlphaComponent(0.6)
        overlay.isUserInteractionEnabled = false
        overlay.alpha = 0
        
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = UIColor(named: "principal")
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        overlay.addSubview(indicator)
        
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: overlay.centerYAnchor)
        ])
        
        window.addSubview(overlay)
        overlayView = overlay
        
        UIView.animate(withDuration: 0.2) {
            overlay.alpha = 1
        }
    }
    
    @MainActor
    func hide() {
        guard let overlay = overlayView else { return }
        overlayView = nil
        
        UIView.animate(withDuration: 0.2, animations: {
            overlay.alpha = 0
        }, completion: { _ in
            overlay.removeFromSuperview()
        })
    }
    
    private var keyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)
    }
}
