import { AMapWeatherService } from '../utils/AMapWeatherService';

// 接口定义
interface WeatherInfo {
  temperature: string;
  windLevel: string;
  wind:string;
  humidity: string;
  weather:string;
}

interface FeatureItem {
  icon: ResourceStr;
  title: string;
  onClick: () => void;
}

interface CameraItem {
  title: string;
  thumbnail: ResourceStr;
  onClick: () => void;
}

interface DeviceStatusItem {
  label: string;
  value: number;
  color: ResourceColor;
  desc: string;
}

interface DeviceTypeItem {
  label: string;
  value: number;
  icon: ResourceStr;
}

//@Entry
@Component
export default  struct Home {
  @State userName: string = '你好,master';
  @State currentDate: string = '2025年10月23日 星期四';
  @State location: string = '未知';
  @State weatherInfo: WeatherInfo = {
    temperature: '--',
    windLevel: '--',
    wind:'  ',
    humidity: '--',
    weather:'  '
  };

  private  weatherService:AMapWeatherService = new AMapWeatherService();

  aboutToAppear(): void {
    this.weatherService.getCurrentLocationWeather().then(res=>{
      console.log("res:"+JSON.stringify(res))
      if(res&&Array.isArray(res.lives)&&res.lives.length>0) {
        this.currentDate = res.lives[0].reporttime;

        this.weatherInfo.temperature = res.lives[0].temperature;
        this.weatherInfo.windLevel = res.lives[0].windpower;
        this.weatherInfo.wind = res.lives[0].winddirection;
        this.weatherInfo.humidity = res.lives[0].humidity;
        this.weatherInfo.weather = res.lives[0].weather;

        this.location = res.lives[0].city
      }
    })
  }

  // 功能按钮数据
  @State featureItems: FeatureItem[] = [
    {
      icon: $r('app.media.cutedapeng'),
      title: '智慧大棚',
      onClick: () => {
        console.log('点击智慧大棚');
      }
    },
    {
      icon: $r('app.media.warehouse'),
      title: '智慧仓库',
      onClick: () => {
        console.log('点击智慧仓库');
      }
    },
    {
      icon: $r('app.media.producttrace'),
      title: '产品溯源',
      onClick: () => {
        console.log('点击产品溯源');
      }
    },
    {
      icon: $r('app.media.plantmanager'),
      title: '种植管理',
      onClick: () => {
        console.log('点击种植管理');
      }
    }
  ];

  // 摄像头数据
  @State cameraItems: CameraItem[] = [
    {
      title: '视频1',
      thumbnail: $r('app.media.camera2'),
      onClick: () => {
        console.log('点击视频1');
      }
    },
    {
      title: '视频2',
      thumbnail: $r('app.media.camera2'),
      onClick: () => {
        console.log('点击视频2');
      }
    },
    {
      title: '视频3',
      thumbnail: $r('app.media.camerabg'),
      onClick: () => {
        console.log('点击视频3');
      }
    },
    {
      title: '视频4',
      thumbnail: $r('app.media.camerabg'),
      onClick: () => {
        console.log('点击视频4');
      }
    }
  ];
  @State deviceTotal: number = 80;
  @State deviceStatusList: DeviceStatusItem[] = [
    { label: '在线·运行', value: 57, color: '#28a55a', desc: '' },
    { label: '在线·故障', value: 3, color: '#ffd3002a', desc: '' },
    { label: '离线·正常', value: 12, color: '#e67e22', desc: '' },
    { label: '离线·故障', value: 8, color: '#4e5b6b', desc: '' }
  ];
  @State deviceTypeList: DeviceTypeItem[] = [
    { label: '传感器', value: 25, icon: $r('app.media.weather_icon') },
    { label: '控制器', value: 42, icon: $r('app.media.plant_management') },
    { label: '摄像头', value: 13, icon: $r('app.media.camera_icon') },
  ];

