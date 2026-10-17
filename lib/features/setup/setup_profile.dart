import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/locale/locale_provider.dart';

enum Gender { male, female }

enum Goal { loseWeight, gainWeight, muscleMass, shapeBody, others }

enum ActivityLevel { beginner, intermediate, advanced }

/// Haftada qanday mashg'ulot qiladi — sportpit tavsiyasi shunga tayanadi.
enum TrainingType { strength, cardio, running, hiit, yoga, teamSports }

/// 4. Set Up davomida yig'iladigan ma'lumot.
/// Keyinchalik AI reja tuzish (plan_generator) uchun serverga yuboriladi.
class SetupProfile {
  Gender gender = Gender.male;
  int age = 25;
  int weightKg = 70;
  int heightCm = 170;
  Goal goal = Goal.shapeBody;
  ActivityLevel activity = ActivityLevel.beginner;

  /// Haftasiga necha kun mashq qiladi (0–7) va qanday turlar.
  int trainingDays = 3;
  Set<TrainingType> trainingTypes = {TrainingType.strength};
  String fullName = '';
  String nickname = '';
  String email = '';
  String phone = '';

  /// Avatar fayli (ilova papkasida). `null` — avatar yo'q.
  String? avatarPath;

  /// Ko'rsatiladigan ism: taxallus → to'liq ismning birinchi so'zi → '' (ekran "Do'stim" deydi).
  String get displayName {
    if (nickname.trim().isNotEmpty) return nickname.trim();
    if (fullName.trim().isNotEmpty) return fullName.trim().split(' ').first;
    return '';
  }

  SetupProfile copy() => SetupProfile()
    ..gender = gender
    ..age = age
    ..weightKg = weightKg
    ..heightCm = heightCm
    ..goal = goal
    ..activity = activity
    ..trainingDays = trainingDays
    ..trainingTypes = {...trainingTypes}
    ..fullName = fullName
    ..nickname = nickname
    ..email = email
    ..phone = phone
    ..avatarPath = avatarPath;

  Map<String, Object?> toJson() => {
    'gender': gender.name,
    'age': age,
    'weightKg': weightKg,
    'heightCm': heightCm,
    'goal': goal.name,
    'activity': activity.name,
    'trainingDays': trainingDays,
    'trainingTypes': [for (final t in trainingTypes) t.name],
    'fullName': fullName,
    'nickname': nickname,
    'email': email,
    'phone': phone,
    'avatarPath': avatarPath,
  };

  static SetupProfile fromJson(Map<String, Object?> j) {
    T byName<T extends Enum>(List<T> values, Object? name, T fallback) =>
        values.where((v) => v.name == name).firstOrNull ?? fallback;
    final p = SetupProfile();
    return p
      ..gender = byName(Gender.values, j['gender'], p.gender)
      ..age = (j['age'] as num?)?.toInt() ?? p.age
      ..weightKg = (j['weightKg'] as num?)?.toInt() ?? p.weightKg
      ..heightCm = (j['heightCm'] as num?)?.toInt() ?? p.heightCm
      ..goal = byName(Goal.values, j['goal'], p.goal)
      ..activity = byName(ActivityLevel.values, j['activity'], p.activity)
      ..trainingDays = ((j['trainingDays'] as num?)?.toInt() ?? p.trainingDays)
          .clamp(0, 7)
      ..trainingTypes = j['trainingTypes'] is List
          ? {
              for (final n in j['trainingTypes'] as List)
                ...TrainingType.values.where((t) => t.name == n),
            }
          : p.trainingTypes
      ..fullName = j['fullName'] as String? ?? ''
      ..nickname = j['nickname'] as String? ?? ''
      ..email = j['email'] as String? ?? ''
      ..phone = j['phone'] as String? ?? ''
      ..avatarPath = j['avatarPath'] as String?;
  }
}

/// Joriy foydalanuvchi. Yangilash: `ref.read(userProvider.notifier).state = p.copy()..x = y`.
/// Har o'zgarish telefonga avtomatik saqlanadi (`userPersistenceProvider`).
/// TODO(backend): serverga ham yuborish.
final userProvider = StateProvider<SetupProfile>((ref) {
  final prefs = ref.read(sharedPrefsProvider);
  final raw = prefs.getString(_userPrefsKey);
  final user = raw == null
      ? SetupProfile()
      : SetupProfile.fromJson(jsonDecode(raw) as Map<String, Object?>);
  // Eski versiyada avatar alohida saqlangan edi.
  user.avatarPath ??= prefs.getString(avatarPrefsKey);
  return user;
});

void saveUser(Ref ref, SetupProfile user) => ref
    .read(sharedPrefsProvider)
    .setString(_userPrefsKey, jsonEncode(user.toJson()));

/// Profilni telefonga saqlab turadi — `FitnessApp` kuzatadi.
final userPersistenceProvider = Provider<void>((ref) {
  ref.listen(userProvider, (_, next) => saveUser(ref, next));
});

const _userPrefsKey = 'user_profile';
const avatarPrefsKey = 'avatar_path';
