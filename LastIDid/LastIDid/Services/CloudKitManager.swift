//
//  CloudKitManager.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/20/26.
//

import Foundation
import CloudKit
import SwiftData

/// Manager for iCloud sync status and configuration
/// Note: Actual sync is handled by SwiftData's CloudKit integration
class CloudKitManager: ObservableObject {
    static let shared = CloudKitManager()

    @Published var iCloudStatus: CKAccountStatus = .noAccount
    @Published var isCheckingStatus = false
    @Published var lastSyncDate: Date?
    @Published var syncError: String? = "iCloud sync coming soon"

    private var container: CKContainer?

    // Set this to true once CloudKit entitlements are properly configured in Xcode
    private static let isCloudKitEnabled = false

    private init() {
        // CloudKit initialization is disabled until entitlements are configured
        // To enable: 1) Add CloudKit capability in Xcode, 2) Set isCloudKitEnabled = true
        guard Self.isCloudKitEnabled else {
            return
        }

        initializeContainer()
    }

    private func initializeContainer() {
        // Only called when CloudKit is explicitly enabled
        if FileManager.default.ubiquityIdentityToken != nil {
            container = CKContainer.default()
            checkAccountStatus()
            setupAccountChangeNotification()
        } else {
            iCloudStatus = .noAccount
            syncError = "Not signed in to iCloud"
        }
    }

    // MARK: - Account Status

    func checkAccountStatus() {
        guard let container = container else {
            iCloudStatus = .noAccount
            isCheckingStatus = false
            return
        }

        isCheckingStatus = true

        container.accountStatus { [weak self] status, error in
            DispatchQueue.main.async {
                self?.isCheckingStatus = false
                self?.iCloudStatus = status

                if let error = error {
                    self?.syncError = error.localizedDescription
                } else {
                    self?.syncError = nil
                }
            }
        }
    }

    private func setupAccountChangeNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(accountChanged),
            name: .CKAccountChanged,
            object: nil
        )
    }

    @objc private func accountChanged() {
        checkAccountStatus()
    }

    // MARK: - Status Helpers

    var isSignedIn: Bool {
        iCloudStatus == .available
    }

    var statusDescription: String {
        switch iCloudStatus {
        case .available:
            return "Signed in to iCloud"
        case .noAccount:
            return "Not signed in to iCloud"
        case .restricted:
            return "iCloud access restricted"
        case .couldNotDetermine:
            return "Checking iCloud status..."
        case .temporarilyUnavailable:
            return "iCloud temporarily unavailable"
        @unknown default:
            return "Unknown iCloud status"
        }
    }

    var statusIcon: String {
        switch iCloudStatus {
        case .available:
            return "checkmark.icloud.fill"
        case .noAccount:
            return "xmark.icloud.fill"
        case .restricted:
            return "lock.icloud.fill"
        case .couldNotDetermine, .temporarilyUnavailable:
            return "arrow.clockwise.icloud.fill"
        @unknown default:
            return "icloud.fill"
        }
    }

    // MARK: - Sync Tracking

    func recordSync() {
        lastSyncDate = Date()
        UserDefaults.standard.set(lastSyncDate, forKey: "lastCloudKitSync")
    }

    func loadLastSyncDate() {
        lastSyncDate = UserDefaults.standard.object(forKey: "lastCloudKitSync") as? Date
    }

    var lastSyncDescription: String {
        guard let date = lastSyncDate else {
            return "Never synced"
        }

        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return "Last synced \(formatter.localizedString(for: date, relativeTo: Date()))"
    }
}

// MARK: - SwiftData CloudKit Configuration Helper

extension ModelConfiguration {
    /// Creates a ModelConfiguration with CloudKit sync enabled
    /// Note: Requires CloudKit capability and container to be configured in Xcode
    static func withCloudKit(
        schema: Schema,
        cloudKitContainerIdentifier: String
    ) -> ModelConfiguration {
        ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .private(cloudKitContainerIdentifier)
        )
    }
}

// MARK: - Sync-Aware App Configuration

/// Use this in LastIDidApp.swift to enable CloudKit sync
/// Replace the existing ModelConfiguration with this:
///
/// ```swift
/// let modelConfiguration: ModelConfiguration
/// if CloudKitManager.shared.isSignedIn {
///     modelConfiguration = .withCloudKit(
///         schema: schema,
///         cloudKitContainerIdentifier: "iCloud.com.yourname.lastidid"
///     )
/// } else {
///     modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
/// }
/// ```
