import { it } from '@ohos/hypium';
import { TabType } from '../models/MainModel';

import Home from '../views/Home';
import Greenhouse from '../views/Greenhouse';
import Message from '../views/Message';
import Mine from '../views/Mine';

// 声明变量
let title:string = "asd"
console.log("sa")
@Entry
@Component
struct Main {
  @State message: string = 'Hello World';
  @State isActive:string = 'home'

  tabData:TabType[]=[
    {icon:$r('app.media.tabs_firstpage'),text:'首页',name:'home'},
    {icon:$r('app.media.ic_greenhouse'),text:'大棚',name:'greenhouse'},
    {icon:$r('app.media.ic_msg'),text:'消息',name:'message'},
    {icon:$r('app.media.ic_mine'),text:'我的',name:'mine'},
  ]

  @Builder
  taBarBuilder(item:TabType){
    Column({space:5}){
      Image(item.icon)
        .height(25)
        .fillColor(this.isActive === item.name ? '#59A869':'#D5D5D5')
      Text(item.text)
        .fontSize(14)
    }
  }

  build() {
    Tabs({ barPosition: BarPosition.End }) {
      ForEach(this.tabData, (item: TabType, index: number) => {
        TabContent() {
          if (item.name === 'home') {
            Home()
          } else if (item.name === 'greenhouse') {
            Greenhouse()  // 大棚页面组件
          }
          else if (item.name === 'message') {
            Message()  // 大棚页面组件
          }
          else if (item.name === 'mine') {
            Mine()  // 大棚页面组件
          }

          else {
            Home()
          }
        }
        .height('100%')
        .tabBar(this.taBarBuilder(item)) //导航按钮区
      })
    }
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

    .onChange((index:number)=>{
      this.isActive = this.tabData[index].name

    })

  }
}