import axios, { AxiosError, AxiosResponse } from '@ohos/axios';
import { IAMTokenPreferencesDataUtil } from '../utils/IAMTokenPreferencesDataUtil';
import { AuthInfo } from '../IAMAuth/AuthInfo';
import { Auth } from '../IAMAuth/Auth';
import { Identity } from '../IAMAuth/Identity';
import { Password } from '../IAMAuth/Password';
import { User } from '../IAMAuth/User';
import { Domain } from '../IAMAuth/Domain';
import { Scope } from '../IAMAuth/Scope';
import { Project } from '../IAMAuth/Project';
import { hilog } from '@kit.PerformanceAnalysisKit';

// 定义响应数据的接口（根据实际返回结构补充）
interface IAMResponseData {
  // 华为IAM接口返回的响应体结构（可根据实际情况补充）
  // 示例：可能包含token有效期等信息
  expires_at?: number;
}


export class IAMService {
  // 1. 静态成员：用类名访问，避免this
  private static instance: IAMService; // 静态实例（单例）
  private static readonly IAM_USER = '  ';
  private static readonly IAM_PASSWORD = '  ';
  private static readonly IAM_DOMAIN = '   ';
  private static readonly PROJECT_REGION = '   ';
  private static readonly IAM_TOKEN_URL =  ''
  private static readonly TOKEN_EXPIRE_INTERVAL = 23 * 60 * 60 * 1000; // 23小时刷新

  private refreshTimer: number | null = null; // 实例成员（非静态）

  // 私有构造函数：防止外部new
  private constructor() {}

  /**
   * 2. 修正静态方法：用类名（IAMService）替代this访问静态成员
   */
  public static getInstance(): IAMService {
    if (!IAMService.instance) { // 关键修正：this → IAMService
      IAMService.instance = new IAMService();
    }
    return IAMService.instance; // 关键修正：this → IAMService
  }

  /**
   * 初始化：获取Token + 启动自动刷新
   */
  public init(): void {
    this.getIAMToken();
    this.startAutoRefresh();
  }

  /**
   * 获取IAM Token（内部调用，存储到首选项）
   */
  private getIAMToken(): void {
    const authInfo = this.buildAuthParams();

    const axiosInstance = axios.create({
      headers: {
        'Content-Type': 'application/json'
      }
    });

    // 显式声明response的类型，指定headers为Record<string, string>
    axiosInstance.post<IAMResponseData>(IAMService.IAM_TOKEN_URL, authInfo)
      .then((response: AxiosResponse<IAMResponseData>) => {
        // 明确headers的类型为Record<string, string>，避免any
        const headers: Record<string, string> = response.headers as Record<string, string>;
        const token: string | undefined = headers['x-subject-token'];

        if (token) {
          IAMTokenPreferencesDataUtil.init().setPreferencesData('token', token);
          hilog.info(0x0000, 'IAMService', 'Token获取成功');
        } else {
          hilog.error(0x0000, 'IAMService', '响应头缺少x-subject-token');
        }
      })
      .catch((error: AxiosError) => {
        const errorMsg = error.response?.data ? JSON.stringify(error.response.data) : error.message;
        hilog.error(0x0000, 'IAMService', `Token获取失败: ${errorMsg}`);
      });
  }

  /**
   * 构建IAM认证请求参数
   */
  private buildAuthParams(): AuthInfo {
    const authInfo = new AuthInfo();
    const auth = new Auth();
    const identity = new Identity();
    const password = new Password();
    const user = new User();
    const domain = new Domain();
    const scope = new Scope();
    const project = new Project();

    // 3. 静态常量：用类名访问（避免硬编码重复）
    identity.methods = ['password'];
    domain.name = IAMService.IAM_DOMAIN; // 类名访问静态域名
    user.name = IAMService.IAM_USER;     // 类名访问静态用户名
    user.password = IAMService.IAM_PASSWORD; // 类名访问静态密码
    user.domain = domain;
    password.user = user;
    identity.password = password;

    project.name = IAMService.PROJECT_REGION; // 类名访问静态区域
    scope.project = project;

    auth.identity = identity;
    auth.scope = scope;
    authInfo.auth = auth;

    return authInfo;
  }

  /**
   * 启动Token自动刷新
   */
  private startAutoRefresh(): void {
    if (this.refreshTimer) {
      clearInterval(this.refreshTimer);
    }
    // 类名访问静态刷新间隔
    this.refreshTimer = setInterval(() => {
      hilog.info(0x0000, 'IAMService', '自动刷新Token');
      this.getIAMToken();
    }, IAMService.TOKEN_EXPIRE_INTERVAL);
  }

  /**
   * 获取存储的Token
   */
  public getStoredToken(): string {
    return IAMTokenPreferencesDataUtil.init().getPreferencesData('token') || '';
  }

  /**
   * 销毁：清除定时任务
   */
  public destroy(): void {
    if (this.refreshTimer) {
      clearInterval(this.refreshTimer);
      this.refreshTimer = null;
    }
  }
}