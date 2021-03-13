# adb 使用


启动 app 带参数

```shell
adb shell am start -d 'fbgwy://fenbi.com/interview_mock/prepare?userJamId=38'
```


过滤日志

```
adb logcat | grep "tinker"
```