  build() {
      Scroll() {
        Column({ space: 16 }) {
          // 头部用户信息区域
          this.buildHeaderSection()
          
          // 天气信息区域
          this.buildWeatherSection()
          
          // 功能按钮区域
          this.buildFeatureSection()
          
          // 摄像头监控区域
          this.buildCameraSection()

          // 设备状态区域
          this.buildDeviceStatusSection()
        }
        .padding({ left: 16, right: 16, bottom: 20, top: 12 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#e0f4e6')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  // 构建头部区域
  @Builder
  buildHeaderSection() {
    Row() {
      // 用户头像
      Image($r('app.media.my_image'))
        .width(50)
        .height(50)
        .borderRadius(25)
        .backgroundColor('#E8F5E8')
      
      Column() {
        Text(`${this.userName}, 欢迎来到智慧农场`)
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2E7D32')
          .margin({ bottom: 4 })
        
        Text(this.currentDate)
          .fontSize(14)
          .fontColor('#666666')
      }
      .margin({ left: 12 })
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      
      // 位置信息
      Row() {
        Image($r('app.media.location'))
          .width(25)
          .height(25)
          .fillColor('#2E7D32')
        
        Text(this.location)
          .fontSize(20)
          .fontColor('#666666')
          .margin({ left: 1 })
      }
    }
    .width('100%')
    .margin({ bottom: 20 })
  }

  // 构建天气区域
  @Builder
  buildWeatherSection() {
    Row() {
      Text('实时\n天气')
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .fontColor('#2E7D32')
      
      Image($r('app.media.weatherwenhao'))
        .width(20)
        .height(20)
        .fillColor('#999999')
        .margin({ left: 4 })
      
      Text(`${this.weatherInfo.weather}}`)
        .fontSize(12)
        .fontColor('#999999')
        .margin({ left: 4 })
      Text('|')
        .fontSize(12)
        .fontColor('#999999')
        .margin({ left: 4 })
      
      Text(`气温${this.weatherInfo.temperature}℃`)
        .fontSize(12)
        .fontColor('#666666')
        .margin({ left: 4 })

      Text('|')
        .fontSize(12)
        .fontColor('#999999')
        .margin({ left: 8 })
      
      Text(`${this.weatherInfo.wind}风${this.weatherInfo.windLevel}级`)
        .fontSize(12)
        .fontColor('#666666')
        .margin({ left: 16 })

      Text('|')
        .fontSize(12)
        .fontColor('#999999')
        .margin({ left: 8 })
      
      Text(`湿度${this.weatherInfo.humidity}%`)
        .fontSize(12)
        .fontColor('#666666')
        .margin({ left: 16 })
    }
    .width('100%')
    .height(60)
    .padding({ top: 12, bottom: 12, left: 16,right:10 })
    .backgroundColor('#F8F9FA')
    .borderRadius(8)
    .margin({ bottom: 20 })
  }

  @Builder
  buildDeviceStatusSection() {
    Column({ space: 14 }) {
      Row() {
        Text('设备状态')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.Black)
        Blank()
        Text('更多设备')
          .fontSize(14)
          .fontColor('#1976D2')
      }
      .width('100%')

      Row({ space: 18 }) {
        // 环形总数
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

        // 状态列表
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

      // 分类卡片
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
      radius: 6,
      color: '#14141414',
      offsetX: 0,
      offsetY: 2
    })
    .margin({ bottom: 16 })
  }

  @Builder
  buildStatusItem(item: DeviceStatusItem) {
    Row({ space: 8 }) {
      Text(`${item.value}`)
        .fontSize(10)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
      Circle({ width: 10, height: 10 }).fill(item.color)
      Text(item.label)
        .fontSize(10)
        .fontColor('#666666')
    }
  }

  // 构建功能按钮区域
  @Builder
  buildFeatureSection() {
    Row() {
      ForEach(this.featureItems, (item: FeatureItem, index: number) => {
        Column() {
          Image(item.icon)
            .width(40)
            .height(40)
            .fillColor('#2E7D32')
            .margin({ bottom: 8 })
          
          Text(item.title)
            .fontSize(14)
            .fontColor('#333333')
        }
        .layoutWeight(1)
        .height(80)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#F8F9FA')
        .borderRadius(8)
        .border({
          width: 1,
          color: '#E0E0E0',
          style: BorderStyle.Solid
        })
        .margin({ left: 4, right: 4 })
        .onClick(item.onClick)
      })
    }
    .width('100%')
    .margin({ bottom: 20 })
  }

  // 构建摄像头区域
  @Builder
  buildCameraSection() {
    Column() {
      // 标题行
      Row() {
        Text('通用摄像头')
          .fontSize(20)
          .fontWeight(FontWeight.Bolder)
          .fontColor('#333333')
        
        Blank()
        
        Text('查看更多')
          .fontSize(14)
          .fontColor('#1976D2')
          .onClick(() => {
            console.log('查看更多摄像头');
          })
      }
      .width('100%')
      .margin({ bottom: 12 })
      
      // 摄像头内容区域（带边框）
      Column() {
        // 主摄像头视图
        Image($r('app.media.camerabg'))
          .width('100%')
          .height(200)
          .backgroundColor('#E8F5E8')
          .borderRadius(8)
          .margin({ bottom: 12 })
        
        // 小摄像头网格
        Scroll() {
          Row() {
            ForEach(this.cameraItems, (item: CameraItem, index: number) => {
              Column() {
                Stack() {
                  Image(item.thumbnail)
                    .width('100%')
                    .height('100%')
                    .backgroundColor('#E8F5E8')
                    .borderRadius(4)
                  
                  Image($r('app.media.camera_icon'))
                    .width(24)
                    .height(24)
                    .fillColor('#FFFFFF')
                    .opacity(0.8)
                }
                .width(80)
                .height(60)
                .onClick(item.onClick)
                
                Text(item.title)
                  .fontSize(12)
                  .fontColor('#666666')
                  .margin({ top: 4 })
              }
              .backgroundColor('#F8F9FA')
              .borderRadius(8)
              .border({
                width: 1,
                color: '#E0E0E0',
                style: BorderStyle.Solid
              })
              .margin({ left: 4, right: 4 })
              .padding(8)
            })
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
        }
        .width('100%')
        .height(100)
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Auto)
      }
      .width('100%')
      .padding({ top: 16, bottom: 16, left: 16, right: 16 })
      .backgroundColor('#F8F9FA')
      .borderRadius(8)
      .border({
        width: 1,
        color: '#E0E0E0',
        style: BorderStyle.Solid
      })
    }
    .width('100%')
  }
}