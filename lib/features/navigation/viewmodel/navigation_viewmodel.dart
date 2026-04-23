import 'package:flutter_riverpod/flutter_riverpod.dart';

class NavigationViewModel extends Notifier<int> {
  @override
  int build() => 0; // default tab

  void setIndex(int index) {
    state = index;
  }
}

final navigationProvider =
    NotifierProvider<NavigationViewModel, int>(
  () => NavigationViewModel(),
);