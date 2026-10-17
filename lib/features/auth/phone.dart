/// Telefon raqam: foydalanuvchi 9 xonali milliy raqamni kiritadi (+998 oldindan turadi),
/// ichkarida `+998XXXXXXXXX` ko'rinishida saqlanadi (server bilan bir xil).
String? normalizePhone(String raw) {
  var d = raw.replaceAll(RegExp(r'\D'), '');
  if (d.length == 12 && d.startsWith('998')) d = d.substring(3);
  if (d.length != 9) return null;
  return '+998$d';
}

/// `+998901234567` → `+998 90 123 45 67`.
String formatPhone(String phone) {
  final d = phone.replaceAll(RegExp(r'\D'), '');
  if (d.length != 12) return phone;
  return '+998 ${d.substring(3, 5)} ${d.substring(5, 8)} '
      '${d.substring(8, 10)} ${d.substring(10)}';
}
