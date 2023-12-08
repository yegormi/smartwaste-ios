//
//  Extensions.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 05.11.2023.
//

import SwiftUI
import AlertToast

extension View {
    func invalidBorder(isActive: Bool) -> some View {
        self.modifier(InvalidBorderStyle(isInvalid: isActive))
    }
    
    func inputFieldStyle(type: KeyboardType) -> some View {
        self.modifier(InputFieldStyle(keyboard: type))
    }
    
    func scaleButton() -> some View {
        self.buttonStyle(ScaleButtonStyle())
    }
}


extension UIDevice {
    var hasNotch: Bool {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        guard let window = windowScene?.windows.first else { return false }
        
        return window.safeAreaInsets.top > 20
    }
}

extension NSLayoutConstraint {
    override public var description: String {
        let id = identifier ?? ""
        return "id: \(id), constant: \(constant)"
    }
}

extension Binding where Value: Equatable {
    func removeDuplicates() -> Self {
        .init(
            get: { self.wrappedValue },
            set: { newValue, transaction in
                guard newValue != self.wrappedValue else { return }
                self.transaction(transaction).wrappedValue = newValue
            }
        )
    }
}

extension AlertToast: Equatable {
    public static func == (lhs: AlertToast, rhs: AlertToast) -> Bool {
        // Implement your equality comparison logic here
        // You may need to compare the properties of AlertToast
        // Return true if they are equal, false otherwise
        return lhs.type == rhs.type
    }
}
