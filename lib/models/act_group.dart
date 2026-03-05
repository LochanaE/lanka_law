import 'act_item.dart';

class ActGroup {
  final String actNo;
  ActItem? en;
  ActItem? si;
  ActItem? ta;

  ActGroup({
    required this.actNo,
    this.en,
    this.si,
    this.ta,
  });

  String get displayTitle {
    return en?.title ?? si?.title ?? ta?.title ?? 'Unknown Title';
  }

  DateTime? get publishedDate {
    return en?.publishedDate ?? si?.publishedDate ?? ta?.publishedDate;
  }

  bool get hasEn => en != null;
  bool get hasSi => si != null;
  bool get hasTa => ta != null;
}
