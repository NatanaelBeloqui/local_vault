import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 0)
class UserProfile extends HiveObject {
  @HiveField(0)
  late String name;

  @HiveField(1)
  late String email;

  @HiveField(2)
  late String registrationDate;

  @HiveField(3)
  late int score;

  UserProfile({
    required this.name,
    required this.email,
    required this.registrationDate,
    required this.score,
  });
}
