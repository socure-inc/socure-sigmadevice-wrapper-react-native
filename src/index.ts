import { NativeModules } from 'react-native';

const RnSigmaDeviceBase = NativeModules.RnSigmaDevice;

export enum SigmaDeviceContext {
  Default = 'Default',
  Home = 'Home',
  SignUp = 'SignUp',
  Login = 'Login',
  Password = 'Password',
  Checkout = 'Checkout',
  Profile = 'Profile',
  Transaction = 'Transaction',
}

export interface SessionTokenResponse {
  sessionToken: string;
}

export interface SigmaDeviceOptions {
  advertisingID?: string;
  omitLocationData?: boolean;
  useSocureGov?: boolean;
  configBaseUrl?: string;
  customerSessionId?: string;
}

export interface SigmaDeviceError {
  code: string;
  message: string;
}

export class RnSigmaDevice {
  public static async initializeSDK(
    sdkKey: string,
    config: SigmaDeviceOptions
  ): Promise<SessionTokenResponse> {
    return RnSigmaDeviceBase.initializeSDK(sdkKey, config);
  }

  public static async getSessionToken(): Promise<SessionTokenResponse> {
    return RnSigmaDeviceBase.getSessionToken();
  }

  public static async processDevice(
    sigmaDeviceContext: SigmaDeviceContext | string
  ): Promise<SessionTokenResponse> {
    return RnSigmaDeviceBase.processDevice(sigmaDeviceContext);
  }

  public static async pauseDataCollection(): Promise<void> {
    return RnSigmaDeviceBase.pauseDataCollection();
  }

  public static async resumeDataCollection(): Promise<void> {
    return RnSigmaDeviceBase.resumeDataCollection();
  }

  public static async addCustomerSessionId(
    customerSessionId: string
  ): Promise<void> {
    return RnSigmaDeviceBase.addCustomerSessionId(customerSessionId);
  }

  public static async createNewSession(
    customerSessionId?: string
  ): Promise<SessionTokenResponse> {
    return RnSigmaDeviceBase.createNewSession(customerSessionId);
  }

  public static async performSilentNetworkAuth(
    mobileNumber: string
  ): Promise<void> {
    return RnSigmaDeviceBase.performSilentNetworkAuth(mobileNumber);
  }
}
