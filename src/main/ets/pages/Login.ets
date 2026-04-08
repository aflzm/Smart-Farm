import router from '@ohos.router'; // 导入路由模块
import prompt from '@ohos.prompt'; // 导入提示模块

// 登录页面相关接口定义
interface LoginData {
  account: string;
  password: string;
  agreeTerms: boolean;
}

@Entry
@Component
struct Login {
  @State loginData: LoginData = {
    account: '',
    password: '',
    agreeTerms: false
  };

  @State isLoggingIn: boolean = false; // 登录状态
  @State loginError: string = ''; // 错误信息

  // 登录验证方法
  handleLogin() {
   // 1. 验证账号是否为空
    if (!this.loginData.account) {
      this.loginError = '请输入账号';
      return;
    }

    // 2. 验证密码是否为空
    if (!this.loginData.password) {
      this.loginError = '请输入密码';
      return;
    }

    // 3. 验证协议是否同意
    if (!this.loginData.agreeTerms) {
      this.loginError = '请先同意服务协议和隐私政策';
      return;
    }

    // 4. 验证账号密码是否正确 (模拟)
    if (this.loginData.account === 'master' && this.loginData.password === '123456') {
      this.isLoggingIn = true;
      this.loginError = '';

      // 显示登录成功提示
      prompt.showToast({
        message: '登录成功，正在跳转...',
        duration: 2000
      });

      // 3秒后跳转到Main界面
      setTimeout(() => {
        this.isLoggingIn = false;
        // 跳转到Main页面
        router.pushUrl({
          url: 'pages/Main', // Main页面的路由
          params: {
            username: this.loginData.account
          }
        });
      }, 3000);                //控制几秒登录  1000毫米等于 1秒
    } else {
      // 账号或密码错误
      this.loginError = '账号或密码错误';
    }
  }

  @Builder
  buildLoginPage() {
    Stack() {
      // ================== 核心：替换为指定的农业主题渐变背景 ==================
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          // angle: 180 表示从上到下
          angle: 180,
          colors: [
            ['rgba(194, 252, 183, 1.00)', 0.1], // 浅绿色
            ['rgba(214, 252, 195, 1.00)', 0.3], // 稍亮的浅绿色
            ['rgba(234, 246, 233, 1.00)', 1.0]  // 接近白色的淡绿色
          ]
        })
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

      // 背景光效圆圈 (保留自第二个界面)
      Column() {
        Circle({ width: 200, height: 200 })
          .fill('#FFFFFF')
          .opacity(0.1)
          .position({ x: -50, y: 100 })

        Circle({ width: 150, height: 150 })
          .fill('#E8F5E8')
          .opacity(0.2)
          .position({ x: 280, y: 400 })
      }
      .width('100%')
      .height('100%')

      // 主要内容区域 (保留自第二个界面)
      Column() {
        // 顶部标题区域
        Column({ space: 12 }) {
          Text('欢迎回来')
            .fontSize(35)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.Black)
            .alignSelf(ItemAlign.Start)
            .margin({ top: 80, left: 24 })

          Text('智慧农业物联网系统')
            .fontSize(25)
            .fontColor(Color.Black)
            .alignSelf(ItemAlign.Start)
            .margin({ left: 24 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        // 输入框区域
        Column({ space: 16 }) {
          // 账号输入框
          Row() {
            Image($r('app.media.login'))
              .width(20)
              .height(20)
              .margin({ left: 16, right: 12 })

            TextInput({
              placeholder: '请输入账号',
              text: this.loginData.account
            })
              .width('100%')
              .backgroundColor(Color.Transparent)
              .border({ width: 0 })
              .fontSize(16)
              .onChange((value: string) => {
                this.loginData.account = value;
                this.loginError = ''; // 输入时清空错误信息
              })
          }
          .width('100%')
          .height(56)
          .backgroundColor(Color.White)
          .borderRadius(28)
          .shadow({
            radius: 8,
            color: '#10000000',
            offsetX: 0,
            offsetY: 2
          })
          .margin({ left: 24, right: 24 })

          // 密码输入框
          Row() {
            Image($r('app.media.loginpassword'))
              .width(20)
              .height(20)
              .margin({ left: 16, right: 12 })

            TextInput({
              placeholder: '请输入密码',
              text: this.loginData.password
            })
              .width('100%')
              .backgroundColor(Color.Transparent)
              .border({ width: 0 })
              .fontSize(16)
              .type(InputType.Password)
              .onChange((value: string) => {
                this.loginData.password = value;
                this.loginError = ''; // 输入时清空错误信息
              })
          }
          .width('100%')
          .height(56)
          .backgroundColor(Color.White)
          .borderRadius(28)
          .shadow({
            radius: 8,
            color: '#10000000',
            offsetX: 0,
            offsetY: 2
          })
          .margin({ left: 24, right: 24 })

          // 错误信息显示
          if (this.loginError) {
            Text(this.loginError)
              .fontSize(14)
              .fontColor('#FF3B30')
              .margin({ top: 8, left: 24 })
              .width('100%')
              .textAlign(TextAlign.Start)
          }
        }
        .margin({ top: 60 })

        // 登录按钮
        Button(this.isLoggingIn ? '登录中...' : '登录')
          .width('100%')
          .height(56)
          .backgroundColor(this.isLoggingIn ? '#8BC34A' : '#ff20a400') // 按钮颜色可以根据背景微调，这里保留原样
          .borderRadius(28)
          .fontSize(20)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)
          .margin({ top: 30, left: 24, right: 24 })
          .onClick(() => {
            if (!this.isLoggingIn) {
              this.handleLogin();
            }
          })
          .enabled(!this.isLoggingIn) // 登录时禁用按钮

        Blank()

        // 底部协议区域
        Row({ space: 8 }) {
          Checkbox({ name: 'agreeTerms', group: 'agreement' })
            .select(this.loginData.agreeTerms)
            .onChange((value: boolean) => {
              this.loginData.agreeTerms = value;
              if (value) {
                this.loginError = ''; // 勾选时清空错误信息
              }
            })
            .width(18)
            .height(18)

          Row({ space: 4 }) {
            Text('已阅读并同意')
              .fontSize(14)
              .fontColor('#999999')

            Text('《服务协议》')
              .fontSize(14)
              .fontColor('#666666')
              .decoration({ type: TextDecorationType.Underline })

            Text('和')
              .fontSize(14)
              .fontColor('#999999')

            Text('《隐私政策》')
              .fontSize(14)
              .fontColor('#666666')
              .decoration({ type: TextDecorationType.Underline })
          }
        }
        .margin({ bottom: 40, left: 24, right: 24 })
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .height('100%')

      // 登录加载遮罩层 (保留自第二个界面)
      if (this.isLoggingIn) {
        Column() {
          LoadingProgress()
            .color(Color.White)
            .width(50)
            .height(50)
          Text('正在登录...')
            .fontSize(16)
            .fontColor(Color.White)
            .margin({ top: 15 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor('#000000')
        .opacity(0.7)
      }
    }
    .width('100%')
    .height('100%')

    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  build() {
    Column() {
      this.buildLoginPage()
    }
  }
}
