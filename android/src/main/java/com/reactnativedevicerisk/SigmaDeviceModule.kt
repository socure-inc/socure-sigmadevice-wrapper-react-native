package com.reactnativedevicerisk

import android.os.Handler
import androidx.appcompat.app.AppCompatActivity
import com.facebook.react.bridge.*
import com.reactnativedevicerisk.util.Constants.CHECKOUT
import com.reactnativedevicerisk.util.Constants.DEFAULT
import com.reactnativedevicerisk.util.Constants.HOMEPAGE
import com.reactnativedevicerisk.util.Constants.LOGIN
import com.reactnativedevicerisk.util.Constants.PASSWORD
import com.reactnativedevicerisk.util.Constants.PROFILE
import com.reactnativedevicerisk.util.Constants.SIGNUP
import com.reactnativedevicerisk.util.Constants.TRANSACTION
import com.reactnativedevicerisk.util.Constants.UNKNOWN
import com.socure.idplus.device.SigmaDevice
import com.socure.idplus.device.SigmaDeviceOptions
import com.socure.idplus.device.callback.SessionTokenCallback
import com.socure.idplus.device.callback.SigmaDeviceCallback
import com.socure.idplus.device.context.SigmaDeviceContext
import com.socure.idplus.device.error.SigmaDeviceError

class SigmaDeviceModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {
  private var sendDataPromise: Promise? = null

  private val handler = Handler(reactContext.mainLooper)

  override fun getName(): String {
    return RN_SIGMA_DEVICE
  }

  @ReactMethod
  fun initializeSDK(sdkKey: String, sigmaDeviceOptions: ReadableMap?, promise: Promise) {
    val activity = currentActivity
    sendDataPromise = promise
    if (activity == null) {
      sendDataPromise?.reject(Throwable(message = "Aborting since app activity object is null"))
      return
    }
    handler.post {
      SigmaDevice.initializeSDK(
        activity as AppCompatActivity,
        sdkKey,
        getSigmaDeviceOptions(sigmaDeviceOptions),
        object : SigmaDeviceCallback {
          override fun onError(errorType: SigmaDeviceError, errorMessage: String?) {
            sendDataPromise?.reject(Throwable(message = "${errorType.name}: $errorMessage"))
          }

          override fun onSessionCreated(sessionToken: String) {
            sendSessionToken(sessionToken)
          }
        })
    }
  }

  @ReactMethod
  fun getSessionToken(promise: Promise) {
    sendDataPromise = promise
    handler.post {
      SigmaDevice.getSessionToken(object : SessionTokenCallback {
        override fun onComplete(sessionToken: String) {
          sendSessionToken(sessionToken)
        }

        override fun onError(errorType: SigmaDeviceError, errorMessage: String?) {
          sendDataPromise?.reject(Throwable(message = "${errorType.name}: $errorMessage"))
        }

      })
    }
  }

  private fun sendSessionToken(sessionToken: String) {
    val response = Arguments.createMap()
    response.putString("sessionToken", sessionToken)
    sendDataPromise?.resolve(response)
  }

  private fun getSigmaDeviceOptions(sigmaDeviceOptions: ReadableMap?): SigmaDeviceOptions {
    var apiOptions = SigmaDeviceOptions()
    if (sigmaDeviceOptions != null) {
      val omitLocationData =
        if (sigmaDeviceOptions.hasKey("omitLocationData")) sigmaDeviceOptions.getBoolean("omitLocationData") else false
      val advertisingID =
        if (sigmaDeviceOptions.hasKey("advertisingID")) sigmaDeviceOptions.getString("advertisingID") else null
      val useSocureGov =
        if (sigmaDeviceOptions.hasKey("useSocureGov")) sigmaDeviceOptions.getBoolean("useSocureGov") else false
      apiOptions = SigmaDeviceOptions(omitLocationData, advertisingID, useSocureGov)
    }
    return apiOptions
  }

  @ReactMethod
  fun processDevice(sigmaDeviceContext: String, promise: Promise) {
    val context = getContextFromString(sigmaDeviceContext)

    sendDataPromise = promise
    handler.post {
      SigmaDevice.processDevice(context, object : SessionTokenCallback {
        override fun onComplete(sessionToken: String) {
          sendSessionToken(sessionToken)
        }

        override fun onError(errorType: SigmaDeviceError, errorMessage: String?) {
          sendDataPromise?.reject(Throwable(message = "${errorType.name}: $errorMessage"))
        }

      })
    }
  }

  private fun getContextFromString(contextString: String) =
    when (contextString) {
      DEFAULT -> SigmaDeviceContext.Default()
      HOMEPAGE -> SigmaDeviceContext.Home()
      SIGNUP -> SigmaDeviceContext.SignUp()
      LOGIN -> SigmaDeviceContext.Login()
      PASSWORD -> SigmaDeviceContext.Password()
      CHECKOUT -> SigmaDeviceContext.CheckOut()
      PROFILE -> SigmaDeviceContext.Profile()
      TRANSACTION -> SigmaDeviceContext.Transaction()
      else -> SigmaDeviceContext.Other(UNKNOWN)
    }

  companion object {
    private const val RN_SIGMA_DEVICE = "RnSigmaDevice"
  }
}
