import { IAMService } from '../utils/IAMService';
import { SensorDataService } from '../utils/SensorDataService';
import axios, { AxiosResponse } from '@ohos/axios';

interface ControllerItem {
  name: string;
  location: string;
  enabled: boolean;
  automation: boolean;
}

interface SensorMetricItem {
  title: string;
  value: string;
  valueColor: ResourceColor;
  icon: ResourceStr;
}

interface CameraItem {
  title: string;
  image: ResourceStr;
}

interface DeviceStatusItem {
  label: string;
  value: number;
  color: ResourceColor;
}

interface DeviceTypeItem {
  label: string;
  value: number;
  icon: ResourceStr;
}

interface MotorCommandParas {
  Motor: string;
}

interface MotorCommandPayload {
  service_id: string;
  command_name: string;
  paras: MotorCommandParas;
}

interface MotorCommandResponse {
  result?: string;
  message?: string;
  code?: string | number;
}

interface LightCommandParas {
  Light: string;
}

interface LightCommandPayload {
  service_id: string;
  command_name: string;
  paras: LightCommandParas;
}

interface LightCommandResponse {
  result?: string;
  message?: string;
  code?: string | number;
}

@Entry
@Component
export default struct Greenhouse {
  private iamService: IAMService = IAMService.getInstance();
  private sensorDataService: SensorDataService = SensorDataService.getInstance();
  private sensorRefreshTimer: number | null = null;
  private readonly MOTOR_COMMAND_URL: string =''    // url
  private readonly MOTOR_SERVICE_ID: string = 'Agriculture';
  private readonly MOTOR_COMMAND_NAME: string = 'Agriculture_Control_Motor';
  private readonly LIGHT_SERVICE_ID: string = 'Agriculture';
  private readonly LIGHT_COMMAND_NAME: string = 'Agriculture_Control_light';
  @State activeTab: string = 'sensor';


  //自我添加
  @State refreshTime: string = '12:49';

  @State shedOptions: string[] = ['玫瑰种植基地-1号大棚', '玫瑰种植基地-2号大棚', '玫瑰种植基地-3号大棚'
    , '玫瑰种植基地-4号大棚', '玫瑰种植基地-5号大棚'];
  @State sensorOptions: string[] = ['全部传感器', '室内传感器', '室外传感器'];
  @State selectedShed: string = '玫瑰种植基地-1号大棚';
  @State selectedSensor: string = '全部传感器';
  @State isShedDropdownOpen: boolean = false;
  @State isSensorDropdownOpen: boolean = false;


  @State controllers: ControllerItem[] = [
    { name: '电机', location: '玫瑰种植基地-1号大棚', enabled: false, automation: false },
    { name: '灯光', location: '玫瑰种植基地-2号大棚', enabled: false, automation: false },
    { name: '水阀', location: '玫瑰种植基地-3号大棚', enabled: false, automation: false },
    { name: '滴灌', location: '玫瑰种植基地-4号大棚', enabled: true, automation: false },
    { name: '农药', location: '玫瑰种植基地-5号大棚', enabled: false, automation: false },
    { name: '苍柯', location: '玫瑰种植基地-6号大棚', enabled: false, automation: false },
  ];
  @State sensorMetrics: SensorMetricItem[] = [
    { title: '室外温度', value: '21.3', valueColor: '#28a55a', icon: $r('app.media.p21') },
    { title: '室外湿度', value: '96.7%', valueColor: '#e67e22', icon: $r('app.media.p22') },
    { title: '风向', value: '正东', valueColor: '#28a55a', icon: $r('app.media.p23') },
    { title: '瞬时风速', value: '20m/s', valueColor: '#28a55a', icon: $r('app.media.p24') },
    { title: '瞬时雨量', value: '34', valueColor: '#28a55a', icon: $r('app.media.p25') },
    { title: '紫外线强度', value: '20m/s', valueColor: '#28a55a', icon: $r('app.media.p26') },
    { title: '光照强度', value: '0.539', valueColor: '#28a55a', icon: $r('app.media.p27') },
    { title: '气压', value: '-69', valueColor: '#28a55a', icon: $r('app.media.p28') },
    { title: 'PM2.5', value: '7.569', valueColor: '#28a55a', icon: $r('app.media.p9') },
    { title: 'PM10', value: '131', valueColor: '#28a55a', icon: $r('app.media.pm10') },
  ];
  @State cameraList: CameraItem[] = [
    { title: '1号大棚分门摄像头', image: $r('app.media.camerabg') },
    { title: '1号大棚种植区摄像头', image: $r('app.media.camerabg') },
  ];
  @State deviceTotal: number = 80;
  @State deviceStatusList: DeviceStatusItem[] = [
    { label: '在线·运行', value: 57, color: '#28a55a' },
    { label: '在线·故障', value: 3, color: '#ffd30019' },
    { label: '离线·正常', value: 12, color: '#e67e22' },
    { label: '离线·故障', value: 8, color: '#ff4b545f' }
  ];
  @State deviceTypeList: DeviceTypeItem[] = [
    { label: '传感器', value: 25, icon: $r('app.media.weather_icon') },
    { label: '控制器', value: 42, icon: $r('app.media.plant_management') },
    { label: '摄像头', value: 13, icon: $r('app.media.camera_icon') },
  ];

