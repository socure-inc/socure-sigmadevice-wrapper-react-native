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
            reject("initializeSDK_error", "SDKKey is required", nil)
            return
        }

        var sdkOptions: SigmaDeviceOptions?
        if let options = options {
            let omitLocationData = options["omitLocationData"] as? Bool
            let advertisingID = options["advertisingID"] as? String
            let useSocureGov = options["useSocureGov"] as? Bool
            let configBaseUrl = options["configBaseUrl"] as? String
            let customerSessionId = options["customerSessionId"] as? String
            sdkOptions = SigmaDeviceOptions(omitLocationData: omitLocationData ?? false,
                                            advertisingID: advertisingID,
                                            useSocureGov: useSocureGov ?? false,
                                            configBaseUrl: configBaseUrl,
                                            customerSessionId: customerSessionId)
        }

        SigmaDevice.initializeSDK(SDKKey, options: sdkOptions) { sessionToken, error in
            RnSigmaDevice.processResponse(methodName: "initializeSDK",
                                          sessionToken: sessionToken,
                                          error: error,
                                          resolver: resolve,
                                          rejecter: reject)
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

    @objc(pauseDataCollection:rejecter:)
    func pauseDataCollection(resolver resolve: @escaping RCTPromiseResolveBlock,
                             rejecter reject: @escaping RCTPromiseRejectBlock) -> Void {
        Task {
            do {
                try await SigmaDevice.pauseDataCollection()
                resolve(nil)
            } catch {
                let errorMsg = RnSigmaDevice.handleSigmaDeviceError(error as? SigmaDeviceError ?? .unknownError)
                reject("pauseDataCollection_error", errorMsg, nil)
            }
        }
    }

    @objc(resumeDataCollection:rejecter:)
    func resumeDataCollection(resolver resolve: @escaping RCTPromiseResolveBlock,
                              rejecter reject: @escaping RCTPromiseRejectBlock) -> Void {
        Task {
            do {
                try await SigmaDevice.resumeDataCollection()
                resolve(nil)
            } catch {
                let errorMsg = RnSigmaDevice.handleSigmaDeviceError(error as? SigmaDeviceError ?? .unknownError)
                reject("resumeDataCollection_error", errorMsg, nil)
            }
        }
    }

    @objc(addCustomerSessionId:resolver:rejecter:)
    func addCustomerSessionId(customerSessionId: String,
                              resolver resolve: @escaping RCTPromiseResolveBlock,
                              rejecter reject: @escaping RCTPromiseRejectBlock) -> Void {
        Task {
            do {
                try await SigmaDevice.addCustomerSessionId(customerSessionId)
                resolve(nil)
            } catch {
                let errorMsg = RnSigmaDevice.handleSigmaDeviceError(error as? SigmaDeviceError ?? .unknownError)
                reject("addCustomerSessionId_error", errorMsg, nil)
            }
        }
    }

    @objc(createNewSession:resolver:rejecter:)
    func createNewSession(customerSessionId: String?,
                          resolver resolve: @escaping RCTPromiseResolveBlock,
                          rejecter reject: @escaping RCTPromiseRejectBlock) -> Void {
        Task {
            do {
                let sessionToken = try await SigmaDevice.createNewSession(customerSessionId: customerSessionId)
                resolve(["sessionToken": sessionToken])
            } catch {
                let errorMsg = RnSigmaDevice.handleSigmaDeviceError(error as? SigmaDeviceError ?? .unknownError)
                reject("createNewSession_error", errorMsg, nil)
            }
        }
    }

    @objc(performSilentNetworkAuth:resolver:rejecter:)
    func performSilentNetworkAuth(mobileNumber: String,
                                  resolver resolve: @escaping RCTPromiseResolveBlock,
                                  rejecter reject: @escaping RCTPromiseRejectBlock) -> Void {
        Task {
            do {
                try await SigmaDevice.performSilentNetworkAuth(mobileNumber: mobileNumber)
                resolve(nil)
            } catch {
                if let sigmaDeviceError = error as? SigmaDeviceError {
                    let errorMsg = RnSigmaDevice.handleSigmaDeviceError(sigmaDeviceError)
                    reject("performSilentNetworkAuth_error", errorMsg, nil)
                } else if let silentNetworkAuthError = error as? SilentNetworkAuthError {
                    let errorMsg = RnSigmaDevice.handleSilentNetworkAuthError(silentNetworkAuthError)
                    reject("performSilentNetworkAuth_error", errorMsg, nil)
                } else {
                    reject("performSilentNetworkAuth_error", "An unknown error occurred during silent network authentication", nil)
                }
            }
        }
    }

    static func handleSigmaDeviceError(_ error: SigmaDeviceError) -> String {
        switch error {
        case .sdkNotInitializedError:
            return "SDK not initialized"
        case .sdkPausedError:
            return "SDK is currently paused"
        case .dataFetchError:
            return "An error occurred while fetching the data"
        case .dataUploadError(let code, let msg):
            return "\(code ?? ""): \(msg ?? "")"
        case .networkConnectionError(let networkConnectionError):
            let nsError = networkConnectionError as NSError
            return "\(nsError.domain): \(nsError.code): \(nsError.localizedDescription)"
        case .unknownError:
            fallthrough
        default:
            return "Unknown error occurred"
        }
    }

    static func handleSilentNetworkAuthError(_ error: SilentNetworkAuthError) -> String {
        switch error {
        case .invalidMobileNumberError:
            return "The provided mobile number is invalid."
        case .unauthorizedError:
            return "The account associated with the `SdkKey` is not authorized to perform silent network authentication."
        case .unknownError:
            fallthrough
        default:
            return "An unknown error occurred during the silent network authentication process."
        }
    }

    static func processResponse(methodName: String,
                                sessionToken: String?,
                                error: SigmaDeviceError?,
                                resolver resolve: @escaping RCTPromiseResolveBlock,
                                rejecter reject: @escaping RCTPromiseRejectBlock) {
        if let error = error {
            let errorMsg = RnSigmaDevice.handleSigmaDeviceError(error)
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
        switch contextString {
        case "default":
            return .default
        case "homepage":
            return .homepage
        case "signup":
            return .signup
        case "login":
            return .login
        case "profile":
            return .profile
        case "password":
            return .password
        case "transaction":
            return .transaction
        case "checkout":
            return .checkout
        default:
            return .other(contextString)
        }
    }
}
