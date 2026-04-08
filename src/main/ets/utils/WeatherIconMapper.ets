/**
 * 天气图标映射工具类
 * 根据天气中文名称返回对应的图标文件名
 */
export class WeatherIconMapper {
  // 天气与图标映射关系的内部存储结构
  private static weatherMap: Map<string, string> = new Map();

  // 初始化映射关系
  static {
    // 0: 晴
    WeatherIconMapper.addWeatherEntries(["晴"], "ic_clear");

    // 1: 少云、晴间多云、多云
    WeatherIconMapper.addWeatherEntries(["少云", "晴间多云", "多云"], "ic_partlyCloudy");

    // 2: 阴
    WeatherIconMapper.addWeatherEntries(["阴"], "ic_negative");

    // 3: 各种风
    WeatherIconMapper.addWeatherEntries([
      "有风", "平静", "微风", "和风", "清风",
      "强风/劲风", "疾风", "大风", "烈风"
    ], "ic_wind");

    // 4: 霾相关
    WeatherIconMapper.addWeatherEntries([
      "霾", "中度霾", "重度霾", "严重霾"
    ], "ic_haze");

    // 5: 雷阵雨相关
    WeatherIconMapper.addWeatherEntries([
      "强雷阵雨", "雷阵雨", "雷阵雨并伴有冰雹"
    ], "ic_thunderstorm");

    // 6: 小雨相关
    WeatherIconMapper.addWeatherEntries([
      "小雨", "毛毛雨", "细雨"
    ], "ic_lightRain");

    // 7: 阵雨、雨
    WeatherIconMapper.addWeatherEntries(["阵雨", "雨"], "ic_rain");

    // 8: 中雨相关
    WeatherIconMapper.addWeatherEntries(["中雨", "小雨-中雨"], "ic_moderateRain");

    // 9: 大雨暴雨相关
    WeatherIconMapper.addWeatherEntries([
      "大雨", "暴雨", "大暴雨", "特大暴雨", "强阵雨",
      "极端降雨", "中雨-大雨", "大雨-暴雨", "暴雨-大暴雨",
      "大暴雨-特大暴雨"
    ], "ic_rainstorm");

    // 10: 雨雪混合
    WeatherIconMapper.addWeatherEntries([
      "雨雪天气", "雨夹雪", "阵雨夹雪", "冻雨"
    ], "ic_rainSnow");

    // 11: 雪相关
    WeatherIconMapper.addWeatherEntries([
      "雪", "阵雪", "小雪", "中雪", "大雪", "暴雪",
      "小雪-中雪", "中雪-大雪", "大雪-暴雪"
    ], "ic_snow");

    // 12: 沙尘相关
    WeatherIconMapper.addWeatherEntries([
      "浮尘", "扬沙", "沙尘暴", "强沙尘暴"
    ], "ic_sandstorm");

    // 13: 风暴相关
    WeatherIconMapper.addWeatherEntries([
      "风暴", "狂爆风", "飓风", "热带风暴", "龙卷风"
    ], "ic_tornado");

    // 14: 雾相关
    WeatherIconMapper.addWeatherEntries([
      "雾", "浓雾", "强浓雾", "轻雾", "大雾", "特强浓雾"
    ], "ic_fog");

    // 15: 热
    WeatherIconMapper.addWeatherEntries(["热"], "ic_high");

    // 16: 冷
    WeatherIconMapper.addWeatherEntries(["冷"], "ic_low");
  }

  /**
   * 批量添加天气与图标映射
   * @param weathers 天气数组
   * @param iconName 图标文件名
   */
  private static addWeatherEntries(weathers: string[], iconName: string) {
    weathers.forEach(weather => {
      // 去除可能的空格并标准化
      const normalizedWeather = weather.trim();
      // 静态方法中使用类名访问静态属性，而非this
      WeatherIconMapper.weatherMap.set(normalizedWeather, iconName);
    });
  }

  /**
   * 根据天气中文名称获取图标文件名
   * @param weather 天气中文名称
   * @returns 图标文件名，未知天气返回ic_unow
   */
  static getWeatherIcon(weather: string): string {
    if (!weather) {
      return "ic_unow";
    }

    // 去除空格并查询
    const normalizedWeather = weather.trim();
    return WeatherIconMapper.weatherMap.get(normalizedWeather) || "ic_unow";
  }

  /**
   * 检查天气是否在映射表中
   * @param weather 天气中文名称
   * @returns 是否存在
   */
  static hasWeather(weather: string): boolean {
    return WeatherIconMapper.weatherMap.has(weather.trim());
  }

  /**
   * 获取所有天气类型
   * @returns 天气类型数组
   */
  static getAllWeathers(): string[] {
    return Array.from(WeatherIconMapper.weatherMap.keys());
  }
}
