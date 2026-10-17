// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'FitBody';

  @override
  String get next => 'Далее';

  @override
  String get skip => 'Пропустить';

  @override
  String get getStarted => 'Начать';

  @override
  String get continueBtn => 'Продолжить';

  @override
  String get start => 'Начать';

  @override
  String get language => 'Язык';

  @override
  String get comingSoon => 'Скоро';

  @override
  String get onboarding1Title => 'Начните путь к более активному образу жизни';

  @override
  String get onboarding2Title =>
      'Найдите советы по питанию под ваш образ жизни';

  @override
  String get onboarding3Title => 'Сообщество для вас — бросьте себе вызов';

  @override
  String get onboardingWelcome => 'Добро пожаловать в';

  @override
  String get welcome => 'Добро пожаловать';

  @override
  String get loginSubtitle => 'Войдите, чтобы продолжить свой фитнес-путь';

  @override
  String get createAccount => 'Создать аккаунт';

  @override
  String get signupSubtitle => 'Давайте начнём ваш путь';

  @override
  String get logIn => 'Войти';

  @override
  String get signUp => 'Регистрация';

  @override
  String get fullName => 'Полное имя';

  @override
  String get email => 'Email';

  @override
  String get password => 'Пароль';

  @override
  String get confirmPassword => 'Подтвердите пароль';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get orSignUpWith => 'или войдите через';

  @override
  String get dontHaveAccount => 'Нет аккаунта?';

  @override
  String get alreadyHaveAccount => 'Уже есть аккаунт?';

  @override
  String get forgotPasswordSubtitle =>
      'Введите email, и мы отправим код для сброса пароля';

  @override
  String get sendCode => 'Отправить код';

  @override
  String get codeSent => 'Код отправлен на ваш email';

  @override
  String get fieldRequired => 'Обязательное поле';

  @override
  String get invalidEmail => 'Неверный email';

  @override
  String get passwordTooShort => 'Минимум 6 символов';

  @override
  String get passwordsDontMatch => 'Пароли не совпадают';

  @override
  String get setupTitle => 'Постоянство — ключ к прогрессу. Не сдавайтесь!';

  @override
  String get setupSubtitle =>
      'Расскажите немного о себе, чтобы мы составили план для вас.';

  @override
  String get genderTitle => 'Ваш пол';

  @override
  String get male => 'Мужской';

  @override
  String get female => 'Женский';

  @override
  String get ageTitle => 'Сколько вам лет?';

  @override
  String get weightTitle => 'Какой у вас вес?';

  @override
  String get heightTitle => 'Какой у вас рост?';

  @override
  String get kg => 'кг';

  @override
  String get cm => 'см';

  @override
  String get goalTitle => 'Какая у вас цель?';

  @override
  String get goalLoseWeight => 'Похудеть';

  @override
  String get goalGainWeight => 'Набрать вес';

  @override
  String get goalMuscleMass => 'Набрать мышечную массу';

  @override
  String get goalShapeBody => 'Подтянуть фигуру';

  @override
  String get goalOthers => 'Другое';

  @override
  String get activityTitle => 'Уровень физической активности';

  @override
  String get beginner => 'Начальный';

  @override
  String get intermediate => 'Средний';

  @override
  String get advanced => 'Продвинутый';

  @override
  String get profileTitle => 'Заполните профиль';

  @override
  String get nickname => 'Никнейм';

  @override
  String get mobileNumber => 'Номер телефона';

  @override
  String hiUser(String name) {
    return 'Привет, $name';
  }

  @override
  String get homeSubtitle => 'Пора бросить вызов своим возможностям.';

  @override
  String get tabHome => 'Главная';

  @override
  String get tabResources => 'Статьи';

  @override
  String get tabFavorites => 'Избранное';

  @override
  String get tabSupport => 'Поддержка';

  @override
  String get tabShop => 'Магазин';

  @override
  String get tabSubscription => 'Подписка';

  @override
  String get tabNews => 'Новости';

  @override
  String get tabProfile => 'Профиль';

  @override
  String get workout => 'Тренировки';

  @override
  String get progress => 'Статистика';

  @override
  String get nutrition => 'Питание';

  @override
  String get community => 'Сообщество';

  @override
  String get recommendations => 'Рекомендации';

  @override
  String get seeAll => 'Все';

  @override
  String get weeklyChallenge => 'Недельный челлендж';

  @override
  String get articlesTips => 'Статьи и советы';

  @override
  String minutes(int count) {
    return '$count мин';
  }

  @override
  String kcal(int count) {
    return '$count ккал';
  }

  @override
  String get myRoutines => 'Мои программы';

  @override
  String get noRoutinesYet => 'Пока нет программ';

  @override
  String get makeYourOwnRoutine => 'Создать свою программу';

  @override
  String exercisesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count упражнений',
      few: '$count упражнения',
      one: '$count упражнение',
    );
    return '$_temp0';
  }

  @override
  String setsReps(int sets, int reps) {
    return '$sets × $reps';
  }

  @override
  String setsSeconds(int sets, int seconds) {
    return '$sets × $secondsс';
  }

  @override
  String get startWorkout => 'Начать тренировку';

  @override
  String get notFound => 'Не найдено';

  @override
  String get routineName => 'Название программы';

  @override
  String get chooseExercises => 'Выберите упражнения';

  @override
  String get saveRoutine => 'Сохранить';

  @override
  String get routineSaved => 'Программа сохранена';

  @override
  String get routineIncomplete =>
      'Введите название и выберите хотя бы одно упражнение';

  @override
  String get workoutLog => 'Журнал тренировок';

  @override
  String get progressCharts => 'Графики';

  @override
  String get workoutsLabel => 'тренировок';

  @override
  String get minutesLabel => 'минут';

  @override
  String get kcalLabel => 'ккал';

  @override
  String get weightProgress => 'Вес';

  @override
  String get caloriesBurned => 'Сожжено калорий (7 дней)';

  @override
  String get mealPlans => 'План питания';

  @override
  String get mealIdeas => 'Идеи блюд';

  @override
  String get breakfast => 'Завтрак';

  @override
  String get lunch => 'Обед';

  @override
  String get dinner => 'Ужин';

  @override
  String get todaysPlan => 'План на сегодня';

  @override
  String get generateWithAi => 'Составить план с AI';

  @override
  String get protein => 'Белки';

  @override
  String get carbs => 'Углеводы';

  @override
  String get fat => 'Жиры';

  @override
  String get ingredients => 'Ингредиенты';

  @override
  String get discussionForum => 'Форум';

  @override
  String get challengesCompetitions => 'Челленджи и соревнования';

  @override
  String get writePostHint => 'Поделитесь чем-нибудь с сообществом…';

  @override
  String get publish => 'Опубликовать';

  @override
  String repliesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ответов',
      few: '$count ответа',
      one: '$count ответ',
    );
    return '$_temp0';
  }

  @override
  String participantsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count участников',
      few: '$count участника',
      one: '$count участник',
    );
    return '$_temp0';
  }

  @override
  String daysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'осталось $count дней',
      few: 'осталось $count дня',
      one: 'остался $count день',
    );
    return '$_temp0';
  }

  @override
  String get join => 'Участвовать';

  @override
  String get joined => 'Вы участвуете';

  @override
  String get welcomeHeadline => 'Давайте познакомимся';

  @override
  String get welcomeHighlight => 'ближе';

  @override
  String get welcomeSubtitle =>
      'Получите персональный план тренировок и питания всего за 1 минуту.';

  @override
  String get signIn => 'Войти';

  @override
  String get getReady => 'Приготовьтесь';

  @override
  String readyUser(String name) {
    return 'Готовы, $name?';
  }

  @override
  String get search => 'Поиск';

  @override
  String get steps => 'Шаги';

  @override
  String get dailyProgram => 'Программа дня';

  @override
  String minRead(int count) {
    return '$count мин чтения';
  }

  @override
  String get browse => 'Тренировки';

  @override
  String get sorting => 'Сортировка';

  @override
  String get about => 'Описание';

  @override
  String routineAbout(int count, int minutes) {
    return 'Упражнений: $count, около $minutes минут. Следуйте таймеру и голосовым подсказкам — можно поставить на паузу в любой момент.';
  }

  @override
  String get level => 'Уровень';

  @override
  String get exercisesLabel => 'Упражнения';

  @override
  String get focusArea => 'Зона';

  @override
  String get fullBody => 'Всё тело';

  @override
  String get voiceGuide => 'Голосовые подсказки';

  @override
  String get secondsLabel => 'секунд';

  @override
  String get repsLabel => 'повторений';

  @override
  String setOf(int count) {
    return 'Подходов: $count';
  }

  @override
  String get previous => 'Назад';

  @override
  String get finish => 'Завершить';

  @override
  String get congratulation => 'Поздравляем!';

  @override
  String workoutCompleted(String title) {
    return 'Вы завершили тренировку «$title». Отлично, так держать!';
  }

  @override
  String get close => 'Закрыть';

  @override
  String get calories => 'Калории';

  @override
  String get today => 'Сегодня';

  @override
  String ofKcal(int count) {
    return 'из $count ккал';
  }

  @override
  String get dailyMeal => 'Питание на день';

  @override
  String get editPlan => 'Изменить';

  @override
  String get customizePlanHint => 'Пора настроить план питания и рецепты.';

  @override
  String get workoutVideos => 'Видеотренировки';

  @override
  String get all => 'Все';

  @override
  String get video => 'Видео';

  @override
  String get article => 'Статьи';

  @override
  String get noFavorites => 'Пока пусто — нажмите ♡, чтобы сохранить';

  @override
  String get helpCenter => 'Справка';

  @override
  String get onlineSupport => 'Онлайн-поддержка';

  @override
  String get faq1Q => 'Как составляется мой план тренировок?';

  @override
  String get faq1A =>
      'План строится на основе вашей цели, уровня и данных из настройки. Их можно изменить в любой момент в разделе «Редактировать профиль».';

  @override
  String get faq2Q => 'Можно ли заниматься без инвентаря?';

  @override
  String get faq2A =>
      'Да. Большинство программ — с собственным весом; нужный инвентарь указан в описании программы.';

  @override
  String get faq3Q => 'Как сменить язык?';

  @override
  String get faq3A =>
      'Нажмите на значок глобуса вверху или откройте Профиль → Настройки → Язык.';

  @override
  String get faq4Q => 'Мои данные в безопасности?';

  @override
  String get faq4A =>
      'Ваши данные надёжно хранятся и не передаются третьим лицам без вашего согласия.';

  @override
  String get supportGreeting =>
      'Привет! 👋 Я ассистент FitBody. Спрашивайте о тренировках и питании.';

  @override
  String get supportAutoReply =>
      'Спасибо! AI-тренер скоро появится — пока наша команда ответит вам здесь.';

  @override
  String get typeMessage => 'Введите сообщение…';

  @override
  String get logOutConfirm => 'Вы действительно хотите выйти?';

  @override
  String get cancel => 'Отмена';

  @override
  String get logOut => 'Выйти';

  @override
  String get editProfile => 'Редактировать профиль';

  @override
  String get notifications => 'Уведомления';

  @override
  String get settings => 'Настройки';

  @override
  String get help => 'Помощь';

  @override
  String get profile => 'Мой профиль';

  @override
  String get ageLabel => 'Возраст';

  @override
  String get heightLabel => 'Рост';

  @override
  String get saved => 'Сохранено';

  @override
  String get workoutReminders => 'Напоминания';

  @override
  String get systemNotifications => 'Системные';

  @override
  String get notifReminder1 => 'Время утренней растяжки — достаточно 10 минут!';

  @override
  String get notifReminder2 => 'Выпейте стакан воды 💧';

  @override
  String get notifReminder3 =>
      'Вечерняя прогулка: до цели осталось 3 000 шагов.';

  @override
  String get notifSystem1 => 'Новый челлендж недели: Plank With Hip Twist';

  @override
  String get notifSystem2 => 'Обновление: голосовые подсказки для тренировок';

  @override
  String get searchHint => 'Тренировки, блюда…';

  @override
  String get noResults => 'Ничего не найдено';

  @override
  String ttsExerciseReps(String name, int count) {
    return '$name. $count повторений.';
  }

  @override
  String ttsExerciseTimed(String name, int count) {
    return '$name. $count секунд.';
  }

  @override
  String get ttsFinished => 'Тренировка завершена. Отлично!';

  @override
  String get ttsGreatJob => 'Отлично! Цель достигнута.';

  @override
  String get aiFormCheck => 'AI-проверка техники';

  @override
  String get cameraUnavailable =>
      'Камера недоступна. Разрешите доступ к камере в настройках телефона и попробуйте снова.';

  @override
  String get stepIntoFrame => 'Отойдите, чтобы всё тело было в кадре';

  @override
  String get hintGoLower => 'Опуститесь ниже';

  @override
  String get hintKeepStraight => 'Держите корпус прямо';

  @override
  String get hintGood => 'Отличная техника!';

  @override
  String get profilePhoto => 'Фото профиля';

  @override
  String get takePhoto => 'Сделать фото';

  @override
  String get chooseFromGallery => 'Выбрать из галереи';

  @override
  String get removePhoto => 'Удалить фото';

  @override
  String get weeklyGoal => 'цель недели';

  @override
  String get kcalThisWeek => 'ккал сожжено за неделю';

  @override
  String workoutsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count тренировок',
      few: '$count тренировки',
      one: '$count тренировка',
    );
    return '$_temp0';
  }

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дней подряд',
      few: '$count дня подряд',
      one: '$count день подряд',
      zero: 'Серии пока нет',
    );
    return '$_temp0';
  }

  @override
  String get dailyCalories => 'Калории по дням';

  @override
  String avgPerActiveDay(int count) {
    return 'в среднем $count ккал в активный день';
  }

  @override
  String get dailyGoalLabel => 'цель';

  @override
  String get activityCalendar => 'Активность';

  @override
  String activeDaysOf(int count, int total) {
    return 'активных дней: $count из $total';
  }

  @override
  String get less => 'Меньше';

  @override
  String get more => 'Больше';

  @override
  String get weeklyActivity => 'Активность по неделям';

  @override
  String get minutesPerWeek => 'минут тренировок в неделю';

  @override
  String get thisWeekShort => 'сейчас';

  @override
  String sinceDate(String date) {
    return 'с $date';
  }

  @override
  String get addWeightHint => 'Регулярно вносите вес, чтобы видеть динамику.';

  @override
  String get addWeight => 'Добавить вес';

  @override
  String get byLevel => 'По уровню';

  @override
  String get totalWorkouts => 'тренировок всего';

  @override
  String get totalKcal => 'ккал всего';

  @override
  String get noWorkoutsYet =>
      'Тренировок пока нет. Завершите первую — и она появится здесь.';

  @override
  String get startFirstWorkout => 'Начать тренировку';

  @override
  String get yesterday => 'Вчера';

  @override
  String get thisWeek => 'Эта неделя';

  @override
  String get streakLabel => 'дней подряд';

  @override
  String get clearData => 'Очистить статистику';

  @override
  String get clearDataHint =>
      'Журнал тренировок и история веса (включая тестовые данные)';

  @override
  String get clearDataConfirm =>
      'Все тренировки и история веса будут удалены. Это нельзя отменить.';

  @override
  String get dataCleared => 'Статистика очищена';

  @override
  String get aiFoodScan => 'AI-сканер еды';

  @override
  String get whatAreYouEating => 'Что вы едите?';

  @override
  String get placeFoodInFrame => 'Поместите еду в рамку';

  @override
  String get gallery => 'Галерея';

  @override
  String get manualEntry => 'Вручную';

  @override
  String get aiAnalyzing => 'AI анализирует вашу еду';

  @override
  String get demoResult => 'Демо-результат — AI-сервер ещё не подключён';

  @override
  String aiConfidence(int count) {
    return 'Уверенность AI $count%';
  }

  @override
  String get portion => 'Порция';

  @override
  String get retake => 'Заново';

  @override
  String get addToDiary => 'Добавить в дневник';

  @override
  String foodAdded(int count) {
    return 'Добавлено: $count ккал';
  }

  @override
  String get snack => 'Перекус';

  @override
  String get foodName => 'Название блюда';

  @override
  String get eatenToday => 'Съедено сегодня';

  @override
  String get addFood => 'Добавить';

  @override
  String get noFoodToday =>
      'Сегодня пока ничего не записано. Нажмите + и наведите камеру на еду.';

  @override
  String get activityRun => 'Бег';

  @override
  String get activityWalk => 'Ходьба';

  @override
  String get activityBike => 'Велосипед';

  @override
  String get runMode => 'Режим пробежки';

  @override
  String get gpsSearching => 'Поиск GPS…';

  @override
  String gpsReady(int count) {
    return 'GPS готов · ±$count м';
  }

  @override
  String get gpsOff => 'Геолокация выключена';

  @override
  String get locationDenied => 'Нет доступа к геолокации';

  @override
  String get openSettings => 'Открыть настройки';

  @override
  String get runHint =>
      'Калории считаются в реальном времени по скорости и весу.';

  @override
  String get runNotificationTitle => 'Идёт тренировка';

  @override
  String get runNotificationText => 'Считаем дистанцию и калории';

  @override
  String get ttsRunStart => 'Поехали!';

  @override
  String ttsRunDone(String distance, int kcal) {
    return 'Тренировка завершена. $distance километра, $kcal калорий.';
  }

  @override
  String ttsRunKm(int km, String pace, int kcal) {
    return '$km километр. Средний темп $pace. $kcal калорий.';
  }

  @override
  String runLogTitle(String activity, String distance) {
    return '$activity · $distance км';
  }

  @override
  String get live => 'Онлайн';

  @override
  String get paused => 'Пауза';

  @override
  String get resume => 'Продолжить';

  @override
  String get pause => 'Пауза';

  @override
  String get holdToStop => 'Удерживайте';

  @override
  String get kcalBurned => 'ккал сожжено';

  @override
  String get km => 'км';

  @override
  String get minPerKm => '/км';

  @override
  String get kmh => 'км/ч';

  @override
  String get distance => 'Дистанция';

  @override
  String get pace => 'Темп';

  @override
  String get speed => 'Скорость';

  @override
  String get runSummary => 'Отличный результат!';

  @override
  String get duration => 'Время';

  @override
  String get avgPace => 'Средний темп';

  @override
  String get splits => 'Отрезки';

  @override
  String kmSplit(int count) {
    return '$count км';
  }

  @override
  String get discard => 'Удалить';

  @override
  String get eatenLabel => 'съедено';

  @override
  String get burnedLabel => 'сожжено';

  @override
  String get remainingLabel => 'осталось';

  @override
  String get overLabel => 'сверх нормы';

  @override
  String get runCardSubtitle =>
      'GPS · калории в реальном времени · нажмите, чтобы начать';

  @override
  String get friend => 'Друг';

  @override
  String get you => 'Вы';

  @override
  String macrosShort(int protein, int carbs, int fat) {
    return 'Б $protein · У $carbs · Ж $fat';
  }

  @override
  String get todaysWorkout => 'Тренировка дня';

  @override
  String get devicesTitle => 'Часы и устройства';

  @override
  String get devicesSubtitle =>
      'Шаги, пульс, сон и калории с ваших часов — через Health Connect.';

  @override
  String get devicesSettingsHint =>
      'Galaxy Watch, Mi Band, Garmin, Apple Watch…';

  @override
  String get connectYourWatch => 'Подключите часы';

  @override
  String get watchConnected => 'Часы подключены';

  @override
  String get connectWatch => 'Подключить';

  @override
  String get healthWhatWeRead => 'Что будет читать приложение:';

  @override
  String get heartRate => 'Пульс';

  @override
  String get restingHeartRate => 'Пульс в покое';

  @override
  String get sleep => 'Сон';

  @override
  String get activeCalories => 'Активные калории';

  @override
  String get healthReadOnly =>
      'Только чтение. Приложение никогда не изменяет ваши данные о здоровье.';

  @override
  String get healthDenied =>
      'Доступ не выдан. Его можно включить в Health Connect.';

  @override
  String get healthUnsupported =>
      'Health Connect недоступен на этом устройстве.';

  @override
  String get healthNeedsInstall =>
      'Установите или обновите Health Connect, чтобы подключить часы.';

  @override
  String get installHealthConnect => 'Установить Health Connect';

  @override
  String get healthNoData =>
      'Данных пока нет. Проверьте, что приложение часов делится данными с Health Connect.';

  @override
  String get samsungHealthHint =>
      'Samsung: откройте Samsung Health → Настройки → Health Connect и включите обмен данными.';

  @override
  String get syncing => 'Синхронизация…';

  @override
  String lastSync(String time) {
    return 'Обновлено в $time';
  }

  @override
  String get refresh => 'Обновить';

  @override
  String get disconnect => 'Отключить';

  @override
  String get bpm => 'уд/мин';

  @override
  String get hoursShort => 'ч';

  @override
  String get fromYourWatch => 'С ваших часов';

  @override
  String sleepDuration(int h, int m) {
    return '$h ч $m мин';
  }

  @override
  String get bodybuilding => 'Бодибилдинг';

  @override
  String get bodybuildingSubtitle =>
      'Сплиты · веса · прогрессия нагрузки · рекорды';

  @override
  String get nextSession => 'Следующая тренировка';

  @override
  String get startSession => 'Начать';

  @override
  String setsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count подходов',
      few: '$count подхода',
      one: '$count подход',
    );
    return '$_temp0';
  }

  @override
  String get personalRecords => 'Личные рекорды';

  @override
  String get weeklySetsTitle => 'Недельный объём по мышцам';

  @override
  String get weeklySetsHint =>
      'Рабочие подходы за 7 дней · 10–20 оптимально для роста';

  @override
  String get programs => 'Программы';

  @override
  String daysPerWeek(int count) {
    return '$count дн. в неделю';
  }

  @override
  String get recentSessions => 'Последние тренировки';

  @override
  String get noSessionsYet => 'Тренировок пока нет — начните первую выше.';

  @override
  String get tonnes => 'т';

  @override
  String get noSetsDone => 'Отметьте хотя бы один подход ✓';

  @override
  String get sessionDone => 'Тренировка завершена!';

  @override
  String get setsLabel => 'подходов';

  @override
  String get newPr => 'Новый рекорд';

  @override
  String get leaveSessionTitle => 'Выйти из тренировки?';

  @override
  String get leaveSessionText => 'Выполненные подходы не сохранятся.';

  @override
  String get finishSession => 'Завершить тренировку';

  @override
  String restSec(int count) {
    return 'отдых $count с';
  }

  @override
  String get lastTime => 'Прошлый раз';

  @override
  String get setCol => 'Подх.';

  @override
  String get repsCol => 'Повт.';

  @override
  String get addSet => 'Добавить подход';

  @override
  String get restTimer => 'Отдых';

  @override
  String get market => 'Магазин';

  @override
  String get myOrders => 'Мои заказы';

  @override
  String get noOrdersYet => 'Заказов пока нет.';

  @override
  String get orderStatusDemo => 'демо-заказ';

  @override
  String get mealDelivery => 'Доставка еды';

  @override
  String get sportNutrition => 'Спортпит';

  @override
  String get marketDemoNote =>
      'Демо: товары и программы питания — примеры, заказы никуда не отправляются.';

  @override
  String yourDailyNorm(int count) {
    return 'Ваша дневная норма: $count ккал';
  }

  @override
  String ageYears(int count) {
    return '$count лет';
  }

  @override
  String get recommendedForYou => 'Подходит вам';

  @override
  String get bestMatch => 'Лучший выбор';

  @override
  String mealsPerDay(int count) {
    return '$count приёмов/день';
  }

  @override
  String get matchesYourNorm => 'Соответствует вашей норме';

  @override
  String kcalFromNorm(String diff) {
    return '$diff ккал от нормы';
  }

  @override
  String get perDay => 'день';

  @override
  String get allCompanies => 'Все компании';

  @override
  String get from => 'от';

  @override
  String get callDemo => 'Демо: звонок пока недоступен';

  @override
  String get rations => 'Рационы';

  @override
  String get sampleMenu => 'Пример меню на день:';

  @override
  String get howManyDays => 'На сколько дней?';

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дней',
      few: '$count дня',
      one: '$count день',
    );
    return '$_temp0';
  }

  @override
  String orderFor(String sum) {
    return 'Заказать · $sum';
  }

  @override
  String proteinNeed(int grams, String goal) {
    return 'Ваша потребность в белке: ~$grams г/день · цель: $goal';
  }

  @override
  String get addedToCart => 'Добавлено в корзину';

  @override
  String get addToCart => 'В корзину';

  @override
  String get cart => 'Корзина';

  @override
  String get cartEmpty => 'Корзина пуста';

  @override
  String sportOrderTitle(int count) {
    return 'Спортпит · $count шт.';
  }

  @override
  String get cashOnDelivery => 'Наличные';

  @override
  String get checkout => 'Оформление заказа';

  @override
  String get deliveryAddress => 'Адрес доставки';

  @override
  String get paymentMethod => 'Способ оплаты';

  @override
  String get total => 'Итого';

  @override
  String get placeOrder => 'Оформить заказ';

  @override
  String get orderPlaced => 'Заказ принят!';

  @override
  String get orderDemoNote =>
      'Это демо-заказ. Реальная доставка и оплата заработают после подключения партнёров.';

  @override
  String get todaysMission => 'Задание на сегодня';

  @override
  String get startNow => 'Начать сейчас';

  @override
  String get missionDone => 'Задание выполнено!';

  @override
  String get missionDoneHint =>
      'Отлично — серия сохранена. Отдыхайте и восстанавливайтесь.';

  @override
  String get missionRest => 'Сегодня день отдыха';

  @override
  String get missionRestHint =>
      'Восстановление — часть тренировок. Лёгкая прогулка — бонус.';

  @override
  String get missionLightRun => 'Лёгкая прогулка или пробежка';

  @override
  String missionStreakAtRisk(int streak, int hours) {
    return 'Ваша серия $streak дн. сгорит через $hours ч — не теряйте её!';
  }

  @override
  String missionHoursLeft(int hours) {
    return 'До конца дня $hours ч. Начните серию сегодня!';
  }

  @override
  String levelShort(int level) {
    return 'Уровень $level';
  }

  @override
  String weekProgress(int done, int planned) {
    return '$done / $planned выполнено';
  }

  @override
  String get setScheduleCta =>
      'Составьте график — будем напоминать и не дадим пропустить.';

  @override
  String get achievements => 'Достижения';

  @override
  String get achFirst => 'Первая тренировка';

  @override
  String achStreak(int count) {
    return 'Серия $count дн.';
  }

  @override
  String achWorkouts(int count) {
    return '$count тренировок';
  }

  @override
  String achKcal(int count) {
    return 'Сожжено $count ккал';
  }

  @override
  String achKm(int count) {
    return '$count км пробежано';
  }

  @override
  String achLevel(int count) {
    return 'Достигните уровня $count';
  }

  @override
  String xpToNext(int xp) {
    return 'До следующего уровня $xp XP';
  }

  @override
  String get xpHowTo =>
      'Каждая тренировка даёт 50 XP и ещё 1 XP за каждые 5 ккал.';

  @override
  String get remindersHint => 'Напоминания в дни тренировок';

  @override
  String get trainingDays => 'Дни тренировок';

  @override
  String get reminderTime => 'Время напоминания';

  @override
  String streakSaverHint(int hour) {
    return 'Если до $hour:00 не потренируетесь, напомним ещё раз, чтобы сохранить серию.';
  }

  @override
  String get notificationsDenied =>
      'Уведомления запрещены. Разрешите их в настройках телефона.';

  @override
  String get reminderTitle => 'Время тренировки! 💪';

  @override
  String get reminderBody =>
      'Сегодняшняя тренировка ждёт. 20 минут хватит, чтобы сохранить серию.';

  @override
  String get streakSaverTitle => 'Ваша серия сгорает 🔥';

  @override
  String streakSaverBody(int count) {
    return '$count дн. подряд — не бросайте. Даже короткая тренировка засчитывается.';
  }

  @override
  String get streakSaverBodyNoStreak =>
      'Сегодня ещё не было тренировки. Начните сейчас — даже 10 минут засчитываются.';

  @override
  String get techniqueVideo => 'Видео техники';

  @override
  String get techniqueVideos => 'Видео техники';

  @override
  String get techniqueVideosHint =>
      'Неправильная техника ведёт к травмам. Посмотрите, как выполнять, прежде чем брать вес.';

  @override
  String get compoundLift => 'Базовое · многосуставное';

  @override
  String get isolationLift => 'Изолирующее';

  @override
  String get videoOpenFailed => 'Не удалось открыть видео';

  @override
  String get change => 'Изменить';

  @override
  String get missionRunHint => 'Пробежка с GPS — дистанция и реальные калории';

  @override
  String missionForDay(String day) {
    return 'Задание на $day';
  }

  @override
  String get missionPickHint =>
      'Выберите, чем будете заниматься в этот день каждую неделю.';

  @override
  String get missionAuto => 'Автоматически';

  @override
  String get missionAutoHint => 'Приложение само подберёт тренировку';

  @override
  String get missionBbHint => 'Следующий день вашей программы:';

  @override
  String get dayMissions => 'Задания по дням';

  @override
  String get letsStart => 'Начнём!';

  @override
  String get whyFitBody => 'Зачем FitBody';

  @override
  String get userGuide => 'Руководство';

  @override
  String get openSection => 'Открыть';

  @override
  String get replayTour => 'Показать знакомство снова';

  @override
  String get noPostsYet => 'Постов пока нет. Поделитесь прогрессом первым!';

  @override
  String get noNotifications => 'Пока нет уведомлений';

  @override
  String get navScan => 'AI';

  @override
  String get sectionsTitle => 'Разделы';

  @override
  String get sectionRun => 'Бег';

  @override
  String get sectionGuide => 'Гид';

  @override
  String get todayTitle => 'Сегодня';

  @override
  String get workoutsTitle => 'Тренировки';

  @override
  String get circlesLabel => 'кругов';

  @override
  String get stepIntoFrameHead => 'Лицо и плечи должны быть в кадре';

  @override
  String get hintGetInPlank => 'Встаньте в планку боком к камере';

  @override
  String get hintBiggerCircles => 'Вращайте головой медленно и шире';

  @override
  String get hintBendForward => 'Наклонитесь глубже вперёд';

  @override
  String get hintKeepLegsStraight => 'Не сгибайте колени';

  @override
  String get placePhoneSide =>
      'Поставьте телефон в 2–3 м сбоку от себя — всё тело должно быть в кадре';

  @override
  String get placePhoneFront =>
      'Поставьте телефон в 2–3 м напротив себя — всё тело должно быть в кадре';

  @override
  String get browseArticles => 'Смотреть статьи';
}
