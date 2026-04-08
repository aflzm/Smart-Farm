@Entry
@Component
struct Index {
  @State message: string = 'Hello World ';
  @State count:number=5;
  //自动跳转，进入页面的时候开始执行
  aboutToAppear(): void {
    console.log('进入界面')
    //开始倒计时
    let interval = setInterval(()=>{
      //执行的方法
      console.log('开始倒计时')
      this.count--
      if(this.count<=0){
        clearInterval(interval) //取消定时器
        //跳转到下一个界面
        this.getUIContext().getRouter().replaceUrl({

          url: 'pages/Login'
        })
      }
    },1000)  //    1000毫秒=1秒  后跳转
  }


  build() {
    Column() {
      //第一部分
      Column() {
        Button('跳过').height(35)
          .backgroundColor(Color.Black)   //枚举
          .opacity(0.6)    //透明度，整个按钮所有内容都透明，包含文字
          .onClick(() => {
            console.log('点击了跳过');
            this.getUIContext().getRouter().replaceUrl({
              //  replaceUrl不可以返回的跳转
              url: 'pages/Login'
            })
          })
      }
      .height('10%')
      .width('100%')
      //  .backgroundColor(Color.Yellow)
      .alignItems(HorizontalAlign.End)
      .padding(10)


      //第二部分
      Column() {
        Image($r('app.media.ic_welcome'))
          .width('70%')
      }
      .height('60%')
      .width('100%')
      //.backgroundColor(Color.Green)
      .margin({ top: 30 })


      //第三部分
      Column() {
        Column() {
          //横向布局
          Row() {
            Text('Copyright © 2021-2025 | ').fontSize(14).fontColor('#ccc')
            Text('IPv6')
              .border({ width: 1, style: BorderStyle.Solid, color: '#ccc' })
              .borderRadius(16)
              .padding({
                left: 5,
                right: 5,
                top: 0,
                bottom: 0
              })
              .fontSize(13)
              .fontColor('#ccc')
          }

          Text('农业物联网系统').fontSize(14).fontColor('#ccc')
            .margin({ top: 10 })
        }
      }
      .height('30%')
      .width('100%')
      .justifyContent(FlexAlign.End)
      .padding({ bottom: 20 }) //底部边距 20
      //.backgroundColor(Color.Blue)
    }


    .height('100%')
    .width('100%')
    //.backgroundColor(Color.Red)
    //.backgroundColor('rgba(0,0,0,0.80)')  //rgba a 表示透明度，0-1
    //线性渐变
    .linearGradient({
      angle: 180, colors: [['rgba(213,248,178,1.00)', 0], ['rgba(235,253,216,1)', 0.3], ['rgba(235,253,216,0)', 1]]

    })

    .expandSafeArea([SafeAreaType.SYSTEM],[SafeAreaEdge.TOP,SafeAreaEdge.BOTTOM])
  }
}