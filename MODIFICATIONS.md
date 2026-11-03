# 本 Fork 修改说明

> 原项目：[NaivG/bilimusic](https://github.com/NaivG/bilimusic)（Flutter 跨平台 B 站音乐播放器，AGPL-3.0）
> 本 Fork 由 [Swenhai](https://github.com/Swenhai) 维护，修改日期：2026-11-03

## 改动概览

原项目已具备：WBI 签名与风控处理、多 P（分P）拆分、多源歌词（含翻译）、跨设备同步。
本 Fork **只补一项缺口**：**B 站 UGC 合集（ugc_season）拆分**——把「一条视频属于某个合集」的内容展开成整张歌单。

## 为什么需要

搜索「周杰伦 稻香」这类关键词时，常见结果是某个合集里的一集（例如「100 首华语经典 EP.37」）。
原逻辑只播当前这一条，用户想听合集里其他集只能自己一集集找。
分P 已有「系列视频」拆单，但 **UGC 合集是多个独立 bvid**，与分P 的数据结构完全不同，原项目未覆盖。

## 改动文件

| 文件 | 类型 | 说明 |
| --- | --- | --- |
| `lib/domain/bili_season.dart` | 新增 | 合集模型 `BiliSeason`（id / 标题 / 封面 / 剧集列表 / 总时长 / `isSeries` 判定） |
| `lib/core/network/api_service.dart` | 修改 | 新增 `getVideoSeason(bvid)`：解析 `view` 接口的 `data.ugc_season`，兼容 `arc` 嵌套与字段平铺两种写法；失败/无合集返回 null |
| `lib/features/search/ui/search_results_overlay.dart` | 修改 | 点击搜索结果时先判合集：属于合集则带着整季跳歌单页，否则维持原单曲播放 |
| `lib/shared/widgets/long_press_menu.dart` | 修改 | 右键/长按菜单新增「展开所属合集」，任意页面（搜索、收藏、歌单）都能用；新增可复用函数 `openSeasonPlaylist` |

## 行为说明

1. **搜索点击**：命中合集 → 打开歌单页（歌曲为整季各集，按接口顺序），不自动播放；非合集 → 原逻辑直接播放。
2. **长按菜单**：「展开所属合集」对任意曲目可用；不属于合集时提示「该视频不属于合集」，不影响当前播放。
3. **取流**：合集每集带自己的 `bvid` + `arc.cid`，走项目原有 `getAudioUrl` 流程，无需另设通道。
4. **容错**：`getVideoSeason` 内部捕获 `BiliException` 并返回 null，网络异常时自动退回单曲播放。

## 引用

| 引用 | 用途 |
| --- | --- |
| `/x/web-interface/view` 的 `data.ugc_season.sections[].episodes[]` | 合集剧集列表（每集含 `bvid`、`arc.cid`、`arc.title`、`arc.duration`、`arc.pic`） |
| 项目原有 `BiliClient`（WBI 签名 / Cookie / 风控重试） | 复用其请求与风控能力，未新增网络栈 |
| 项目原有 `TitleMetaFilter`、`biliCoverThumbSuffix` | 标题清洗与封面缩略规格保持一致 |

## 验证

```bash
flutter pub get
flutter analyze lib          # 0 error / 0 warning（34 条均为项目原有 info 级提示）
flutter run -d windows       # 或 flutter build windows / apk
```

实测环境：Flutter 3.47.9（stable，Dart 3.13.7），Windows 11。
