import DeviceRisk

@objc(RnSigmaDevice)
class RnSigmaDevice: NSObject, RCTBridgeModule {
    
    @objc(initializeSDK:options:resolver:rejecter:)
    func initializeSDK(SDKKey: String?,
                       options: [String : Any]?,
                       resolver resolve: @escaping RCTPromiseResolveBlock,
                       rejecter reject: @escaping RCTPromiseRejectBlock) -> Void {
        guard let SDKKey = SDKKey else {
            reject("initializeSDK_error", "Missing SDK Key", nil)
            return
        }

        var sdkOptions: SigmaDeviceOptions?
        if let options = options {
            let omitLocationData = options["omitLocationData"] as? Bool
            let advertisingID = options["advertisingID"] as? String
            sdkOptions = SigmaDeviceOptions(omitLocationData: omitLocationData ?? false, advertisingID: advertisingID)
        }
        
        SigmaDevice.initializeSDK(SDKKey, options: sdkOptions) { sessionToken, error in
            if let error = error {
                let errorMsg: String
                switch error {
                case .dataFetchError:
                    errorMsg = "An error occurred while fetching the data"
                case .dataUploadError(let code, let msg):
                    errorMsg = "\(code ?? ""): \(msg ?? "")"
                case .networkConnectionError(let nsUrlError):
                    errorMsg = nsUrlError.localizedDescription
                case .unknownError:
                    errorMsg = "Unknown error occurred"
                default:
                    errorMsg = "Unknown error occurred"
                }
                reject("initialzeSDK_error", errorMsg, nil)
                return
            }
            
            guard let sessionToken = sessionToken else {
                reject("initialzeSDK_error", "Request failed to return a session token", nil)
                return
            }
            
            resolve([
                "sessionToken": sessionToken
            ])
        }
        NotificationCenter.default.post(Notification(name: Notification.Name("SOCURE_REACT_NATIVE_ENV")))
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
            if let error = error {
                let errorMsg: String
                switch error {
                case .dataFetchError:
                    errorMsg = "An error occurred while fetching the data"
                case .dataUploadError(let code, let msg):
                    errorMsg = "\(code ?? ""): \(msg ?? "")"
                case .networkConnectionError(let nsUrlError):
                    errorMsg = nsUrlError.localizedDescription
                case .unknownError:
                    errorMsg = "Unknown error occurred"
                default:
                    errorMsg = "Unknown error occurred"
                }
                reject("process_device", errorMsg, nil)
                return
            }
            
            guard let sessionToken = sessionToken else {
                reject("process_device", "Request failed to return a session token", nil)
                return
            }
            
            resolve([
                "sessionToken": sessionToken
            ])
        }
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
