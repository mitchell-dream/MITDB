fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
### PodUpdate
```
fastlane PodUpdate
```
PodUpdate 用来升级 pod 的 fastlane 脚本，
        参数：tag：标签号,
             specName: spec 文件名称
        用法：fastlane PodUpdate tag:xxx specName:xxx

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
