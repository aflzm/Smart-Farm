import { http } from '@kit.NetworkKit';
import { BusinessError } from '@ohos.base';

// 高德地图API密钥
const API_KEY = "  ";//  密钥
// 默认城市编码（福州）
const DEFAULT_CITY_CODE = "350100";

// IP定位API地址
const IP_LOCATION_URL = `https://restapi.amap.com/v3/ip?key=${API_KEY}`;

// 天气API地址模板
const WEATHER_URL_TEMPLATE = `https://restapi.amap.com/v3/weather/weatherInfo?key=${API_KEY}&city=%s`;

/**
 * IP定位返回结果接口
 */
export interface LocationResult {
  status: string;
  info: string;
  infocode: string;
  province: string;
  city: string;
  adcode: string;
  rectangle: string;
}

export interface Live {
  province: string;
  city: string;
  adcode: string;
  weather: string;
  temperature: string;
  winddirection: string;
  windpower: string;
  humidity: string;
  reporttime: string;
}

/**
 * 天气信息接口
 */
export interface WeatherResult {
  status: string;
  count: string;
  info: string;
  infocode: string;
  lives?: Live[];
}

/**
 * 高德地图天气服务工具类
 */
export class AMapWeatherService {

  /**
   * 通过IP获取地区信息
   * @returns Promise<LocationResult> 地区信息
   */
  async getLocationByIp(): Promise<LocationResult> {
    return new Promise((resolve, reject) => {
      const request = http.createHttp();

      request.request(
        IP_LOCATION_URL,
        {
          method: http.RequestMethod.GET,
          connectTimeout: 60000,
          readTimeout: 60000,
        },
        (err: BusinessError, data: http.HttpResponse) => {
          try {
            if (err) {
              reject(new Error(`请求地区信息失败: ${err.message}`));
              return;
            }

            if (!data.result) {
              reject(new Error("获取地区信息返回空数据"));
              return;
            }

            const result = JSON.parse(data.result.toString()) as LocationResult;
            if (result.status !== "1") {
              reject(new Error(`获取地区信息失败: ${result.info}`));
              return;
            }

            resolve(result);
          } catch (parseError) {
            reject(new Error(`解析地区信息失败: ${parseError.message}`));
          } finally {
            // 确保请求资源被释放
            request.destroy();
          }
        }
      );
    });
  }

  /**
   * 根据城市编码获取天气信息
   * @param cityCode 城市编码，为空时使用默认值
   * @returns Promise<WeatherResult> 天气信息
   */
  async getWeatherByCityCode(cityCode?: string): Promise<WeatherResult> {
    // 处理城市编码，为空则使用默认值
    const actualCityCode = (cityCode?.trim() || DEFAULT_CITY_CODE);

    const weatherUrl = WEATHER_URL_TEMPLATE.replace("%s", actualCityCode);

    return new Promise((resolve, reject) => {
      const request = http.createHttp();

      request.request(
        weatherUrl,
        {
          method: http.RequestMethod.GET,
          connectTimeout: 60000,
          readTimeout: 60000,
        },
        (err: BusinessError, data: http.HttpResponse) => {
          try {
            if (err) {
              reject(new Error(`请求天气信息失败: ${err.message}`));
              return;
            }

            if (!data.result) {
              reject(new Error("获取天气信息返回空数据"));
              return;
            }

            const result = JSON.parse(data.result.toString()) as WeatherResult;
            if (result.status !== "1") {
              reject(new Error(`获取天气信息失败: ${result.info}`));
              return;
            }

            resolve(result);
          } catch (parseError) {
            reject(new Error(`解析天气信息失败: ${parseError.message}`));
          } finally {
            // 确保请求资源被释放
            request.destroy();
          }
        }
      );
    });
  }

  /**
   * 一站式获取当前地区天气
   * 先通过IP定位获取城市编码，获取失败时使用默认城市编码
   * @returns Promise<WeatherResult> 天气信息
   */
  async getCurrentLocationWeather(): Promise<WeatherResult> {
    try {
      // 尝试获取定位信息
      const location = await this.getLocationByIp();
      // 验证城市编码有效性
      const cityCode = (location.adcode?.trim() || "").length > 0
        ? location.adcode
        : DEFAULT_CITY_CODE;

      return await this.getWeatherByCityCode(cityCode);
    } catch (error) {
      console.warn(`定位获取失败，使用默认城市编码: ${(error as Error).message}`);
      // 定位失败时直接使用默认城市编码
      return this.getWeatherByCityCode(DEFAULT_CITY_CODE);
    }
  }
}