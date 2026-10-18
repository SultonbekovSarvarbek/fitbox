import '../features/setup/setup_profile.dart';
import 'content/content_l10n.dart';

/// Для кого товар, программа питания или статья.
enum Audience { everyone, men, women }

/// Что выбрал пользователь в переключателе «Все / Мужчинам / Женщинам».
enum AudienceFilter { all, men, women }

const audienceFilterNames = <AudienceFilter, Tr>{
  AudienceFilter.all: Tr('All', 'Hammasi', 'Все'),
  AudienceFilter.men: Tr('For men', 'Erkaklarga', 'Мужчинам'),
  AudienceFilter.women: Tr('For women', 'Ayollarga', 'Женщинам'),
};

/// Переключатель по умолчанию — по полу из анкеты.
AudienceFilter audienceFilterFor(Gender gender) =>
    gender == Gender.male ? AudienceFilter.men : AudienceFilter.women;

/// Показывать ли элемент при выбранном фильтре. «Для всех» видно всегда,
/// «мужчинам» / «женщинам» — только в своём фильтре и в «Все».
bool audienceVisible(Audience item, AudienceFilter filter) => switch (filter) {
  AudienceFilter.all => true,
  AudienceFilter.men => item != Audience.women,
  AudienceFilter.women => item != Audience.men,
};

/// Подходит ли элемент человеку этого пола (для рекомендаций).
bool audienceFitsGender(Audience item, Gender gender) =>
    audienceVisible(item, audienceFilterFor(gender));

/// Элемент сделан именно для этого пола (а не «для всех») — такому отдаём предпочтение.
bool audienceIsSpecificTo(Audience item, Gender gender) =>
    item == (gender == Gender.male ? Audience.men : Audience.women);
