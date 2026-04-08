/**
 * 设备影子中desired/properties的接口（期望属性）
 */
export interface DesiredProperties {
  // 根据实际返回的期望属性字段扩展，例如：
  temperature?: number;  // 期望温度（可选）
  humidity?: number;     // 期望湿度（可选）
  blower?: boolean;      // 期望风机状态（可选）
  // 其他可能的期望属性...
}

/**
 * 设备影子中desired字段的接口
 */
export interface DesiredData {
  properties: DesiredProperties; // 期望属性（使用显式接口替代any）
  event_time: string | null;     // 期望属性的事件时间
}

/**
 * 设备影子中reported/properties的接口（实际上报属性）
 */
export interface ReportedProperties {
  Temperature?: string;  // 实际温度（可选）
  Humidity?: string;     // 实际湿度（可选）
  Luminance?: string;      // 实际风机状态（可选）
  LightStatus?: string;
  MotorStatus?: string;
  // 其他可能的上报属性...
}

/**
 * 设备影子中reported字段的接口
 */
export interface ReportedData {
  properties: ReportedProperties; // 实际上报属性
  event_time: string;             // 实际上报的事件时间（返回中该字段不为null）
}

/**
 * 设备影子数组中单个元素的完整接口
 */
export interface DeviceShadowItem {
  service_id: string;      // 服务ID（如"all_temperature_sensor"）
  desired: DesiredData;    // 期望数据（使用显式接口）
  reported: ReportedData;  // 实际上报数据
  version: number;         // 版本号
}