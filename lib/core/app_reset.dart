import 'package:flutter/foundation.dart';

/// Oshirilganda butun `ProviderScope` qayta yaratiladi — xotiradagi barcha holat
/// (profil, buyurtmalar, savat) yangidan, saqlangan ma'lumotdan o'qiladi.
/// Akkaunt o'chirilganda ishlatiladi.
final appResetEpoch = ValueNotifier<int>(0);
