@Entry
@Component
export default struct Mine {
  build() {
    Column() {
      // 1. 白色标题栏（新增）
      Row() {
        Text('我的')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .width('100%')
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .height(60)
      .backgroundColor('#FFFFFF')  // 白色背景
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)

      // 2. 绿色背景区域（包含头像信息，移除了标题）
      Column() {
        // 头像+用户信息
        Row() {
          // 头像
          Image($r('app.media.my_image'))
            .width(80)  //60
            .height(80)  //60
            .borderRadius(30)
            .border({ width: 2, color: Color.White })

          // 信息
          Column() {
            Text('master')
              .fontSize(28)    //18
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .width('100%')
              .textAlign(TextAlign.Start)

            Text('电话:18888888')
              .fontSize(20)  //16
              .fontColor('#F0F8FF')
              .width('100%')
              .textAlign(TextAlign.Start)
          }
          .margin({ left: 12 })
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .height(180)  // 高度调整为180，因为移除了标题
      .backgroundColor('#2ECC71')
      .padding({ top: 20, left: 20, right: 20 })  // 调整顶部padding
      .alignItems(HorizontalAlign.Start)
      .margin({ top: 0 })

      // 3. 功能列表区域（悬浮在背景下方）
      Column() {
        // 个人信息 - 使用用户图标
        this.renderListItem('个人信息', $r('app.media.mine_information'))

        // 设备与数据管理 - 使用设备图标
        this.renderListItem('设备与数据管理', $r('app.media.mine_data'))

        // 设置 - 使用设置图标
        this.renderListItem('设置', $r('app.media.mine_set'))
      }
      .width('100%')
      .padding({ left: 20, right: 20 })
      .margin({ top: 10 })
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7F5')
  }

  // 封装列表项组件 - 添加图标参数
  @Builder
  renderListItem(title: string, leftIcon: Resource) {
    Row() {
      // 左侧图标 - 使用传入的图标
      Image(leftIcon)
        .width(24)
        .height(24)
        .margin({ left: 16, right: 12 })

      Text(title)
        .fontSize(16)
        .fontColor('#333333')

      Blank()

      // 右侧箭头
      Image($r('app.media.mine_toright'))
        .width(16)
        .height(16)
        .margin({ right: 16 })
    }
    .width('100%')
    .height(56)
    .backgroundColor('#ffdbf5da')  // 绿色背景
    .borderRadius(8)
    .alignItems(VerticalAlign.Center)
    .margin({ bottom: 10 })
  }
}