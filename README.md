# releaseTracker

## Overview
1. 追踪 github 项目的 release.
2. 当有更新时候, 会发送邮件到 mail.list
3. target.list 中是需要关心的项目
4. 仅仅在 osx 下测试
5. 推荐写在 cronjob 中定时跟踪

## Usage
```
./tracker.sh
```

## 已知问题
1. osx 下需要 `launchctl start org.postfix.master`
2. 暂无其他平台测试
3. 没参数可配置(因为懒
