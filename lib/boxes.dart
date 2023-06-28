import 'package:hive_flutter/adapters.dart';

class Boxes {
  static Box getData() => Hive.box("Todo");
}
