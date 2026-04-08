// views/Message.ets
// 智慧农场消息界面（完整版：未读总数红圈+单条消息红圈1）

// 消息类型接口
interface FarmMessage {
  id: number;
  title: string;       // 消息标题
  content: string;     // 消息内容
  time: string;        // 时间
  unread: boolean;     // 是否未读
}

@Entry
@Component
export default struct Message {
  // 农场消息模拟数据（前两条未读，第三条已读）
  @State messageList: FarmMessage[] = [
    {
      id: 1,
      title: '1号大棚温湿度异常',
      content: '湿度不够，及时滴灌！',
      time: '10分钟前',
      unread: true
    },
    {
      id: 2,
      title: '今日农事提醒',
      content: '15:00完成2号大棚滴灌作业',
      time: '1小时前',
      unread: true
    },
    {
      id: 3,
      title: '系统更新通知',
      content: '智慧农场V1.2版本已更新',
      time: '3小时前',
      unread: false
    }
  ];

  build() {
    Column() {
      // 1. 顶部标题栏（含未读总数红圈）
      Row() {
        Text('农场消息')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        // 未读消息总数红圈（如"2"）
        if (this.getUnreadCount() > 0) {
          Text(`${this.getUnreadCount()}`)
            .fontSize(12)
            .fontColor('#FFFFFF')
            .backgroundColor('#FF5733')
            .width(20)
            .height(20)
            .textAlign(TextAlign.Center)
            .borderRadius(10)
            .margin({ left: 8 })
        }
      }
      .width('100%')
      .height(56)
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#DAF5E4')

      // 2. 消息列表（核心区域）
      if (this.messageList.length > 0) {
        List() {
          ForEach(this.messageList, (msg: FarmMessage) => {
            ListItem() {
              Row() {
                // 消息图标
                Image($r('app.media.my_image'))
                  .width(40)
                  .height(40)
                  .borderRadius(20)
                  .objectFit(ImageFit.Contain)
                  .backgroundColor(msg.unread ? '#E8F4E8' : '#F5F5F5')
                  .padding(8)

                // 消息内容区域
                Column() {
                  Row() {
                    Text(msg.title)
                      .fontSize(16)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#333333')

                    Blank()

                    Text(msg.time)
                      .fontSize(12)
                      .fontColor('#999999')
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.SpaceBetween)

                  Text(msg.content)
                    .fontSize(14)
                    .fontColor('#666666')
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .margin({ top: 4 })
                }
                .margin({ left: 12 })
                .layoutWeight(1)  // 使用layoutWeight让内容区域填充剩余空间

                // 单条消息未读红圈（显示"1"） - 修改位置
                if (msg.unread) {
                  Column() {
                    Text('1')
                      .fontSize(12)
                      .fontColor('#FFFFFF')
                      .backgroundColor('#FF5733')
                      .width(20)
                      .height(20)
                      .textAlign(TextAlign.Center)
                      .borderRadius(10)
                  }
                  .alignItems(HorizontalAlign.Center)
                  .justifyContent(FlexAlign.Center)
                }
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 12, bottom: 12 })
              .borderRadius(8)
              .backgroundColor('#FFFFFF')
              .margin({ top: 8, left: 16, right: 16 })
              .alignItems(VerticalAlign.Center)
              .onClick(() => {
                // 点击标记为已读
                this.markAsRead(msg.id)
              })
            }
          })
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor('#DAF5E4')
      } else {
        // 空数据提示
        Column() {
          Image($r('app.media.my_image'))
            .width(80)
            .height(80)
            .opacity(0.3)

          Text('暂无农场消息')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 12 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor('#DAF5E4')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#DAF5E4')
  }

  // 计算未读消息总数
  getUnreadCount(): number {
    let count = 0
    this.messageList.forEach(msg => {
      if (msg.unread) {
        count++
      }
    })
    return count
  }

  // 标记指定ID的消息为已读
  markAsRead(id: number) {
    this.messageList = this.messageList.map((msg: FarmMessage) => {
      if (msg.id === id) {
        return {
          id: msg.id,
          title: msg.title,
          content: msg.content,
          time: msg.time,
          unread: false // 标记为已读
        }
      }
      return msg
    })
  }
}