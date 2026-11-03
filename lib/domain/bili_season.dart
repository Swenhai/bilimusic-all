import 'package:bilimusic/domain/music.dart';

/// B 站 UGC 合集（`view` 接口的 `data.ugc_season`）。
///
/// 与「分P」的区别：分P 是同一个 bvid 下的多个 cid；合集是多个**独立 bvid**
/// 组成的一季内容。二者都能拆成单曲播放，但合集要按 bvid + cid 双要素取流。
class BiliSeason {
  /// 合集 id（`ugc_season.id`），用作歌单标识。
  final int id;

  /// 合集标题（`ugc_season.title`）。
  final String title;

  /// 合集封面（`ugc_season.cover`），缺失时为空串。
  final String coverUrl;

  /// 合集全部剧集，按接口顺序展开（跨 section 顺排）。
  final List<Music> episodes;

  const BiliSeason({
    required this.id,
    required this.title,
    required this.coverUrl,
    required this.episodes,
  });

  /// 是否值得拆分（只有一集的合集没有拆分意义）。
  bool get isSeries => episodes.length > 1;

  /// 合集总时长。
  Duration get totalDuration => episodes.fold(
    Duration.zero,
    (sum, e) => sum + (e.duration ?? Duration.zero),
  );
}
