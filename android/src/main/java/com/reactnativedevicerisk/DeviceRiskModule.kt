package com.reactnativedevicerisk

import android.os.Handler
import android.os.Looper
import androidx.appcompat.app.AppCompatActivity
import com.facebook.react.bridge.*
import com.socure.idplus.devicerisk.androidsdk.SDKAppDataPublic
import com.socure.idplus.devicerisk.androidsdk.model.UploadResult
import com.socure.idplus.devicerisk.androidsdk.sensors.DeviceRiskManager
import java.util.*

class DeviceRiskModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext), DeviceRiskManager.DataUploadCallback {
  private val manager = DeviceRiskManager(isReact = "true")
  private var trackersInitialized = false
  private var sendDataPromise: Promise? = null

  override fun getName(): String {
    return "RnDeviceRisk"
  }

  @ReactMethod
  fun toggleUserConsent(state: Boolean) {
    SDKAppDataPublic.userContent = state
  }

  @ReactMethod
  fun setTracker(socureKey: String, providers: ReadableArray, promise: Promise) {
    try {
      val trackers = mutableListOf<DeviceRiskManager.DeviceRiskDataSourcesEnum>()
      for (i in 0 until providers.size()) {
        providers.getString(i)?.let {
          trackers.add(DeviceRiskManager.DeviceRiskDataSourcesEnum.valueOf(it))
        }
      }
      initializeTrackers(socureKey, trackers)
      promise.resolve(Arguments.createMap())
    } catch (error: Exception) {
      println(error)
      promise.reject(error)
    }
  }

  private fun initializeTrackers(socureKey: String, trackers: MutableList<DeviceRiskManager.DeviceRiskDataSourcesEnum>) {
    trackersInitialized = true
    val userConsent = SDKAppDataPublic.userContent
    val handler = Handler(reactApplicationContext.mainLooper)
    handler.post {
      manager.setTracker(socureKey, BuildConfig.B_URL, trackers, userConsent, currentActivity as AppCompatActivity, this)
    }
  }

  @ReactMethod
  fun sendData(promise: Promise) {
    sendDataWithContext(null, promise)
  }

  @ReactMethod
  fun sendDataWithContext(context: String? = null, promise: Promise) {
    uploadTrackingData(promise)
  }

  private fun uploadTrackingData(promise: Promise) {
    if (!trackersInitialized) {
      promise.reject(Throwable("Trackers not initialized. Call setTracker first."))
      return
    }
    sendDataPromise = promise
    val handler = Handler(reactApplicationContext.mainLooper)
    handler.post {
      manager.sendData()
    }
  }

  override fun dataUploadFinished(uploadResult: UploadResult) {
    val response = Arguments.createMap()

    response.putString("deviceRiskSessionId", uploadResult.uuid ?: "")

    sendDataPromise?.resolve(response)
  }

  override fun onError(errorType: DeviceRiskManager.SocureSDKErrorType, errorMessage: String?) {
    sendDataPromise?.reject(Throwable(message = "${errorType.name}: $errorMessage"))
  }

  override fun getConstants(): MutableMap<String, Any> {
    val constants = mutableMapOf<String, Any>()
    DeviceRiskManager.DeviceRiskDataSourcesEnum.values().forEach {
      if (it.name.toLowerCase(Locale.US) != "bluetooth")
        constants[it.name] = it.name
    }

    return constants
  }

}
