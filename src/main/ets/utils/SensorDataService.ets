import { IAMService } from './IAMService';
import { Agriculture } from '../models/Agriculture';
import { DeviceShadowItem } from '../models/ShadowTypes';
import axios, { AxiosError, AxiosResponse } from '@ohos/axios';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { prompt } from '@kit.ArkUI';

/**
 * 传感器数据工具类：封装IAM初始化、数据请求、定时刷新逻辑
 */
export class SensorDataService {
  // 单例实例（确保全局唯一，避免重复创建定时任务）
  private static instance: SensorDataService;
  // 定时任务ID（用于后续销毁）
  private refreshTimer: number | null = null;
  // 传感器数据请求URL（可根据实际需求调整）
  private static readonly SENSOR_SHADOW_URL =
    'https://cae2e28098.st1.iotda-app.cn-north-4.myhuaweicloud.com:443/v5/iot/14943c82ff65450b96153861f251491e/devices/691eb9cabf22cc5a8c084b59_BearPi_1120/shadow'
  // 定时刷新间隔（3秒，与原逻辑一致）
  private static readonly REFRESH_INTERVAL = 5000;

  // 私有构造函数：禁止外部new
  private constructor() {}

  /**
   * 获取单例实例
   */
  public static getInstance(): SensorDataService {
    if (!SensorDataService.instance) {
      SensorDataService.instance = new SensorDataService();
    }
    return SensorDataService.instance;
  }

  /**
   * 初始化并启动传感器数据获取（核心方法）
   * @param agriculture 页面中的Agriculture对象（用于同步数据到UI）
   */
  public initAndStart(agriculture: Agriculture): void {
    // 1. 初始化IAMService（获取Token）
    IAMService.getInstance().init();

    // 2. 立即获取一次数据
    this.getSensorData(agriculture);

    // 3. 启动定时刷新（先清除已有任务，避免重复）
    this.stopRefresh();
    this.refreshTimer = setInterval(() => {
      this.getSensorData(agriculture);
    }, SensorDataService.REFRESH_INTERVAL);

    hilog.info(0x0000, 'SensorDataService', '传感器数据服务已初始化，开始定时刷新');
  }

  /**
   * 停止定时刷新（页面销毁时调用，避免内存泄漏）
   */
  public stopRefresh(): void {
    if (this.refreshTimer) {
      clearInterval(this.refreshTimer);
      this.refreshTimer = null;
      hilog.info(0x0000, 'SensorDataService', '传感器数据定时刷新已停止');
    }
  }

  /**
   * 核心：请求传感器数据并同步到Agriculture对象
   * @param agriculture 页面中的Agriculture对象
   */
  private getSensorData(agriculture: Agriculture): void {
    // 从IAMService获取最新Token
    const token = IAMService.getInstance().getStoredToken();
    console.log('【SensorDataService】获取到的Token: ', token ? 'Token存在（长度：' + token.length + '）' : 'Token为空');

    // Token为空时提示并终止请求
    if (!token) {
      console.error('【SensorDataService】Token为空，无法发起请求');
      prompt.showToast({ message: 'Token获取失败，无法更新传感器数据' });
      return;
    }

    // 创建axios实例并发起请求
    const axiosInstance = axios.create({
      headers: {
        "Content-Type": "application/json",
        "X-Auth-Token": token
      },
      validateStatus: (status) => {
        console.log('【SensorDataService】请求状态码: ', status);
        return true;
      }
    });

    axiosInstance.get(SensorDataService.SENSOR_SHADOW_URL)
      .then((response: AxiosResponse) => {
        console.log('【SensorDataService】传感器数据请求成功');
        const shadowArray: DeviceShadowItem[] = response.data.shadow as DeviceShadowItem[];
        const targetSensor = shadowArray.find(item => item.service_id === 'Agriculture');

        if (targetSensor?.reported?.properties) {
          const properties = targetSensor.reported.properties;

          // 1. 构建新的属性值（无需创建完整Agriculture对象）
          const newTemperature = properties.Temperature?.toString() || '--';
          const newHumidity = properties.Humidity?.toString() || '--';
          const newLuminance = properties.Luminance?.toString() || '--';
          const newLightStatus = properties.LightStatus || '--';
          const newMotorStatus = properties.MotorStatus || '--';

          // 2. 关键修改：手动逐个赋值（替代Object.assign，避免标准库限制）
          agriculture.Temperature = newTemperature;
          agriculture.Humidity = newHumidity;
          agriculture.Luminance = newLuminance;
          agriculture.LightStatus = newLightStatus;
          agriculture.MotorStatus = newMotorStatus;
          console.log('【SensorDataService】数据同步完成: ', JSON.stringify(agriculture));
        } else {
          hilog.warn(0x0000, 'SensorDataService', '未找到有效的Agriculture传感器数据');
        }
      })
      .catch((error: AxiosError) => {
        console.error('【SensorDataService】传感器数据请求失败: ');
        console.error('错误消息: ', error.message);
        if (error.response) {
          console.error('错误响应体: ', JSON.stringify(error.response.data));
        }
      });
  }

  public async fetchSensorData(): Promise<Agriculture> {
    // 创建默认数据对象（请求失败时返回）
    const defaultData = new Agriculture();
    defaultData.Temperature = '--';
    defaultData.Humidity = '--';
    defaultData.Luminance = '--';
    defaultData.LightStatus = '--';
    defaultData.MotorStatus = '--';

    // 1. 校验Token
    const token = IAMService.getInstance().getStoredToken();
    if (!token) {
      const errorMsg = 'Token为空，无法获取传感器数据';
      prompt.showToast({ message: errorMsg });
      console.error('【SensorDataService】', errorMsg);
      return defaultData; // 返回默认数据，避免Promise reject
    }

    try {
      // 2. 发起请求（与原有逻辑一致，但不依赖外部对象）
      const axiosInstance = axios.create({
        headers: {
          "Content-Type": "application/json",
          "X-Auth-Token": token
        },
        validateStatus: (status) => {
          console.log('【SensorDataService】请求状态码: ', status);
          return true;
        }
      });

      const response: AxiosResponse = await axiosInstance.get(SensorDataService.SENSOR_SHADOW_URL);
      console.log('【SensorDataService】fetchSensorData请求成功');

      // 3. 解析数据（与原有逻辑一致）
      const shadowArray: DeviceShadowItem[] = response.data.shadow as DeviceShadowItem[];
      const targetSensor = shadowArray.find(item => item.service_id === 'Agriculture');

      if (targetSensor?.reported?.properties) {
        const properties = targetSensor.reported.properties;
        // 4. 构建并返回Agriculture数据（不修改外部对象，直接返回）
        const sensorData = new Agriculture();
        sensorData.Temperature = properties.Temperature?.toString() || '--';
        sensorData.Humidity = properties.Humidity?.toString() || '--';
        sensorData.Luminance = properties.Luminance?.toString() || '--';
        sensorData.LightStatus = properties.LightStatus || '--';
        sensorData.MotorStatus = properties.MotorStatus || '--';

        console.log('【SensorDataService】解析到的传感器数据: ', JSON.stringify(sensorData));
        return sensorData; // 返回最新数据
      } else {
        hilog.warn(0x0000, 'SensorDataService', '未找到有效的Agriculture传感器数据');
        return defaultData;
      }

    } catch (error) {
      // 5. 捕获请求异常
      prompt.showToast({ message: `获取设备状态失败: ${error}` });
      return defaultData; // 返回默认数据，避免页面崩溃
    }
  }

}