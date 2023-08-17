import DeviceRisk

@objc(RnSigmaDevice)
class RnSigmaDevice: NSObject, RCTBridgeModule {

    @objc(fingerprint:options:resolver:rejecter:)
    func fingerprint(config: [String : Any],
                     options: [String : Any]?,
                     resolver resolve: @escaping RCTPromiseResolveBlock,
                     rejecter reject: @escaping RCTPromiseRejectBlock) -> Void {
        guard let SDKKey = config["SDKKey"] as? String else {
            reject("fingerprint_error", "Missing SDK Key in the config object", nil)
            return
        }

        NotificationCenter.default.post(Notification(name: Notification.Name("SOCURE_REACT_NATIVE_ENV")))

        let fingerprintEndpointHost = config["fingerprintEndpointHost"] as? String
        let enableBehavioralBiometrics = config["enableBehavioralBiometrics"] as? Bool ?? false
        let apiConfig = SocureSigmaDeviceConfig(SDKKey: SDKKey,
                                                fingerprintEndpointHost: fingerprintEndpointHost,
                                                enableBehavioralBiometrics: enableBehavioralBiometrics)

        var apiOptions: SocureFingerprintOptions?
        if let options = options {
            let omitLocationData = options["omitLocationData"] as? Bool
            let advertisingID = options["advertisingID"] as? String
            var context: SocureFingerprintContext? = nil
            if let contextString = (options["context"] as? String)?.lowercased() {
                context = contextFromString(contextString)
            }

            apiOptions = SocureFingerprintOptions(omitLocationData: omitLocationData ?? false, advertisingID: advertisingID, context: context)
        }

        SocureSigmaDevice.fingerprint(config: apiConfig, options: apiOptions) { result, error in
            if let error = error {
                let errorMsg: String
                switch error {
                case .dataFetchError:
                    errorMsg = "An error occurred while fetching the data"
                case .dataUploadError(let code, let msg):
                    errorMsg = "\(code ?? 0): \(msg ?? "")"
                case .networkConnectionError(let nsUrlError):
                    errorMsg = nsUrlError.localizedDescription
                case .unknownError:
                    errorMsg = "Unknown error occurred"
                default:
                    errorMsg = "Unknown error occurred"
                }
                reject("fingerprint_error", errorMsg, nil)
                return
            }

            guard let result = result else {
                reject("fingerprint_error", "Request failed to return a device session id", nil)
                return
            }

            resolve([
                "deviceSessionId": result.deviceSessionID
            ])
        }
    }

    static func requiresMainQueueSetup() -> Bool {
        return true
    }

    static func moduleName() -> String! {
        return "RnSigmaDevice"
    }

    private func contextFromString(_ contextString: String) -> SocureFingerprintContext {
        if contextString == "homepage" {
            return .homepage
        } else if contextString == "signup" {
            return .signup
        } else if contextString == "login" {
            return .login
        } else if contextString == "profile" {
            return .profile
        } else if contextString == "password" {
            return .password
        } else if contextString == "transaction" {
            return .transaction
        } else if contextString == "checkout" {
            return .checkout
        }
        return .other(contextString)
    }
}
