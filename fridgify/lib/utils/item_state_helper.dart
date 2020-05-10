import 'dart:ui';

enum ItemState {
  fresh,
  dueSoon,
  overDue,
}

extension ItemStateExtension on ItemState {
  Color get color {
    switch (this) {
      case ItemState.fresh:
        return Color(0xff86c06a);
      case ItemState.dueSoon:
        return Color(0xfffff265);
      case ItemState.overDue:
        return Color(0xffec6446);
      default:
        return null;
    }
  }

  ItemState byName(String name) {
    switch (name.toLowerCase()) {
      case 'fresh':
        return ItemState.fresh;
      case 'duesoon':
        return ItemState.dueSoon;
      case 'overdue':
        return ItemState.overDue;
      default:
        return null;
    }
  }
}
