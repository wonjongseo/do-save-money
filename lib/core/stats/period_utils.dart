import 'stat_period.dart';

/// 통계 구간 계산 유틸
class PeriodUtils {
  /// 기간 내 버킷 리스트 생성 (start 포함, end 미포함)
  static List<PeriodRange> buildRanges({
    required int startMillis,
    required int endMillis,
    required StatPeriod period,
    int weekStartsOn = DateTime.monday,
  }) {
    final ranges = <PeriodRange>[];
    var cursor = _floorToPeriodStart(
      millis: startMillis,
      period: period,
      weekStartsOn: weekStartsOn,
    );

    while (cursor < endMillis) {
      final next = _nextPeriodStart(
        millis: cursor,
        period: period,
        weekStartsOn: weekStartsOn,
      );
      ranges.add(PeriodRange(startMillis: cursor, endMillis: next));
      cursor = next;
    }
    return ranges;
  }

  /// 특정 시점을 해당 period의 시작으로 내림
  static int floorToPeriodStart({
    required int millis,
    required StatPeriod period,
    int weekStartsOn = DateTime.monday,
  }) {
    return _floorToPeriodStart(
      millis: millis,
      period: period,
      weekStartsOn: weekStartsOn,
    );
  }

  /// 특정 버킷의 종료 시점(다음 버킷 시작)
  static int nextPeriodStart({
    required int millis,
    required StatPeriod period,
    int weekStartsOn = DateTime.monday,
  }) {
    return _nextPeriodStart(
      millis: millis,
      period: period,
      weekStartsOn: weekStartsOn,
    );
  }

  static int _floorToPeriodStart({
    required int millis,
    required StatPeriod period,
    required int weekStartsOn,
  }) {
    final dt = DateTime.fromMillisecondsSinceEpoch(millis);

    switch (period) {
      case StatPeriod.day:
        return DateTime(dt.year, dt.month, dt.day).millisecondsSinceEpoch;
      case StatPeriod.week:
        // weekStartsOn: DateTime.monday ~ DateTime.sunday
        final current = DateTime(dt.year, dt.month, dt.day);
        final diff = (current.weekday - weekStartsOn + 7) % 7;
        return current.subtract(Duration(days: diff)).millisecondsSinceEpoch;
      case StatPeriod.month:
        return DateTime(dt.year, dt.month, 1).millisecondsSinceEpoch;
    }
  }

  static int _nextPeriodStart({
    required int millis,
    required StatPeriod period,
    required int weekStartsOn,
  }) {
    final dt = DateTime.fromMillisecondsSinceEpoch(millis);

    switch (period) {
      case StatPeriod.day:
        return DateTime(dt.year, dt.month, dt.day + 1).millisecondsSinceEpoch;
      case StatPeriod.week:
        return DateTime(dt.year, dt.month, dt.day)
            .add(const Duration(days: 7))
            .millisecondsSinceEpoch;
      case StatPeriod.month:
        return DateTime(dt.year, dt.month + 1, 1).millisecondsSinceEpoch;
    }
  }
}

/// 기간 버킷 모델
class PeriodRange {
  final int startMillis; // inclusive
  final int endMillis; // exclusive

  const PeriodRange({required this.startMillis, required this.endMillis});
}
