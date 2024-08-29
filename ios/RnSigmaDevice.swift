import DeviceRisk

@objc(RnSigmaDevice)
class RnSigmaDevice: NSObject, RCTBridgeModule {

    @objc(initializeSDK:options:resolver:rejecter:)
    func initializeSDK(SDKKey: String?,
                       options: [String : Any]?,
                       resolver resolve: @escaping RCTPromiseResolveBlock,
                       rejecter reject: @escaping RCTPromiseRejectBlock) -> Void {
        NotificationCenter.default.post(Notification(name: Notification.Name("SOCURE_APPLICATION_TYPE_NOTIFICATION"),
                                                     userInfo: ["SOCURE_APPLICATION_TYPE": "reactNative"]))

        guard let SDKKey = SDKKey else {
            reject("initializeSDK_error", "Missing SDK Key", nil)
            return
        }

        var sdkOptions: SigmaDeviceOptions?
        if let options = options {
            let omitLocationData = options["omitLocationData"] as? Bool
            let advertisingID = options["advertisingID"] as? String
            let useSocureGov = options["useSocureGov"] as? Bool
            let configBaseUrl = options["configBaseUrl"] as? String
            sdkOptions = SigmaDeviceOptions(omitLocationData: omitLocationData ?? false,
                                            advertisingID: advertisingID,
                                            useSocureGov: useSocureGov ?? false,
                                            configBaseUrl: configBaseUrl)
        }

        var isFirstTime = true

        SigmaDevice.initializeSDK(SDKKey, options: sdkOptions) { sessionToken, error in
            defer {
                isFirstTime = false
            }

            if isFirstTime {
                RnSigmaDevice.processResponse(methodName: "initializeSDK",
                                              sessionToken: sessionToken,
                                              error: error,
                                              resolver: resolve,
                                              rejecter: reject)
            }
        }
    }

    @objc(processDevice:resolver:rejecter:)
    func processDevice(context: String?,
                       resolver resolve: @escaping RCTPromiseResolveBlock,
                       rejecter reject: @escaping RCTPromiseRejectBlock) -> Void {

        var sigmaDeviceContext: SigmaDeviceContext = .other("Unknown")
        if let contextString = context?.lowercased() {
            sigmaDeviceContext = contextFromString(contextString)
        }

        SigmaDevice.processDevice(context: sigmaDeviceContext) { sessionToken, error in
            RnSigmaDevice.processResponse(methodName: "processDevice",
                                          sessionToken: sessionToken,
                                          error: error,
                                          resolver: resolve,
                                          rejecter: reject)
        }
    }

    @objc(getSessionToken:rejecter:)
    func getSessionToken(resolver resolve: @escaping RCTPromiseResolveBlock,
                         rejecter reject: @escaping RCTPromiseRejectBlock) -> Void {

        SigmaDevice.getSessionToken { sessionToken, error in
            RnSigmaDevice.processResponse(methodName: "getSessionToken",
                                          sessionToken: sessionToken,
                                          error: error,
                                          resolver: resolve,
                                          rejecter: reject)
        }
    }

    static func processResponse(methodName: String,
                         sessionToken: String?,
                         error: SigmaDeviceError?,
                         resolver resolve: @escaping RCTPromiseResolveBlock,
                         rejecter reject: @escaping RCTPromiseRejectBlock) {
        if let error = error {
            let errorMsg: String
            switch error {
            case .dataFetchError:
                errorMsg = "An error occurred while fetching the data"
            case .dataUploadError(let code, let msg):
                errorMsg = "\(code ?? ""): \(msg ?? "")"
            case .networkConnectionError(let networkConnectionError):
                let nsError = networkConnectionError as NSError
                errorMsg = "\(nsError.domain): \(nsError.code): \(nsError.localizedDescription)"
            case .unknownError:
                fallthrough
            default:
                errorMsg = "Unknown error occurred"
            }
            reject("\(methodName)_error", errorMsg, nil)
            return
        }

        guard let sessionToken = sessionToken else {
            reject("\(methodName)_error", "Request failed to return a session token", nil)
            return
        }

        resolve([
            "sessionToken": sessionToken
        ])
    }

    static func requiresMainQueueSetup() -> Bool {
        return true
    }

    static func moduleName() -> String! {
        return "RnSigmaDevice"
    }

    private func contextFromString(_ contextString: String) -> SigmaDeviceContext {
        if contextString == "default" {
            return .default
        } else if contextString == "homepage" {
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
