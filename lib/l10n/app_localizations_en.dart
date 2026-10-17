// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'FitBody';

  @override
  String get next => 'Next';

  @override
  String get skip => 'Skip';

  @override
  String get getStarted => 'Get Started';

  @override
  String get continueBtn => 'Continue';

  @override
  String get start => 'Start';

  @override
  String get language => 'Language';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get onboarding1Title =>
      'Start your journey towards a more active lifestyle';

  @override
  String get onboarding2Title => 'Find nutrition tips that fit your lifestyle';

  @override
  String get onboarding3Title => 'A community for you, challenge yourself';

  @override
  String get onboardingWelcome => 'Welcome to';

  @override
  String get welcome => 'Welcome';

  @override
  String get loginSubtitle => 'Log in to continue your fitness journey';

  @override
  String get createAccount => 'Create Account';

  @override
  String get signupSubtitle => 'Let\'s start your journey';

  @override
  String get logIn => 'Log In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get fullName => 'Full name';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get orSignUpWith => 'or sign up with';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your email and we will send you a code to reset your password';

  @override
  String get sendCode => 'Send code';

  @override
  String get codeSent => 'Code sent to your email';

  @override
  String get fieldRequired => 'Required field';

  @override
  String get invalidEmail => 'Invalid email';

  @override
  String get passwordTooShort => 'Minimum 6 characters';

  @override
  String get passwordsDontMatch => 'Passwords don\'t match';

  @override
  String get setupTitle =>
      'Consistency is the key to progress. Don\'t give up!';

  @override
  String get setupSubtitle =>
      'Tell us a bit about yourself so we can build a plan just for you.';

  @override
  String get genderTitle => 'What\'s your gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get ageTitle => 'How old are you?';

  @override
  String get weightTitle => 'What is your weight?';

  @override
  String get heightTitle => 'What is your height?';

  @override
  String get kg => 'kg';

  @override
  String get cm => 'cm';

  @override
  String get goalTitle => 'What is your goal?';

  @override
  String get goalLoseWeight => 'Lose weight';

  @override
  String get goalGainWeight => 'Gain weight';

  @override
  String get goalMuscleMass => 'Muscle mass gain';

  @override
  String get goalShapeBody => 'Shape body';

  @override
  String get goalOthers => 'Others';

  @override
  String get activityTitle => 'Physical activity level';

  @override
  String get beginner => 'Beginner';

  @override
  String get intermediate => 'Intermediate';

  @override
  String get advanced => 'Advanced';

  @override
  String get profileTitle => 'Fill your profile';

  @override
  String get nickname => 'Nickname';

  @override
  String get mobileNumber => 'Mobile number';

  @override
  String hiUser(String name) {
    return 'Hi, $name';
  }

  @override
  String get homeSubtitle => 'It\'s time to challenge your limits.';

  @override
  String get tabHome => 'Home';

  @override
  String get tabResources => 'Articles';

  @override
  String get tabFavorites => 'Favorites';

  @override
  String get tabSupport => 'Support';

  @override
  String get tabShop => 'Shop';

  @override
  String get tabSubscription => 'Subscription';

  @override
  String get tabNews => 'News';

  @override
  String get tabProfile => 'Profile';

  @override
  String get workout => 'Workout';

  @override
  String get progress => 'Statistics';

  @override
  String get nutrition => 'Nutrition';

  @override
  String get community => 'Community';

  @override
  String get recommendations => 'Recommendations';

  @override
  String get seeAll => 'See all';

  @override
  String get weeklyChallenge => 'Weekly Challenge';

  @override
  String get articlesTips => 'Articles & Tips';

  @override
  String minutes(int count) {
    return '$count min';
  }

  @override
  String kcal(int count) {
    return '$count kcal';
  }

  @override
  String get myRoutines => 'My routines';

  @override
  String get noRoutinesYet => 'No routines yet';

  @override
  String get makeYourOwnRoutine => 'Make your own routine';

  @override
  String exercisesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercises',
      one: '1 exercise',
    );
    return '$_temp0';
  }

  @override
  String setsReps(int sets, int reps) {
    return '$sets × $reps';
  }

  @override
  String setsSeconds(int sets, int seconds) {
    return '$sets × ${seconds}s';
  }

  @override
  String get startWorkout => 'Start workout';

  @override
  String get notFound => 'Not found';

  @override
  String get routineName => 'Routine name';

  @override
  String get chooseExercises => 'Choose exercises';

  @override
  String get saveRoutine => 'Save';

  @override
  String get routineSaved => 'Routine saved';

  @override
  String get routineIncomplete =>
      'Enter a name and choose at least one exercise';

  @override
  String get workoutLog => 'Workout Log';

  @override
  String get progressCharts => 'Progress Charts';

  @override
  String get workoutsLabel => 'workouts';

  @override
  String get minutesLabel => 'minutes';

  @override
  String get kcalLabel => 'kcal';

  @override
  String get weightProgress => 'Weight';

  @override
  String get caloriesBurned => 'Calories burned (7 days)';

  @override
  String get mealPlans => 'Meal Plans';

  @override
  String get mealIdeas => 'Meal Ideas';

  @override
  String get breakfast => 'Breakfast';

  @override
  String get lunch => 'Lunch';

  @override
  String get dinner => 'Dinner';

  @override
  String get todaysPlan => 'Today\'s plan';

  @override
  String get generateWithAi => 'Generate plan with AI';

  @override
  String get protein => 'Protein';

  @override
  String get carbs => 'Carbs';

  @override
  String get fat => 'Fat';

  @override
  String get ingredients => 'Ingredients';

  @override
  String get discussionForum => 'Discussion forum';

  @override
  String get challengesCompetitions => 'Challenges & competitions';

  @override
  String get writePostHint => 'Share something with the community…';

  @override
  String get publish => 'Publish';

  @override
  String repliesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count replies',
      one: '1 reply',
    );
    return '$_temp0';
  }

  @override
  String participantsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count participants',
      one: '1 participant',
    );
    return '$_temp0';
  }

  @override
  String daysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days left',
      one: '1 day left',
    );
    return '$_temp0';
  }

  @override
  String get join => 'Join';

  @override
  String get joined => 'Joined';

  @override
  String get welcomeHeadline => 'Let\'s get to know you';

  @override
  String get welcomeHighlight => 'better';

  @override
  String get welcomeSubtitle =>
      'Get your personalized workout and meal plan in just 1 minute to help achieve your fitness goals.';

  @override
  String get signIn => 'Sign in';

  @override
  String get getReady => 'Get ready';

  @override
  String readyUser(String name) {
    return 'Ready, $name?';
  }

  @override
  String get search => 'Search';

  @override
  String get steps => 'Steps';

  @override
  String get dailyProgram => 'Daily Program';

  @override
  String minRead(int count) {
    return '$count min read';
  }

  @override
  String get browse => 'Browse';

  @override
  String get sorting => 'Sorting';

  @override
  String get about => 'About';

  @override
  String routineAbout(int count, int minutes) {
    return '$count exercises, about $minutes minutes. Follow the timer and the voice guide — you can pause at any time.';
  }

  @override
  String get level => 'Level';

  @override
  String get exercisesLabel => 'Exercises';

  @override
  String get focusArea => 'Focus area';

  @override
  String get fullBody => 'Full body';

  @override
  String get voiceGuide => 'Voice guide';

  @override
  String get secondsLabel => 'seconds';

  @override
  String get repsLabel => 'reps';

  @override
  String setOf(int count) {
    return '$count sets';
  }

  @override
  String get previous => 'Previous';

  @override
  String get finish => 'Finish';

  @override
  String get congratulation => 'Congratulations!';

  @override
  String workoutCompleted(String title) {
    return 'You have completed “$title”. Great job, keep it up!';
  }

  @override
  String get close => 'Close';

  @override
  String get calories => 'Calories';

  @override
  String get today => 'Today';

  @override
  String ofKcal(int count) {
    return 'of $count kcal';
  }

  @override
  String get dailyMeal => 'Daily meal';

  @override
  String get editPlan => 'Edit plan';

  @override
  String get customizePlanHint =>
      'It\'s time to customize your meal plan and recipes.';

  @override
  String get workoutVideos => 'Workout Videos';

  @override
  String get all => 'All';

  @override
  String get video => 'Video';

  @override
  String get article => 'Article';

  @override
  String get noFavorites => 'Nothing here yet — tap ♡ to save';

  @override
  String get helpCenter => 'Help Center';

  @override
  String get onlineSupport => 'Online Support';

  @override
  String get faq1Q => 'How is my workout plan created?';

  @override
  String get faq1A =>
      'Your plan is based on your goal, level and body data from the setup. You can change them any time in Edit Profile.';

  @override
  String get faq2Q => 'Can I use the app without equipment?';

  @override
  String get faq2A =>
      'Yes. Most routines are bodyweight only; equipment is listed in the routine details.';

  @override
  String get faq3Q => 'How do I change the language?';

  @override
  String get faq3A =>
      'Tap the globe icon at the top or open Profile → Settings → Language.';

  @override
  String get faq4Q => 'Is my data safe?';

  @override
  String get faq4A =>
      'Your data is stored securely and is never shared with third parties without your consent.';

  @override
  String get supportGreeting =>
      'Hi! 👋 I\'m your FitBody assistant. Ask me anything about workouts or nutrition.';

  @override
  String get supportAutoReply =>
      'Thanks! The AI coach is coming soon — for now our team will answer you here shortly.';

  @override
  String get typeMessage => 'Type a message…';

  @override
  String get logOutConfirm => 'Are you sure you want to log out?';

  @override
  String get cancel => 'Cancel';

  @override
  String get logOut => 'Log Out';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get notifications => 'Notifications';

  @override
  String get settings => 'Settings';

  @override
  String get help => 'Help';

  @override
  String get profile => 'My Profile';

  @override
  String get ageLabel => 'Age';

  @override
  String get heightLabel => 'Height';

  @override
  String get saved => 'Saved';

  @override
  String get workoutReminders => 'Workout Reminders';

  @override
  String get systemNotifications => 'System';

  @override
  String get notifReminder1 =>
      'Time for your morning stretch — 10 minutes is enough!';

  @override
  String get notifReminder2 => 'Drink a glass of water 💧';

  @override
  String get notifReminder3 =>
      'Evening walk: 3,000 steps left to reach your goal.';

  @override
  String get notifSystem1 => 'New weekly challenge: Plank With Hip Twist';

  @override
  String get notifSystem2 => 'App updated: new voice guide for workouts';

  @override
  String get searchHint => 'Workouts, meals…';

  @override
  String get noResults => 'Nothing found';

  @override
  String ttsExerciseReps(String name, int count) {
    return '$name. $count reps.';
  }

  @override
  String ttsExerciseTimed(String name, int count) {
    return '$name. $count seconds.';
  }

  @override
  String get ttsFinished => 'Workout complete. Great job!';

  @override
  String get ttsGreatJob => 'Great job! Target reached.';

  @override
  String get aiFormCheck => 'AI form check';

  @override
  String get cameraUnavailable =>
      'Camera is not available. Allow camera access in the phone settings and try again.';

  @override
  String get stepIntoFrame => 'Step back so your whole body is in the frame';

  @override
  String get hintGoLower => 'Go lower';

  @override
  String get hintKeepStraight => 'Keep your body straight';

  @override
  String get hintGood => 'Good form!';

  @override
  String get profilePhoto => 'Profile photo';

  @override
  String get takePhoto => 'Take a photo';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get weeklyGoal => 'weekly goal';

  @override
  String get kcalThisWeek => 'kcal burned this week';

  @override
  String workoutsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count workouts',
      one: '1 workout',
    );
    return '$_temp0';
  }

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count day streak',
      one: '1 day streak',
      zero: 'No streak yet',
    );
    return '$_temp0';
  }

  @override
  String get dailyCalories => 'Daily calories';

  @override
  String avgPerActiveDay(int count) {
    return 'avg $count kcal per active day';
  }

  @override
  String get dailyGoalLabel => 'goal';

  @override
  String get activityCalendar => 'Activity';

  @override
  String activeDaysOf(int count, int total) {
    return '$count active days of $total';
  }

  @override
  String get less => 'Less';

  @override
  String get more => 'More';

  @override
  String get weeklyActivity => 'Weekly activity';

  @override
  String get minutesPerWeek => 'minutes of training per week';

  @override
  String get thisWeekShort => 'now';

  @override
  String sinceDate(String date) {
    return 'since $date';
  }

  @override
  String get addWeightHint => 'Add your weight regularly to see the trend.';

  @override
  String get addWeight => 'Add weight';

  @override
  String get byLevel => 'By level';

  @override
  String get totalWorkouts => 'workouts in total';

  @override
  String get totalKcal => 'kcal in total';

  @override
  String get noWorkoutsYet =>
      'No workouts yet. Finish your first workout and it will appear here.';

  @override
  String get startFirstWorkout => 'Start a workout';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get thisWeek => 'This week';

  @override
  String get streakLabel => 'day streak';

  @override
  String get clearData => 'Clear statistics';

  @override
  String get clearDataHint =>
      'Workout log and weight history (incl. test data)';

  @override
  String get clearDataConfirm =>
      'All workouts and weight history will be deleted. This cannot be undone.';

  @override
  String get dataCleared => 'Statistics cleared';

  @override
  String get aiFoodScan => 'AI food scan';

  @override
  String get whatAreYouEating => 'What are you eating?';

  @override
  String get placeFoodInFrame => 'Place the food inside the frame';

  @override
  String get gallery => 'Gallery';

  @override
  String get manualEntry => 'Manual';

  @override
  String get aiAnalyzing => 'AI is analyzing your food';

  @override
  String get demoResult => 'Demo result — AI server not connected yet';

  @override
  String aiConfidence(int count) {
    return 'AI confidence $count%';
  }

  @override
  String get portion => 'Portion';

  @override
  String get retake => 'Retake';

  @override
  String get addToDiary => 'Add to diary';

  @override
  String foodAdded(int count) {
    return 'Added: $count kcal';
  }

  @override
  String get snack => 'Snack';

  @override
  String get foodName => 'Food name';

  @override
  String get eatenToday => 'Eaten today';

  @override
  String get addFood => 'Add';

  @override
  String get noFoodToday =>
      'Nothing logged yet today. Tap + and point the camera at your meal.';

  @override
  String get activityRun => 'Running';

  @override
  String get activityWalk => 'Walking';

  @override
  String get activityBike => 'Cycling';

  @override
  String get runMode => 'Run mode';

  @override
  String get gpsSearching => 'Searching for GPS…';

  @override
  String gpsReady(int count) {
    return 'GPS ready · ±$count m';
  }

  @override
  String get gpsOff => 'Location is turned off';

  @override
  String get locationDenied => 'No location permission';

  @override
  String get openSettings => 'Open settings';

  @override
  String get runHint =>
      'Calories are counted in real time from your speed and weight.';

  @override
  String get runNotificationTitle => 'Workout in progress';

  @override
  String get runNotificationText => 'Tracking distance and calories';

  @override
  String get ttsRunStart => 'Go!';

  @override
  String ttsRunDone(String distance, int kcal) {
    return 'Workout finished. $distance kilometres, $kcal calories.';
  }

  @override
  String ttsRunKm(int km, String pace, int kcal) {
    return '$km kilometres. Average pace $pace. $kcal calories.';
  }

  @override
  String runLogTitle(String activity, String distance) {
    return '$activity · $distance km';
  }

  @override
  String get live => 'Live';

  @override
  String get paused => 'Paused';

  @override
  String get resume => 'Resume';

  @override
  String get pause => 'Pause';

  @override
  String get holdToStop => 'Hold to stop';

  @override
  String get kcalBurned => 'kcal burned';

  @override
  String get km => 'km';

  @override
  String get minPerKm => '/km';

  @override
  String get kmh => 'km/h';

  @override
  String get distance => 'Distance';

  @override
  String get pace => 'Pace';

  @override
  String get speed => 'Speed';

  @override
  String get runSummary => 'Great job!';

  @override
  String get duration => 'Time';

  @override
  String get avgPace => 'Avg pace';

  @override
  String get splits => 'Splits';

  @override
  String kmSplit(int count) {
    return '$count km';
  }

  @override
  String get discard => 'Discard';

  @override
  String get eatenLabel => 'eaten';

  @override
  String get burnedLabel => 'burned';

  @override
  String get remainingLabel => 'left';

  @override
  String get overLabel => 'over';

  @override
  String get runCardSubtitle => 'GPS · real-time calories · tap to start';

  @override
  String get friend => 'Friend';

  @override
  String get you => 'You';

  @override
  String macrosShort(int protein, int carbs, int fat) {
    return 'P $protein · C $carbs · F $fat';
  }

  @override
  String get todaysWorkout => 'Today\'s workout';

  @override
  String get devicesTitle => 'Watch & devices';

  @override
  String get devicesSubtitle =>
      'Steps, heart rate, sleep and calories from your watch — via Health Connect.';

  @override
  String get devicesSettingsHint =>
      'Galaxy Watch, Mi Band, Garmin, Apple Watch…';

  @override
  String get connectYourWatch => 'Connect your watch';

  @override
  String get watchConnected => 'Watch connected';

  @override
  String get connectWatch => 'Connect';

  @override
  String get healthWhatWeRead => 'What the app will read:';

  @override
  String get heartRate => 'Heart rate';

  @override
  String get restingHeartRate => 'Resting pulse';

  @override
  String get sleep => 'Sleep';

  @override
  String get activeCalories => 'Active calories';

  @override
  String get healthReadOnly =>
      'Read only. The app never changes your health data.';

  @override
  String get healthDenied =>
      'Permission not granted. You can allow it in Health Connect.';

  @override
  String get healthUnsupported =>
      'Health Connect is not available on this device.';

  @override
  String get healthNeedsInstall =>
      'Install or update Health Connect to connect your watch.';

  @override
  String get installHealthConnect => 'Install Health Connect';

  @override
  String get healthNoData =>
      'No data yet. Make sure your watch app shares data with Health Connect.';

  @override
  String get samsungHealthHint =>
      'Samsung: open Samsung Health → Settings → Health Connect and turn on data sharing.';

  @override
  String get syncing => 'Syncing…';

  @override
  String lastSync(String time) {
    return 'Updated at $time';
  }

  @override
  String get refresh => 'Refresh';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get bpm => 'bpm';

  @override
  String get hoursShort => 'h';

  @override
  String get fromYourWatch => 'From your watch';

  @override
  String sleepDuration(int h, int m) {
    return '${h}h ${m}m';
  }

  @override
  String get bodybuilding => 'Bodybuilding';

  @override
  String get bodybuildingSubtitle =>
      'Splits · weights · progressive overload · PRs';

  @override
  String get nextSession => 'Next session';

  @override
  String get startSession => 'Start session';

  @override
  String setsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sets',
      one: '1 set',
    );
    return '$_temp0';
  }

  @override
  String get personalRecords => 'Personal records';

  @override
  String get weeklySetsTitle => 'Weekly volume by muscle';

  @override
  String get weeklySetsHint =>
      'Working sets in the last 7 days · 10–20 is optimal for growth';

  @override
  String get programs => 'Programs';

  @override
  String daysPerWeek(int count) {
    return '$count days / week';
  }

  @override
  String get recentSessions => 'Recent sessions';

  @override
  String get noSessionsYet => 'No sessions yet — start your first one above.';

  @override
  String get tonnes => 't';

  @override
  String get noSetsDone => 'Mark at least one set as done ✓';

  @override
  String get sessionDone => 'Session complete!';

  @override
  String get setsLabel => 'sets';

  @override
  String get newPr => 'New PR';

  @override
  String get leaveSessionTitle => 'Leave the session?';

  @override
  String get leaveSessionText => 'Completed sets will not be saved.';

  @override
  String get finishSession => 'Finish session';

  @override
  String restSec(int count) {
    return 'rest ${count}s';
  }

  @override
  String get lastTime => 'Last time';

  @override
  String get setCol => 'Set';

  @override
  String get repsCol => 'Reps';

  @override
  String get addSet => 'Add set';

  @override
  String get restTimer => 'Rest';

  @override
  String get market => 'Shop';

  @override
  String get myOrders => 'My orders';

  @override
  String get noOrdersYet => 'No orders yet.';

  @override
  String get orderStatusDemo => 'demo order';

  @override
  String get mealDelivery => 'Meal delivery';

  @override
  String get sportNutrition => 'Sport nutrition';

  @override
  String get marketDemoNote =>
      'Demo: products and meal programs are examples, orders are not sent anywhere.';

  @override
  String yourDailyNorm(int count) {
    return 'Your daily norm: $count kcal';
  }

  @override
  String ageYears(int count) {
    return '$count y.o.';
  }

  @override
  String get recommendedForYou => 'Recommended for you';

  @override
  String get bestMatch => 'Best match';

  @override
  String mealsPerDay(int count) {
    return '$count meals/day';
  }

  @override
  String get matchesYourNorm => 'Matches your norm';

  @override
  String kcalFromNorm(String diff) {
    return '$diff kcal vs your norm';
  }

  @override
  String get perDay => 'day';

  @override
  String get allCompanies => 'All companies';

  @override
  String get from => 'from';

  @override
  String get callDemo => 'Demo: calling is not available yet';

  @override
  String get rations => 'Rations';

  @override
  String get sampleMenu => 'Sample day menu:';

  @override
  String get howManyDays => 'How many days?';

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String orderFor(String sum) {
    return 'Order · $sum';
  }

  @override
  String proteinNeed(int grams, String goal) {
    return 'Your protein need: ~$grams g/day · goal: $goal';
  }

  @override
  String get addedToCart => 'Added to cart';

  @override
  String get addToCart => 'Add to cart';

  @override
  String get cart => 'Cart';

  @override
  String get cartEmpty => 'Your cart is empty';

  @override
  String sportOrderTitle(int count) {
    return 'Sport nutrition · $count items';
  }

  @override
  String get cashOnDelivery => 'Cash';

  @override
  String get checkout => 'Checkout';

  @override
  String get deliveryAddress => 'Delivery address';

  @override
  String get paymentMethod => 'Payment method';

  @override
  String get total => 'Total';

  @override
  String get placeOrder => 'Place order';

  @override
  String get orderPlaced => 'Order placed!';

  @override
  String get orderDemoNote =>
      'This is a demo order. Real delivery and payment will work once partners are connected.';

  @override
  String get todaysMission => 'Today\'s mission';

  @override
  String get startNow => 'Start now';

  @override
  String get missionDone => 'Mission complete!';

  @override
  String get missionDoneHint =>
      'Great job — your streak is safe. Rest and recover.';

  @override
  String get missionRest => 'Rest day';

  @override
  String get missionRestHint =>
      'Recovery is part of training. A light walk counts as a bonus.';

  @override
  String get missionLightRun => 'Light walk or run';

  @override
  String missionStreakAtRisk(int streak, int hours) {
    return 'Your $streak-day streak burns out in $hours h — don\'t lose it!';
  }

  @override
  String missionHoursLeft(int hours) {
    return '$hours h left today. Start your streak now!';
  }

  @override
  String levelShort(int level) {
    return 'Level $level';
  }

  @override
  String weekProgress(int done, int planned) {
    return '$done / $planned done';
  }

  @override
  String get setScheduleCta =>
      'Set a training schedule — we\'ll remind you and won\'t let you skip.';

  @override
  String get achievements => 'Achievements';

  @override
  String get achFirst => 'First workout';

  @override
  String achStreak(int count) {
    return '$count-day streak';
  }

  @override
  String achWorkouts(int count) {
    return '$count workouts';
  }

  @override
  String achKcal(int count) {
    return '$count kcal burned';
  }

  @override
  String achKm(int count) {
    return '$count km run';
  }

  @override
  String achLevel(int count) {
    return 'Reach level $count';
  }

  @override
  String xpToNext(int xp) {
    return '$xp XP to the next level';
  }

  @override
  String get xpHowTo =>
      'Each workout gives 50 XP plus 1 XP for every 5 kcal burned.';

  @override
  String get remindersHint => 'Reminders on your training days';

  @override
  String get trainingDays => 'Training days';

  @override
  String get reminderTime => 'Reminder time';

  @override
  String streakSaverHint(int hour) {
    return 'If you haven\'t trained by $hour:00, we\'ll send one more nudge to save your streak.';
  }

  @override
  String get notificationsDenied =>
      'Notifications are blocked. Allow them in phone settings.';

  @override
  String get reminderTitle => 'Time to train 💪';

  @override
  String get reminderBody =>
      'Today\'s workout is waiting. 20 minutes is enough to keep your streak.';

  @override
  String get streakSaverTitle => 'Your streak is burning out 🔥';

  @override
  String streakSaverBody(int count) {
    return '$count days in a row — don\'t throw it away. Even a short session counts.';
  }

  @override
  String get streakSaverBodyNoStreak =>
      'You haven\'t trained today yet. Start now — even 10 minutes counts.';

  @override
  String get techniqueVideo => 'Technique video';

  @override
  String get techniqueVideos => 'Technique videos';

  @override
  String get techniqueVideosHint =>
      'Wrong form causes injuries. Watch how it\'s done before lifting.';

  @override
  String get compoundLift => 'Compound · multi-joint';

  @override
  String get isolationLift => 'Isolation';

  @override
  String get videoOpenFailed => 'Couldn\'t open the video';

  @override
  String get change => 'Change';

  @override
  String get missionRunHint => 'GPS run — distance and real calories';

  @override
  String missionForDay(String day) {
    return 'Mission for $day';
  }

  @override
  String get missionPickHint =>
      'Choose what you\'ll do on this day every week.';

  @override
  String get missionAuto => 'Automatic';

  @override
  String get missionAutoHint => 'The app picks a workout for you';

  @override
  String get missionBbHint => 'Next day of your program:';

  @override
  String get dayMissions => 'Mission for each day';

  @override
  String get letsStart => 'Let\'s start';

  @override
  String get whyFitBody => 'Why FitBody';

  @override
  String get userGuide => 'User guide';

  @override
  String get openSection => 'Open';

  @override
  String get replayTour => 'Show the intro again';

  @override
  String get noPostsYet => 'No posts yet. Be the first to share your progress!';

  @override
  String get noNotifications => 'No notifications yet';

  @override
  String get navScan => 'AI';

  @override
  String get sectionsTitle => 'Sections';

  @override
  String get sectionRun => 'Run';

  @override
  String get sectionGuide => 'Guide';

  @override
  String get todayTitle => 'Today';

  @override
  String get workoutsTitle => 'Workouts';

  @override
  String get circlesLabel => 'circles';

  @override
  String get stepIntoFrameHead => 'Keep your face and shoulders in the frame';

  @override
  String get hintGetInPlank => 'Get into plank, side-on to the camera';

  @override
  String get hintBiggerCircles => 'Roll your head slowly, in wider circles';

  @override
  String get hintBendForward => 'Fold further forward';

  @override
  String get hintKeepLegsStraight => 'Keep your knees straight';

  @override
  String get placePhoneSide =>
      'Place the phone 2–3 m away, side-on to you — keep your whole body in frame';

  @override
  String get placePhoneFront =>
      'Place the phone 2–3 m away, facing you — keep your whole body in frame';

  @override
  String get browseArticles => 'Browse articles';
}
