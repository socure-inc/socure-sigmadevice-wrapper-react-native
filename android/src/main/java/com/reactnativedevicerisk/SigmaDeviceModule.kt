package com.reactnativedevicerisk

import android.os.Handler
import android.os.Looper
import androidx.appcompat.app.AppCompatActivity
import com.facebook.react.bridge.*
import com.socure.idplus.devicerisk.androidsdk.SDKAppDataPublic
import com.socure.idplus.devicerisk.androidsdk.model.SocureFingerprintResult
import com.socure.idplus.devicerisk.androidsdk.sensors.SocureSigmaDevice
import com.socure.idplus.devicerisk.androidsdk.uilts.SocureFingerPrintContext
import com.socure.idplus.devicerisk.androidsdk.model.*
import java.util.*

class SigmaDeviceModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext), SocureSigmaDevice.DataUploadCallback {
  private var sendDataPromise: Promise? = null
  private val sigmaDevice = SocureSigmaDevice()

  override fun getName(): String {
    return "RnSigmaDevice"
  }

  @ReactMethod
  fun fingerprint(config: ReadableMap, options: ReadableMap, promise: Promise) {
    val SDKKey = config.getString("SDKKey") ?: run {
        sendDataPromise?.reject(Throwable(message = "Missing SDK Key in the config object"))
        return
    }

    val fingerprintEndpointHost = config.getString("fingerprintEndpointHost") ?: ""
    val enableBehaviorMetrics = if (config.hasKey("enableBehavioralBiometrics")) config.getBoolean("enableBehavioralBiometrics") else false
    val omitLocationData = if (options.hasKey("omitLocationData")) options.getBoolean("omitLocationData") else false
    val context = options.getString("context") ?: ""
    val advertisingID = options.getString("advertisingID")

    sendDataPromise = promise
    var activity = currentActivity
    if (activity == null) {
      promise.reject(Throwable(message = "Aborting since app activity object is null"))
      return
    }
    val apiConfig = SocureSigmaDeviceConfig(SDKKey, true,enableBehaviorMetrics,  fingerprintEndpointHost = fingerprintEndpointHost, flagEndpointHost = "", activity = activity as AppCompatActivity)
    val apiOptions = SocureFingerPrintOptions(omitLocationData, getContextFromString(context), advertisingID)
    val handler = Handler(reactApplicationContext.mainLooper)
    handler.post {
      sigmaDevice.fingerPrint(apiConfig, apiOptions, this)
    }
  }

  override fun dataUploadFinished(uploadResult: SocureFingerprintResult) {
    val response = Arguments.createMap()
    response.putString("deviceSessionId", uploadResult.deviceSessionID ?: "")
    sendDataPromise?.resolve(response)
  }

  override fun onError(errorType: SocureSigmaDevice.SocureSigmaDeviceError, errorMessage: String?) {
    sendDataPromise?.reject(Throwable(message = "${errorType.name}: $errorMessage"))
  }

  private fun getContextFromString(contextString: String): SocureFingerPrintContext {
    if (contextString == "homepage") {
      return SocureFingerPrintContext.Home()
    } else if (contextString == "signup") {
      return SocureFingerPrintContext.SignUp()
    } else if (contextString == "login") {
      return SocureFingerPrintContext.Login()
    } else if (contextString == "password") {
      return SocureFingerPrintContext.Password()
    } else if (contextString == "checkout") {
      return SocureFingerPrintContext.CheckOut()
    } else if (contextString == "profile") {
      return SocureFingerPrintContext.Profile()
    } else if (contextString == "transaction") {
      return SocureFingerPrintContext.Transaction()
    }

    return SocureFingerPrintContext.Other("unknown")
  }

}
