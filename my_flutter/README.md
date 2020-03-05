# focus_game

A new flutter module project.

## android 接入方案说明
官方文档介绍了2种：依赖module；依赖aar。
不选择依赖module这种方式的原因：因为host项目有flavor，在编译时如果flutter模块没有flavor就会报错。
虽然依赖aar会额外增加 build aar 的步骤，但是没有如上flavor的要求，同时可以减少编译时间。

## Getting Started

#### 1. 拉代码

focus_game 的 master 分支

focus-course-android 的 flutter_game 分支

把focus_game放在focus-course-android/focus-now-android（下文统称host项目）同级目录下，在focus-course-android中添加一个game模块，因为专注课堂使用ARouter做页面跳转，


#### 2. build aar
```
 flutter build aar --no-profile --no-release
```

#### 3. host项目适配

1. 添加依赖 

参考focus-course-android
添加了game模块，在game/build.gradle添加如下配置
```
android {
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
}

repositories {
    maven {
        // 配置本地仓库地址，相对路径相对于当前build.gradle,之前第一步已经放在同级目录下
        url '../../focus_game/build/host/outputs/repo'
    }
    maven {
        url 'http://download.flutter.io'
    }
}

dependencies {
    debugImplementation 'tech.brainco.focus_game:flutter_debug:1.0'
    releaseImplementation 'tech.brainco.focus_game:flutter_release:1.0'
}
```

此外还需要给app/build.gradle添加如下信息，否则会编译报错说找不到flutter_debug
```
repositories {
    maven {
        url '../../focus_game/build/host/outputs/repo'
    }
    maven {
        url 'http://download.flutter.io'
    }
}
```

2. preWarm FlutterEngine
    
在合适的时机提前初始化FlutterEngine，否则进入flutter页面会有1s的延迟
```
flutterGameHelper.preWarm(context)
```

3. 创建 GameFlutterActivity 和 HostMethodHandler

```
    /**
     * 从intent获取flutter模块中所需参数，host应用需补全所需参数
     */
    private fun getIntentArgs(intent: Intent): Map<String, Any> {
        return mapOf(
            GameConstants.Arg.DURATION to intent.getIntExtra(RoutePath.Extras.EXTRA_TRAINING_DURATION, 0)
        )
    }
```
4. 创建 GameInterceptor 拦截页面跳转并转发给 GameFlutterActivity

#### 测试
预期：点击火箭升空游戏会跳转到flutter页面，并显示游戏名称和游戏时长

## iOS 接入说明
1. 直接运行在iOS模拟器上报错如下

`Trying to embed a platform view but the PaintContext does not support embedding`

解决方案：在.ios/Runner/Info.plist中增加如下键值对
```
<key>io.flutter.embedded_views_preview</key>
<true/>
```