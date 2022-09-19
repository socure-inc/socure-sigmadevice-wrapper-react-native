import DeviceRisk

@objc(RnDeviceRisk)
class RnDeviceRisk: NSObject, RCTBridgeModule, DeviceRiskUploadCallback {

    let deviceRiskManager = DeviceRiskManager.sharedInstance

    var initialized = false
    var userConsent = false
    var sendDataResolve: RCTPromiseResolveBlock?
    var sendDataReject: RCTPromiseRejectBlock?
    var deviceRiskSessionID:String? {
        if let uuid = UserDefaults.standard.string(forKey: "DeviceRiskUUID") {
            return uuid
        }

        return nil
    }

    @objc(toggleUserConsent:)
    func toggleUserConsent(newState: Bool) -> Void {
        userConsent = !userConsent
    }

    @objc(setTracker:withTrackers:withResolver:withRejecter:)
    func setTracker(key: NSString, trackers: NSArray, resolve: @escaping RCTPromiseResolveBlock,reject: @escaping RCTPromiseRejectBlock) -> Void {

        DispatchQueue.main.async { [weak self] in
            guard let weakSelf = self else {
                reject("INITIALIZATION_ERROR", "setTracker not properly initialized", nil)
                return
            }
            weakSelf.deviceRiskManager.delegate = self

            var providers: [DeviceRiskDataSources] = []
            for provider in trackers {
                if let providerString = provider as? String,
                   let providerFound = DeviceRiskDataSources.getDataSource(key: providerString) {
                    providers.append(providerFound)
                }
            }

            weakSelf.deviceRiskManager.setTracker(key: key as String, sources: providers, existingUUID: weakSelf.deviceRiskSessionID, userConsent: weakSelf.userConsent)
            weakSelf.initialized = true

            resolve([:])
        }
    }

    @objc(sendData:withRejecter:)
    func sendData(resolve:@escaping RCTPromiseResolveBlock, reject:@escaping RCTPromiseRejectBlock) -> Void {
        sendData(context: nil, resolve: resolve, reject: reject)
    }

    @objc(sendDataWithContext:resolve:withRejecter:)
    func sendData(context: String? = nil, resolve:@escaping RCTPromiseResolveBlock, reject:@escaping RCTPromiseRejectBlock) -> Void {
        if initialized {
            sendDataResolve = resolve
            sendDataReject = reject

            deviceRiskManager.sendData({ (success, result) in
                if let currentResult = result, success {
                    resolve([
                        "deviceRiskSessionId":currentResult.uuid
                    ])
                } else {
                    reject("SEND_DATA_ERROR", "Problem encountered in calculating device risk session id", nil)
                }
            }, true)
        } else {
            reject("SEND_DATA_ERROR", "You must call setTracker first", nil)
        }
    }

    @objc
    func constantsToExport() -> [AnyHashable : Any]! {
        var constants: [AnyHashable:Any] = [:]
        for value in DeviceRiskDataSources.allSources {
            constants[value.key] = value.key
      }
      return constants
    }

    func dataUploadFinished(uploadResult: DeviceRiskUploadResult) {

        if let uuid = uploadResult.uuid {
            UserDefaults.standard.setValue(uuid, forKey: "DeviceRiskUUID")
        }
        /*self.sendDataResolve?([
            "uuid":uploadResult.uuid
        ])*/ // We're ignoring this to ensure synchronicity.
    }

    func onError(errorType: DeviceRiskErrorType, errorMessage: String) {
        self.sendDataReject?("SEND_DATA_ERROR", errorMessage, nil)
    }

    static func requiresMainQueueSetup() -> Bool {
        return true
    }

    static func moduleName() -> String! {
        return "RnDeviceRisk"
    }
}
