import 'package:hive/hive.dart';

part 'SkinEnum.g.dart';

@HiveType(typeId: 20)
enum SkinEnum {
  @HiveField(0)
  fyx,
  @HiveField(1)
  forest,
}