  aboutToAppear(): void {
    // 初始化IAM服务
    this.iamService.init();
    // 立即刷新传感器数据
    this.refreshSensorMetrics();
    // 启动定时刷新
    this.startSensorRefresh();
  }

  aboutToDisappear(): void {
    this.stopSensorRefresh();
  }

  startSensorRefresh(): void {
    this.stopSensorRefresh();
    // 与服务默认刷新间隔一致（5秒）
    this.sensorRefreshTimer = setInterval(() => {
      this.refreshSensorMetrics();
      this.updateRefreshTime();
    }, 5000) as number;
  }

  stopSensorRefresh(): void {
    if (this.sensorRefreshTimer !== null) {
      clearInterval(this.sensorRefreshTimer);
      this.sensorRefreshTimer = null;
    }
  }

  updateRefreshTime(): void {
    const now: Date = new Date();
    const hours: string = now.getHours().toString().padStart(2, '0');
    const minutes: string = now.getMinutes().toString().padStart(2, '0');
    this.refreshTime = `${hours}:${minutes}`;
  }


  async refreshSensorMetrics() {
    // 依赖 IAM Token 的真实接口获取
    const sensorData = await this.sensorDataService.fetchSensorData();

    // 仅更新温度、湿度、光照强度，其余保持原值
    const updated = this.sensorMetrics.map((item: SensorMetricItem) => {
      if (item.title === '室外温度') {
        return {
          title: item.title,
          value: `${sensorData.Temperature}`,
          valueColor: item.valueColor,
          icon: item.icon,
        };
      }
      if (item.title === '室外湿度') {
        return {
          title: item.title,
          value: `${sensorData.Humidity}%`,
          valueColor: item.valueColor,
          icon: item.icon,
        };
      }
      if (item.title === '光照强度') {
        return {
          title: item.title,
          value: `${sensorData.Luminance}`,
          valueColor: item.valueColor,
          icon: item.icon,
        };
      }
      return item;
    });

    this.sensorMetrics = updated;
  }
  @Builder
  buildTab(text: string, key: string) {
    Text(text)
      .fontSize(16)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.activeTab === key ? '#28a55a' : '#666666')
      .padding({ bottom: 6 })
      .border({
        width: 0,
        color: Color.Transparent,
      })
      .onClick(() => {
        this.activeTab = key;
      });
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        this.buildHeader()
        this.buildStatusCard()
        this.buildTabs()
        if (this.activeTab === 'sensor') {
          this.buildSensorGrid()
        } else if (this.activeTab === 'controller') {
          this.buildControllerGrid()
        } else {
          this.buildCameraList()
        }
      }
      .padding({ left: 16, right: 16, top: 12, bottom: 24 })
    }
    .backgroundColor('#e6f3eb')
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  buildHeader() {

    Row() {
      // 中间：智慧单元
      Text("智慧单元")
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
        .width('100%') // 让文字占满Row宽度，实现居中
    }
    .width('100%') // 撑满父容器宽度（和图一一致）
    .height(50)
    .backgroundColor('#FFFFFF') // 白色背景
    .alignItems(VerticalAlign.Center)
    .flexGrow(1) // 强制占满父容器宽度

    Column() {
      Row({ space: 8 }) {
        Text(this.selectedShed)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .flexGrow(1)
        Image($r('app.media.todown'))
          .width(16)
          .height(16)
          .rotate({ angle: this.isShedDropdownOpen ? 180 : 0 })
      }
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor('#FFFFFF')
      .borderRadius(8)
      .width('100%')
      .onClick(() => {
        this.isShedDropdownOpen = !this.isShedDropdownOpen;
      })

      if (this.isShedDropdownOpen) {
        Column() {
          ForEach(this.shedOptions, (item: string, index: number) => {
            Column() {
              Text(item)
                .fontSize(16)
                .padding({ left: 16, right: 16, top: 12, bottom: 12 })
                .width('100%')
                .backgroundColor('#FFFFFF')
                .onClick(() => {
                  this.selectedShed = item;
                  this.isShedDropdownOpen = false;
                })
              if (index < this.shedOptions.length - 1) {
                Divider()
                  .height(1)
                  .color('#F0F0F0')
                  .margin({ left: 16 })
              }
            }
          })
        }
        .width('100%')
        .borderRadius({ bottomLeft: 8, bottomRight: 8 })
        .shadow({ radius: 4, color: '#00000010' })
        .zIndex(10)
      }
    }
    .margin({ left: 16, right: 16 })
    .width('calc(100% - 32px)')
  }
  @Builder
  buildStatusCard() {
    Column({ space: 14 }) {

      Row() {
        Row({ space: 8 }) {
          Image($r('app.media.clock'))
            .width(16)
            .height(16)
          Text(`刷新时间:${this.refreshTime}`)
            .fontSize(12)
            .fontColor('#888888')
        }
        .justifyContent(FlexAlign.Start)

        Row({ space: 8 }) {
          Text("是否开启实时数据")
            .fontSize(14)
            .fontColor('#007DFF')
          Toggle({ type: ToggleType.Switch, isOn: true })
            .selectedColor('#007DFF')
            .onChange((isOn: boolean) => {
              if (isOn) {
                this.startSensorRefresh();
                this.refreshSensorMetrics();
              } else {
                this.stopSensorRefresh();
              }
            })
        }
        .justifyContent(FlexAlign.End)
      }
      .width('100%')
      .padding({ left: 1, right: 1, top: 1, bottom: 1})
      .backgroundColor('#FFFFFF')
      .borderRadius(8)
      .justifyContent(FlexAlign.SpaceBetween)


      Row({ space: 18 }) {
        Stack() {


          Circle()
            .width(80)
            .height(80)
            .strokeWidth(8)
            .stroke('#F0F0F0')
            .fill(Color.Transparent)

          // 在线-运行（绿色）- 57/80 = 71.25%
          Circle()
            .width(80)
            .height(80)
            .strokeWidth(8)
            .stroke('#00B42A')
            .fill(Color.Transparent)
            .strokeDashArray([180, 251.2])
            .strokeDashOffset(0)

          // 在线-故障（红色）- 3/80 = 3.75%
          Circle()
            .width(80)
            .height(80)
            .strokeWidth(8)
            .stroke('#FF5733')
            .fill(Color.Transparent)
            .strokeDashArray([9.42, 251.2])
            .strokeDashOffset(-180)

          // 离线-正常（黄色）- 12/80 = 15%
          Circle()
            .width(80)
            .height(80)
            .strokeWidth(8)
            .stroke('#FFC300')
            .fill(Color.Transparent)
            .strokeDashArray([37.68, 251.2])
            .strokeDashOffset(-189.42)

          // 离线-故障（灰色）- 8/80 = 10%
          Circle()
            .width(80)
            .height(80)
            .strokeWidth(8)
            .stroke('#999999')
            .fill(Color.Transparent)
            .strokeDashArray([25.12, 251.2])
            .strokeDashOffset(-227.1)

          Text(`${this.deviceTotal}`)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#28a55a')
            .margin({ bottom: 10 })
          Text('设备总数(台)')
            .fontSize(12)
            .fontColor('#666666')
            .margin({ top: 26 })
        }
        .width(96)
        .height(96)

        Column({ space: 12 }) {
          Row({ space: 16 }) {
            this.buildStatusItem(this.deviceStatusList[0])
            this.buildStatusItem(this.deviceStatusList[1])
          }
          Row({ space: 16 }) {
            this.buildStatusItem(this.deviceStatusList[2])
            this.buildStatusItem(this.deviceStatusList[3])
          }
        }
        .layoutWeight(1)
      }
      .width('100%')

      Row({ space: 12 }) {
        ForEach(this.deviceTypeList, (item: DeviceTypeItem, index: number) => {
          Column({ space: 8 }) {
            Text(`${item.value}`)
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
            Row({ space: 6 }) {
              Image(item.icon)
                .width(20)
                .height(20)
              Text(item.label)
                .fontSize(14)
                .fontColor('#999999')
            }
          }
          .layoutWeight(1)
          .padding(12)
          .backgroundColor('#f6faf7')
          .borderRadius(10)
        })
      }
    }
    .width('100%')
    .padding({ top: 14, bottom: 14, left: 16, right: 16 })
    .backgroundColor(Color.White)
    .borderRadius(12)
    .clip(true)
    .shadow({
      radius: 8,
      color: '#14141414',
      offsetX: 0,
      offsetY: 2
    })
  }

  @Builder
  buildStatusPoint(color: ResourceColor, text: string) {
    Row({ space: 6 }) {
      Circle({ width: 10, height: 10 }).fill(color)
      Text(text).fontSize(12).fontColor('#666666')
    }
  }

  @Builder
  buildStatusItem(item: DeviceStatusItem) {
    Row({ space: 8 }) {
      Text(`${item.value}`)
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
      Circle({ width: 10, height: 10 }).fill(item.color)
      Text(item.label)
        .fontSize(12)
        .fontColor('#666666')
    }
  }

  @Builder
  buildTabs() {
    Row() {
      this.buildTab('传感器', 'sensor')
      Blank()
      this.buildTab('控制器', 'controller')
      Blank()
      this.buildTab('摄像头', 'camera')
    }
    .padding({ top: 10, bottom: 10, left: 16, right: 16 })
    .backgroundColor(Color.White)
    .borderRadius(12)
    .clip(true)
    .width('100%')
    .margin({ top: 4 })

    // 只有选择"传感器"标签时才显示"全部传感器"下拉选项
    if (this.activeTab === 'sensor') {
      Column() {
        Row({ space: 8 }) {
          Text(this.selectedSensor)
            .fontSize(13)
            .fontWeight(FontWeight.Normal)
            .flexGrow(1)
          Image($r('app.media.todown'))
            .width(16)
            .height(16)
            .rotate({ angle: this.isSensorDropdownOpen ? 180 : 0 })
        }
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .width('100%')
        .onClick(() => {
          this.isSensorDropdownOpen = !this.isSensorDropdownOpen;
        })

        if (this.isSensorDropdownOpen) {
          Column() {
            ForEach(this.sensorOptions, (item: string, index: number) => {
              Column() {
                Text(item)
                  .fontSize(16)
                  .padding({ left: 16, right: 16, top: 12, bottom: 12 })
                  .width('100%')
                  .backgroundColor('#FFFFFF')
                  .onClick(() => {
                    this.selectedSensor = item;
                    this.isSensorDropdownOpen = false;
                  })
                if (index < this.sensorOptions.length - 1) {
                  Divider()
                    .height(1)
                    .color('#F0F0F0')
                    .margin({ left: 16 })
                }
              }
            })
          }
          .width('100%')
          .borderRadius({ bottomLeft: 8, bottomRight: 8 })
          .shadow({ radius: 4, color: '#00000010' })
          .zIndex(10)
        }
      }
      .margin({ left: 16, right: 16 })
      .width('calc(100% - 32px)')
    }
  }

  @Builder
  buildSensorGrid() {
    Grid() {
      ForEach(this.sensorMetrics, (item: SensorMetricItem, index: number) => {
        GridItem() {
          Column({ space: 10 }) {
            Text(item.title)
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
            // 修改点1：Row改为两端对齐，去掉Blank()
            Row({ space: 6 }) {
              Text(item.value)
                .fontSize(18) // 修改点2：放大数值字体，更醒目
                .fontWeight(FontWeight.Bold) // 修改点3：数值加粗
                .fontColor(item.valueColor)
              Image(item.icon)
                .width(32)   // 修改点4：放大图标尺寸
                .height(32)
            }
            // 修改点5：添加箭头，还原图一样式

          }
          // 修改点6：背景色改为白色，内边距加大，强制撑满宽度
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .width('100%')
          //.height('100%')
        }
      })
    }
    .columnsTemplate('1fr 1fr')
    .rowsGap(12)
    .columnsGap(12)
    .width('100%')
  }


  @Builder
  buildControllerGrid() {
    Grid() {
      ForEach(this.controllers, (item: ControllerItem, index: number) => {
        GridItem() {
          Column({ space: 12 }) {
            Row() {
              Text(item.name)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
              Blank()
              Toggle({ type: ToggleType.Switch, isOn: item.enabled })
                .selectedColor('#28a55a')
                .onChange((checked: boolean) => {
                  this.controllers[index].enabled = checked;
                  if (item.name === '电机') {
                    this.sendMotorCommand(checked);
                  } else if (item.name === '灯光') {
                    this.sendLightCommand(checked);
                  }
                })
            }
            Text(item.location)
              .fontSize(12)
              .fontColor('#999999')
            Button('设置自动化')
              .type(ButtonType.Normal)
              .backgroundColor('#28a55a')
              .fontColor(Color.White)
              .height(36)
              .borderRadius(8)
              .fontSize(14)
              .onClick(() => {
                this.controllers[index].automation = true;
                console.log(`${item.name} 自动化设置`);
              })
          }
          .padding(12)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .shadow({
            radius: 6,
            color: '#12121212',
            offsetX: 0,
            offsetY: 2
          })
        }
      })
    }
    .columnsTemplate('1fr 1fr')
    .rowsGap(12)
    .columnsGap(12)
    .width('100%')
  }

  async sendMotorCommand(turnOn: boolean) {
    const token: string = this.iamService.getStoredToken();
    if (!token) {
      console.error('电机控制失败: 未获取到 IAM Token');
      return;
    }
    const payload: MotorCommandPayload = {
      service_id: this.MOTOR_SERVICE_ID,
      command_name: this.MOTOR_COMMAND_NAME,
      paras: {
        Motor: turnOn ? 'ON' : 'OFF',
      },
    };
    try {
      const axiosInstance = axios.create({
        headers: {
          'Content-Type': 'application/json',
          'X-Auth-Token': token,
        },
        validateStatus: () => true,
      });
      const resp: AxiosResponse<MotorCommandResponse> = await axiosInstance.post<MotorCommandResponse>(this.MOTOR_COMMAND_URL, payload);
      console.log(`电机控制下发(${turnOn ? 'ON' : 'OFF'})状态码: ${resp.status}`);
    } catch (err) {
      console.error(`电机控制下发失败: ${(err as Error).message}`);
    }
  }

  async sendLightCommand(turnOn: boolean) {
    const token: string = this.iamService.getStoredToken();
    if (!token) {
      console.error('灯光控制失败: 未获取到 IAM Token');
      return;
    }
    const payload: LightCommandPayload = {
      service_id: this.LIGHT_SERVICE_ID,
      command_name: this.LIGHT_COMMAND_NAME,
      paras: {
        Light: turnOn ? 'ON' : 'OFF',
      },
    };
    try {
      const axiosInstance = axios.create({
        headers: {
          'Content-Type': 'application/json',
          'X-Auth-Token': token,
        },
        validateStatus: () => true,
      });
      const resp: AxiosResponse<LightCommandResponse> = await axiosInstance.post<LightCommandResponse>(this.MOTOR_COMMAND_URL, payload);
      console.log(`灯光控制下发(${turnOn ? 'ON' : 'OFF'})状态码: ${resp.status}`);
    } catch (err) {
      console.error(`灯光控制下发失败: ${(err as Error).message}`);
    }
  }

  @Builder
  buildCameraList() {
    Column({ space: 12 }) {
      ForEach(this.cameraList, (item: CameraItem, index: number) => {
        Column({ space: 10 }) {
          Image(item.image)
            .width('100%')
            .height(170)
            .borderRadius(12)
            .objectFit(ImageFit.Cover)
          Text(item.title)
            .fontSize(14)
            .fontColor('#666666')
        }
        .padding(12)
        .backgroundColor(Color.White)
        .borderRadius(12)
        .shadow({
          radius: 6,
          color: '#12121212',
          offsetX: 0,
          offsetY: 2
        })
      })
    }
    .width('100%')
  }
}