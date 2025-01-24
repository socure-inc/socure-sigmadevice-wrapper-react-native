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

  private val handler = Handler(reactContext.mainLooper)

  override fun getName(): String {
    return RN_SIGMA_DEVICE
  }

  @ReactMethod
  fun initializeSDK(sdkKey: String, sigmaDeviceOptions: ReadableMap?, promise: Promise) {
    val activity = reactApplicationContext.currentActivity
    if (activity == null) {
      promise.reject(Throwable(message = "Aborting since app activity object is null"))
      return
    }

    var isFirstTime = true
    handler.post {
      SigmaDevice.initializeSDK(
        activity as AppCompatActivity,
        sdkKey,
        getSigmaDeviceOptions(sigmaDeviceOptions),
        object : SigmaDeviceCallback {
          override fun onError(errorType: SigmaDeviceError, errorMessage: String?) {
            if (!isFirstTime) {
              return
            }

            isFirstTime = false
            promise.reject(Throwable(message = "${errorType.name}: $errorMessage"))
          }

          override fun onSessionCreated(sessionToken: String) {
            if (!isFirstTime) {
              return
            }

            isFirstTime = false
            sendSessionToken(sessionToken, promise)
          }
        })
    }
  }

  @ReactMethod
  fun getSessionToken(promise: Promise) {
    handler.post {
      SigmaDevice.getSessionToken(object : SessionTokenCallback {
        override fun onComplete(sessionToken: String) {
          sendSessionToken(sessionToken, promise)
        }

        override fun onError(errorType: SigmaDeviceError, errorMessage: String?) {
          promise.reject(Throwable(message = "${errorType.name}: $errorMessage"))
        }

      })
    }
  }

  @ReactMethod
  fun pauseDataCollection() {
    handler.post {
      SigmaDevice.pauseDataCollection()
    }
  }

  @ReactMethod
  fun resumeDataCollection() {
    handler.post {
      SigmaDevice.resumeDataCollection()
    }
  }

  @ReactMethod
  fun addCustomerSessionId(
    customerSessionId: String,
    promise: Promise
  ) {
    handler.post {
      SigmaDevice.addCustomerSessionId(customerSessionId, object : SessionTokenCallback {
        override fun onComplete(sessionToken: String) {
          sendSessionToken(sessionToken, promise)
        }

        override fun onError(errorType: SigmaDeviceError, errorMessage: String?) {
          promise.reject(Throwable(message = "${errorType.name}: $errorMessage"))
        }
      })
    }
  }

  @ReactMethod
  fun createNewSession(
    customerSessionId: String,
    promise: Promise
  ) {
    handler.post {
      SigmaDevice.createNewSession(customerSessionId, object : SessionTokenCallback {
        override fun onComplete(sessionToken: String) {
          sendSessionToken(sessionToken, promise)
        }

        override fun onError(errorType: SigmaDeviceError, errorMessage: String?) {
          promise.reject(Throwable(message = "${errorType.name}: $errorMessage"))
        }
      })
    }
  }

  private fun sendSessionToken(sessionToken: String, promise: Promise) {
    val response = Arguments.createMap()
    response.putString("sessionToken", sessionToken)
    promise.resolve(response)
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
      val configBaseUrl =
        if (sigmaDeviceOptions.hasKey("configBaseUrl")) sigmaDeviceOptions.getString("configBaseUrl") else null
      apiOptions = SigmaDeviceOptions(omitLocationData, advertisingID, useSocureGov, configBaseUrl)
    }
    return apiOptions
  }

  @ReactMethod
  fun processDevice(sigmaDeviceContext: String, promise: Promise) {
    val context = getContextFromString(sigmaDeviceContext)

    handler.post {
      SigmaDevice.processDevice(context, object : SessionTokenCallback {
        override fun onComplete(sessionToken: String) {
          sendSessionToken(sessionToken, promise)
        }

        override fun onError(errorType: SigmaDeviceError, errorMessage: String?) {
          promise.reject(Throwable(message = "${errorType.name}: $errorMessage"))
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
