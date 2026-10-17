import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('uz'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'FitBody'**
  String get appName;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @onboarding1Title.
  ///
  /// In en, this message translates to:
  /// **'Start your journey towards a more active lifestyle'**
  String get onboarding1Title;

  /// No description provided for @onboarding2Title.
  ///
  /// In en, this message translates to:
  /// **'Find nutrition tips that fit your lifestyle'**
  String get onboarding2Title;

  /// No description provided for @onboarding3Title.
  ///
  /// In en, this message translates to:
  /// **'A community for you, challenge yourself'**
  String get onboarding3Title;

  /// No description provided for @onboardingWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to'**
  String get onboardingWelcome;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to continue your fitness journey'**
  String get loginSubtitle;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @signupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s start your journey'**
  String get signupSubtitle;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @orSignUpWith.
  ///
  /// In en, this message translates to:
  /// **'or sign up with'**
  String get orSignUpWith;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we will send you a code to reset your password'**
  String get forgotPasswordSubtitle;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCode;

  /// No description provided for @codeSent.
  ///
  /// In en, this message translates to:
  /// **'Code sent to your email'**
  String get codeSent;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Required field'**
  String get fieldRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Minimum 6 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get passwordsDontMatch;

  /// No description provided for @setupTitle.
  ///
  /// In en, this message translates to:
  /// **'Consistency is the key to progress. Don\'t give up!'**
  String get setupTitle;

  /// No description provided for @setupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us a bit about yourself so we can build a plan just for you.'**
  String get setupSubtitle;

  /// No description provided for @genderTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s your gender'**
  String get genderTitle;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @ageTitle.
  ///
  /// In en, this message translates to:
  /// **'How old are you?'**
  String get ageTitle;

  /// No description provided for @weightTitle.
  ///
  /// In en, this message translates to:
  /// **'What is your weight?'**
  String get weightTitle;

  /// No description provided for @heightTitle.
  ///
  /// In en, this message translates to:
  /// **'What is your height?'**
  String get heightTitle;

  /// No description provided for @kg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get kg;

  /// No description provided for @cm.
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get cm;

  /// No description provided for @goalTitle.
  ///
  /// In en, this message translates to:
  /// **'What is your goal?'**
  String get goalTitle;

  /// No description provided for @goalLoseWeight.
  ///
  /// In en, this message translates to:
  /// **'Lose weight'**
  String get goalLoseWeight;

  /// No description provided for @goalGainWeight.
  ///
  /// In en, this message translates to:
  /// **'Gain weight'**
  String get goalGainWeight;

  /// No description provided for @goalMuscleMass.
  ///
  /// In en, this message translates to:
  /// **'Muscle mass gain'**
  String get goalMuscleMass;

  /// No description provided for @goalShapeBody.
  ///
  /// In en, this message translates to:
  /// **'Shape body'**
  String get goalShapeBody;

  /// No description provided for @goalOthers.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get goalOthers;

  /// No description provided for @activityTitle.
  ///
  /// In en, this message translates to:
  /// **'Physical activity level'**
  String get activityTitle;

  /// No description provided for @beginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get beginner;

  /// No description provided for @intermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get intermediate;

  /// No description provided for @advanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Fill your profile'**
  String get profileTitle;

  /// No description provided for @nickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get nickname;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get mobileNumber;

  /// No description provided for @hiUser.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}'**
  String hiUser(String name);

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'It\'s time to challenge your limits.'**
  String get homeSubtitle;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabResources.
  ///
  /// In en, this message translates to:
  /// **'Articles'**
  String get tabResources;

  /// No description provided for @tabFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get tabFavorites;

  /// No description provided for @tabSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get tabSupport;

  /// No description provided for @tabShop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get tabShop;

  /// No description provided for @tabSubscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get tabSubscription;

  /// No description provided for @tabNews.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get tabNews;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @workout.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get workout;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get progress;

  /// No description provided for @nutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get nutrition;

  /// No description provided for @community.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get community;

  /// No description provided for @recommendations.
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get recommendations;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @weeklyChallenge.
  ///
  /// In en, this message translates to:
  /// **'Weekly Challenge'**
  String get weeklyChallenge;

  /// No description provided for @articlesTips.
  ///
  /// In en, this message translates to:
  /// **'Articles & Tips'**
  String get articlesTips;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String minutes(int count);

  /// No description provided for @kcal.
  ///
  /// In en, this message translates to:
  /// **'{count} kcal'**
  String kcal(int count);

  /// No description provided for @myRoutines.
  ///
  /// In en, this message translates to:
  /// **'My routines'**
  String get myRoutines;

  /// No description provided for @noRoutinesYet.
  ///
  /// In en, this message translates to:
  /// **'No routines yet'**
  String get noRoutinesYet;

  /// No description provided for @makeYourOwnRoutine.
  ///
  /// In en, this message translates to:
  /// **'Make your own routine'**
  String get makeYourOwnRoutine;

  /// No description provided for @exercisesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 exercise} other{{count} exercises}}'**
  String exercisesCount(int count);

  /// No description provided for @setsReps.
  ///
  /// In en, this message translates to:
  /// **'{sets} × {reps}'**
  String setsReps(int sets, int reps);

  /// No description provided for @setsSeconds.
  ///
  /// In en, this message translates to:
  /// **'{sets} × {seconds}s'**
  String setsSeconds(int sets, int seconds);

  /// No description provided for @startWorkout.
  ///
  /// In en, this message translates to:
  /// **'Start workout'**
  String get startWorkout;

  /// No description provided for @notFound.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get notFound;

  /// No description provided for @routineName.
  ///
  /// In en, this message translates to:
  /// **'Routine name'**
  String get routineName;

  /// No description provided for @chooseExercises.
  ///
  /// In en, this message translates to:
  /// **'Choose exercises'**
  String get chooseExercises;

  /// No description provided for @saveRoutine.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveRoutine;

  /// No description provided for @routineSaved.
  ///
  /// In en, this message translates to:
  /// **'Routine saved'**
  String get routineSaved;

  /// No description provided for @routineIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Enter a name and choose at least one exercise'**
  String get routineIncomplete;

  /// No description provided for @workoutLog.
  ///
  /// In en, this message translates to:
  /// **'Workout Log'**
  String get workoutLog;

  /// No description provided for @progressCharts.
  ///
  /// In en, this message translates to:
  /// **'Progress Charts'**
  String get progressCharts;

  /// No description provided for @workoutsLabel.
  ///
  /// In en, this message translates to:
  /// **'workouts'**
  String get workoutsLabel;

  /// No description provided for @minutesLabel.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutesLabel;

  /// No description provided for @kcalLabel.
  ///
  /// In en, this message translates to:
  /// **'kcal'**
  String get kcalLabel;

  /// No description provided for @weightProgress.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weightProgress;

  /// No description provided for @caloriesBurned.
  ///
  /// In en, this message translates to:
  /// **'Calories burned (7 days)'**
  String get caloriesBurned;

  /// No description provided for @mealPlans.
  ///
  /// In en, this message translates to:
  /// **'Meal Plans'**
  String get mealPlans;

  /// No description provided for @mealIdeas.
  ///
  /// In en, this message translates to:
  /// **'Meal Ideas'**
  String get mealIdeas;

  /// No description provided for @breakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get breakfast;

  /// No description provided for @lunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get lunch;

  /// No description provided for @dinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dinner;

  /// No description provided for @todaysPlan.
  ///
  /// In en, this message translates to:
  /// **'Today\'s plan'**
  String get todaysPlan;

  /// No description provided for @generateWithAi.
  ///
  /// In en, this message translates to:
  /// **'Generate plan with AI'**
  String get generateWithAi;

  /// No description provided for @protein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get protein;

  /// No description provided for @carbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get carbs;

  /// No description provided for @fat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get fat;

  /// No description provided for @ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// No description provided for @discussionForum.
  ///
  /// In en, this message translates to:
  /// **'Discussion forum'**
  String get discussionForum;

  /// No description provided for @challengesCompetitions.
  ///
  /// In en, this message translates to:
  /// **'Challenges & competitions'**
  String get challengesCompetitions;

  /// No description provided for @writePostHint.
  ///
  /// In en, this message translates to:
  /// **'Share something with the community…'**
  String get writePostHint;

  /// No description provided for @publish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publish;

  /// No description provided for @repliesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 reply} other{{count} replies}}'**
  String repliesCount(int count);

  /// No description provided for @participantsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 participant} other{{count} participants}}'**
  String participantsCount(int count);

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day left} other{{count} days left}}'**
  String daysLeft(int count);

  /// No description provided for @join.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// No description provided for @joined.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get joined;

  /// No description provided for @welcomeHeadline.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get to know you'**
  String get welcomeHeadline;

  /// No description provided for @welcomeHighlight.
  ///
  /// In en, this message translates to:
  /// **'better'**
  String get welcomeHighlight;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get your personalized workout and meal plan in just 1 minute to help achieve your fitness goals.'**
  String get welcomeSubtitle;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @getReady.
  ///
  /// In en, this message translates to:
  /// **'Get ready'**
  String get getReady;

  /// No description provided for @readyUser.
  ///
  /// In en, this message translates to:
  /// **'Ready, {name}?'**
  String readyUser(String name);

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @steps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get steps;

  /// No description provided for @dailyProgram.
  ///
  /// In en, this message translates to:
  /// **'Daily Program'**
  String get dailyProgram;

  /// No description provided for @minRead.
  ///
  /// In en, this message translates to:
  /// **'{count} min read'**
  String minRead(int count);

  /// No description provided for @browse.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get browse;

  /// No description provided for @sorting.
  ///
  /// In en, this message translates to:
  /// **'Sorting'**
  String get sorting;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @routineAbout.
  ///
  /// In en, this message translates to:
  /// **'{count} exercises, about {minutes} minutes. Follow the timer and the voice guide — you can pause at any time.'**
  String routineAbout(int count, int minutes);

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @exercisesLabel.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get exercisesLabel;

  /// No description provided for @focusArea.
  ///
  /// In en, this message translates to:
  /// **'Focus area'**
  String get focusArea;

  /// No description provided for @fullBody.
  ///
  /// In en, this message translates to:
  /// **'Full body'**
  String get fullBody;

  /// No description provided for @voiceGuide.
  ///
  /// In en, this message translates to:
  /// **'Voice guide'**
  String get voiceGuide;

  /// No description provided for @secondsLabel.
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get secondsLabel;

  /// No description provided for @repsLabel.
  ///
  /// In en, this message translates to:
  /// **'reps'**
  String get repsLabel;

  /// No description provided for @setOf.
  ///
  /// In en, this message translates to:
  /// **'{count} sets'**
  String setOf(int count);

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @congratulation.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get congratulation;

  /// No description provided for @workoutCompleted.
  ///
  /// In en, this message translates to:
  /// **'You have completed “{title}”. Great job, keep it up!'**
  String workoutCompleted(String title);

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calories;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @ofKcal.
  ///
  /// In en, this message translates to:
  /// **'of {count} kcal'**
  String ofKcal(int count);

  /// No description provided for @dailyMeal.
  ///
  /// In en, this message translates to:
  /// **'Daily meal'**
  String get dailyMeal;

  /// No description provided for @editPlan.
  ///
  /// In en, this message translates to:
  /// **'Edit plan'**
  String get editPlan;

  /// No description provided for @customizePlanHint.
  ///
  /// In en, this message translates to:
  /// **'It\'s time to customize your meal plan and recipes.'**
  String get customizePlanHint;

  /// No description provided for @workoutVideos.
  ///
  /// In en, this message translates to:
  /// **'Workout Videos'**
  String get workoutVideos;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @video.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get video;

  /// No description provided for @article.
  ///
  /// In en, this message translates to:
  /// **'Article'**
  String get article;

  /// No description provided for @noFavorites.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet — tap ♡ to save'**
  String get noFavorites;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @onlineSupport.
  ///
  /// In en, this message translates to:
  /// **'Online Support'**
  String get onlineSupport;

  /// No description provided for @faq1Q.
  ///
  /// In en, this message translates to:
  /// **'How is my workout plan created?'**
  String get faq1Q;

  /// No description provided for @faq1A.
  ///
  /// In en, this message translates to:
  /// **'Your plan is based on your goal, level and body data from the setup. You can change them any time in Edit Profile.'**
  String get faq1A;

  /// No description provided for @faq2Q.
  ///
  /// In en, this message translates to:
  /// **'Can I use the app without equipment?'**
  String get faq2Q;

  /// No description provided for @faq2A.
  ///
  /// In en, this message translates to:
  /// **'Yes. Most routines are bodyweight only; equipment is listed in the routine details.'**
  String get faq2A;

  /// No description provided for @faq3Q.
  ///
  /// In en, this message translates to:
  /// **'How do I change the language?'**
  String get faq3Q;

  /// No description provided for @faq3A.
  ///
  /// In en, this message translates to:
  /// **'Tap the globe icon at the top or open Profile → Settings → Language.'**
  String get faq3A;

  /// No description provided for @faq4Q.
  ///
  /// In en, this message translates to:
  /// **'Is my data safe?'**
  String get faq4Q;

  /// No description provided for @faq4A.
  ///
  /// In en, this message translates to:
  /// **'Your data is stored securely and is never shared with third parties without your consent.'**
  String get faq4A;

  /// No description provided for @supportGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi! 👋 I\'m your FitBody assistant. Ask me anything about workouts or nutrition.'**
  String get supportGreeting;

  /// No description provided for @supportAutoReply.
  ///
  /// In en, this message translates to:
  /// **'Thanks! The AI coach is coming soon — for now our team will answer you here shortly.'**
  String get supportAutoReply;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message…'**
  String get typeMessage;

  /// No description provided for @logOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logOutConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get profile;

  /// No description provided for @ageLabel.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get ageLabel;

  /// No description provided for @heightLabel.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get heightLabel;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @workoutReminders.
  ///
  /// In en, this message translates to:
  /// **'Workout Reminders'**
  String get workoutReminders;

  /// No description provided for @systemNotifications.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemNotifications;

  /// No description provided for @notifReminder1.
  ///
  /// In en, this message translates to:
  /// **'Time for your morning stretch — 10 minutes is enough!'**
  String get notifReminder1;

  /// No description provided for @notifReminder2.
  ///
  /// In en, this message translates to:
  /// **'Drink a glass of water 💧'**
  String get notifReminder2;

  /// No description provided for @notifReminder3.
  ///
  /// In en, this message translates to:
  /// **'Evening walk: 3,000 steps left to reach your goal.'**
  String get notifReminder3;

  /// No description provided for @notifSystem1.
  ///
  /// In en, this message translates to:
  /// **'New weekly challenge: Plank With Hip Twist'**
  String get notifSystem1;

  /// No description provided for @notifSystem2.
  ///
  /// In en, this message translates to:
  /// **'App updated: new voice guide for workouts'**
  String get notifSystem2;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Workouts, meals…'**
  String get searchHint;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get noResults;

  /// No description provided for @ttsExerciseReps.
  ///
  /// In en, this message translates to:
  /// **'{name}. {count} reps.'**
  String ttsExerciseReps(String name, int count);

  /// No description provided for @ttsExerciseTimed.
  ///
  /// In en, this message translates to:
  /// **'{name}. {count} seconds.'**
  String ttsExerciseTimed(String name, int count);

  /// No description provided for @ttsFinished.
  ///
  /// In en, this message translates to:
  /// **'Workout complete. Great job!'**
  String get ttsFinished;

  /// No description provided for @ttsGreatJob.
  ///
  /// In en, this message translates to:
  /// **'Great job! Target reached.'**
  String get ttsGreatJob;

  /// No description provided for @aiFormCheck.
  ///
  /// In en, this message translates to:
  /// **'AI form check'**
  String get aiFormCheck;

  /// No description provided for @cameraUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Camera is not available. Allow camera access in the phone settings and try again.'**
  String get cameraUnavailable;

  /// No description provided for @stepIntoFrame.
  ///
  /// In en, this message translates to:
  /// **'Step back so your whole body is in the frame'**
  String get stepIntoFrame;

  /// No description provided for @hintGoLower.
  ///
  /// In en, this message translates to:
  /// **'Go lower'**
  String get hintGoLower;

  /// No description provided for @hintKeepStraight.
  ///
  /// In en, this message translates to:
  /// **'Keep your body straight'**
  String get hintKeepStraight;

  /// No description provided for @hintGood.
  ///
  /// In en, this message translates to:
  /// **'Good form!'**
  String get hintGood;

  /// No description provided for @profilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get profilePhoto;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhoto;

  /// No description provided for @weeklyGoal.
  ///
  /// In en, this message translates to:
  /// **'weekly goal'**
  String get weeklyGoal;

  /// No description provided for @kcalThisWeek.
  ///
  /// In en, this message translates to:
  /// **'kcal burned this week'**
  String get kcalThisWeek;

  /// No description provided for @workoutsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 workout} other{{count} workouts}}'**
  String workoutsCount(int count);

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No streak yet} =1{1 day streak} other{{count} day streak}}'**
  String streakDays(int count);

  /// No description provided for @dailyCalories.
  ///
  /// In en, this message translates to:
  /// **'Daily calories'**
  String get dailyCalories;

  /// No description provided for @avgPerActiveDay.
  ///
  /// In en, this message translates to:
  /// **'avg {count} kcal per active day'**
  String avgPerActiveDay(int count);

  /// No description provided for @dailyGoalLabel.
  ///
  /// In en, this message translates to:
  /// **'goal'**
  String get dailyGoalLabel;

  /// No description provided for @activityCalendar.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activityCalendar;

  /// No description provided for @activeDaysOf.
  ///
  /// In en, this message translates to:
  /// **'{count} active days of {total}'**
  String activeDaysOf(int count, int total);

  /// No description provided for @less.
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get less;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @weeklyActivity.
  ///
  /// In en, this message translates to:
  /// **'Weekly activity'**
  String get weeklyActivity;

  /// No description provided for @minutesPerWeek.
  ///
  /// In en, this message translates to:
  /// **'minutes of training per week'**
  String get minutesPerWeek;

  /// No description provided for @thisWeekShort.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get thisWeekShort;

  /// No description provided for @sinceDate.
  ///
  /// In en, this message translates to:
  /// **'since {date}'**
  String sinceDate(String date);

  /// No description provided for @addWeightHint.
  ///
  /// In en, this message translates to:
  /// **'Add your weight regularly to see the trend.'**
  String get addWeightHint;

  /// No description provided for @addWeight.
  ///
  /// In en, this message translates to:
  /// **'Add weight'**
  String get addWeight;

  /// No description provided for @byLevel.
  ///
  /// In en, this message translates to:
  /// **'By level'**
  String get byLevel;

  /// No description provided for @totalWorkouts.
  ///
  /// In en, this message translates to:
  /// **'workouts in total'**
  String get totalWorkouts;

  /// No description provided for @totalKcal.
  ///
  /// In en, this message translates to:
  /// **'kcal in total'**
  String get totalKcal;

  /// No description provided for @noWorkoutsYet.
  ///
  /// In en, this message translates to:
  /// **'No workouts yet. Finish your first workout and it will appear here.'**
  String get noWorkoutsYet;

  /// No description provided for @startFirstWorkout.
  ///
  /// In en, this message translates to:
  /// **'Start a workout'**
  String get startFirstWorkout;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @streakLabel.
  ///
  /// In en, this message translates to:
  /// **'day streak'**
  String get streakLabel;

  /// No description provided for @clearData.
  ///
  /// In en, this message translates to:
  /// **'Clear statistics'**
  String get clearData;

  /// No description provided for @clearDataHint.
  ///
  /// In en, this message translates to:
  /// **'Workout log and weight history (incl. test data)'**
  String get clearDataHint;

  /// No description provided for @clearDataConfirm.
  ///
  /// In en, this message translates to:
  /// **'All workouts and weight history will be deleted. This cannot be undone.'**
  String get clearDataConfirm;

  /// No description provided for @dataCleared.
  ///
  /// In en, this message translates to:
  /// **'Statistics cleared'**
  String get dataCleared;

  /// No description provided for @aiFoodScan.
  ///
  /// In en, this message translates to:
  /// **'AI food scan'**
  String get aiFoodScan;

  /// No description provided for @whatAreYouEating.
  ///
  /// In en, this message translates to:
  /// **'What are you eating?'**
  String get whatAreYouEating;

  /// No description provided for @placeFoodInFrame.
  ///
  /// In en, this message translates to:
  /// **'Place the food inside the frame'**
  String get placeFoodInFrame;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @manualEntry.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get manualEntry;

  /// No description provided for @aiAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'AI is analyzing your food'**
  String get aiAnalyzing;

  /// No description provided for @demoResult.
  ///
  /// In en, this message translates to:
  /// **'Demo result — AI server not connected yet'**
  String get demoResult;

  /// No description provided for @aiConfidence.
  ///
  /// In en, this message translates to:
  /// **'AI confidence {count}%'**
  String aiConfidence(int count);

  /// No description provided for @portion.
  ///
  /// In en, this message translates to:
  /// **'Portion'**
  String get portion;

  /// No description provided for @retake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get retake;

  /// No description provided for @addToDiary.
  ///
  /// In en, this message translates to:
  /// **'Add to diary'**
  String get addToDiary;

  /// No description provided for @foodAdded.
  ///
  /// In en, this message translates to:
  /// **'Added: {count} kcal'**
  String foodAdded(int count);

  /// No description provided for @snack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get snack;

  /// No description provided for @foodName.
  ///
  /// In en, this message translates to:
  /// **'Food name'**
  String get foodName;

  /// No description provided for @eatenToday.
  ///
  /// In en, this message translates to:
  /// **'Eaten today'**
  String get eatenToday;

  /// No description provided for @addFood.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addFood;

  /// No description provided for @noFoodToday.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged yet today. Tap + and point the camera at your meal.'**
  String get noFoodToday;

  /// No description provided for @activityRun.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get activityRun;

  /// No description provided for @activityWalk.
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get activityWalk;

  /// No description provided for @activityBike.
  ///
  /// In en, this message translates to:
  /// **'Cycling'**
  String get activityBike;

  /// No description provided for @runMode.
  ///
  /// In en, this message translates to:
  /// **'Run mode'**
  String get runMode;

  /// No description provided for @gpsSearching.
  ///
  /// In en, this message translates to:
  /// **'Searching for GPS…'**
  String get gpsSearching;

  /// No description provided for @gpsReady.
  ///
  /// In en, this message translates to:
  /// **'GPS ready · ±{count} m'**
  String gpsReady(int count);

  /// No description provided for @gpsOff.
  ///
  /// In en, this message translates to:
  /// **'Location is turned off'**
  String get gpsOff;

  /// No description provided for @locationDenied.
  ///
  /// In en, this message translates to:
  /// **'No location permission'**
  String get locationDenied;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @runHint.
  ///
  /// In en, this message translates to:
  /// **'Calories are counted in real time from your speed and weight.'**
  String get runHint;

  /// No description provided for @runNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout in progress'**
  String get runNotificationTitle;

  /// No description provided for @runNotificationText.
  ///
  /// In en, this message translates to:
  /// **'Tracking distance and calories'**
  String get runNotificationText;

  /// No description provided for @ttsRunStart.
  ///
  /// In en, this message translates to:
  /// **'Go!'**
  String get ttsRunStart;

  /// No description provided for @ttsRunDone.
  ///
  /// In en, this message translates to:
  /// **'Workout finished. {distance} kilometres, {kcal} calories.'**
  String ttsRunDone(String distance, int kcal);

  /// No description provided for @ttsRunKm.
  ///
  /// In en, this message translates to:
  /// **'{km} kilometres. Average pace {pace}. {kcal} calories.'**
  String ttsRunKm(int km, String pace, int kcal);

  /// No description provided for @runLogTitle.
  ///
  /// In en, this message translates to:
  /// **'{activity} · {distance} km'**
  String runLogTitle(String activity, String distance);

  /// No description provided for @live.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get live;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @holdToStop.
  ///
  /// In en, this message translates to:
  /// **'Hold to stop'**
  String get holdToStop;

  /// No description provided for @kcalBurned.
  ///
  /// In en, this message translates to:
  /// **'kcal burned'**
  String get kcalBurned;

  /// No description provided for @km.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get km;

  /// No description provided for @minPerKm.
  ///
  /// In en, this message translates to:
  /// **'/km'**
  String get minPerKm;

  /// No description provided for @kmh.
  ///
  /// In en, this message translates to:
  /// **'km/h'**
  String get kmh;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @pace.
  ///
  /// In en, this message translates to:
  /// **'Pace'**
  String get pace;

  /// No description provided for @speed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speed;

  /// No description provided for @runSummary.
  ///
  /// In en, this message translates to:
  /// **'Great job!'**
  String get runSummary;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get duration;

  /// No description provided for @avgPace.
  ///
  /// In en, this message translates to:
  /// **'Avg pace'**
  String get avgPace;

  /// No description provided for @splits.
  ///
  /// In en, this message translates to:
  /// **'Splits'**
  String get splits;

  /// No description provided for @kmSplit.
  ///
  /// In en, this message translates to:
  /// **'{count} km'**
  String kmSplit(int count);

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @eatenLabel.
  ///
  /// In en, this message translates to:
  /// **'eaten'**
  String get eatenLabel;

  /// No description provided for @burnedLabel.
  ///
  /// In en, this message translates to:
  /// **'burned'**
  String get burnedLabel;

  /// No description provided for @remainingLabel.
  ///
  /// In en, this message translates to:
  /// **'left'**
  String get remainingLabel;

  /// No description provided for @overLabel.
  ///
  /// In en, this message translates to:
  /// **'over'**
  String get overLabel;

  /// No description provided for @runCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'GPS · real-time calories · tap to start'**
  String get runCardSubtitle;

  /// No description provided for @friend.
  ///
  /// In en, this message translates to:
  /// **'Friend'**
  String get friend;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @macrosShort.
  ///
  /// In en, this message translates to:
  /// **'P {protein} · C {carbs} · F {fat}'**
  String macrosShort(int protein, int carbs, int fat);

  /// No description provided for @todaysWorkout.
  ///
  /// In en, this message translates to:
  /// **'Today\'s workout'**
  String get todaysWorkout;

  /// No description provided for @devicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Watch & devices'**
  String get devicesTitle;

  /// No description provided for @devicesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Steps, heart rate, sleep and calories from your watch — via Health Connect.'**
  String get devicesSubtitle;

  /// No description provided for @devicesSettingsHint.
  ///
  /// In en, this message translates to:
  /// **'Galaxy Watch, Mi Band, Garmin, Apple Watch…'**
  String get devicesSettingsHint;

  /// No description provided for @connectYourWatch.
  ///
  /// In en, this message translates to:
  /// **'Connect your watch'**
  String get connectYourWatch;

  /// No description provided for @watchConnected.
  ///
  /// In en, this message translates to:
  /// **'Watch connected'**
  String get watchConnected;

  /// No description provided for @connectWatch.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connectWatch;

  /// No description provided for @healthWhatWeRead.
  ///
  /// In en, this message translates to:
  /// **'What the app will read:'**
  String get healthWhatWeRead;

  /// No description provided for @heartRate.
  ///
  /// In en, this message translates to:
  /// **'Heart rate'**
  String get heartRate;

  /// No description provided for @restingHeartRate.
  ///
  /// In en, this message translates to:
  /// **'Resting pulse'**
  String get restingHeartRate;

  /// No description provided for @sleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleep;

  /// No description provided for @activeCalories.
  ///
  /// In en, this message translates to:
  /// **'Active calories'**
  String get activeCalories;

  /// No description provided for @healthReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Read only. The app never changes your health data.'**
  String get healthReadOnly;

  /// No description provided for @healthDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission not granted. You can allow it in Health Connect.'**
  String get healthDenied;

  /// No description provided for @healthUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Health Connect is not available on this device.'**
  String get healthUnsupported;

  /// No description provided for @healthNeedsInstall.
  ///
  /// In en, this message translates to:
  /// **'Install or update Health Connect to connect your watch.'**
  String get healthNeedsInstall;

  /// No description provided for @installHealthConnect.
  ///
  /// In en, this message translates to:
  /// **'Install Health Connect'**
  String get installHealthConnect;

  /// No description provided for @healthNoData.
  ///
  /// In en, this message translates to:
  /// **'No data yet. Make sure your watch app shares data with Health Connect.'**
  String get healthNoData;

  /// No description provided for @samsungHealthHint.
  ///
  /// In en, this message translates to:
  /// **'Samsung: open Samsung Health → Settings → Health Connect and turn on data sharing.'**
  String get samsungHealthHint;

  /// No description provided for @syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get syncing;

  /// No description provided for @lastSync.
  ///
  /// In en, this message translates to:
  /// **'Updated at {time}'**
  String lastSync(String time);

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// No description provided for @bpm.
  ///
  /// In en, this message translates to:
  /// **'bpm'**
  String get bpm;

  /// No description provided for @hoursShort.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get hoursShort;

  /// No description provided for @fromYourWatch.
  ///
  /// In en, this message translates to:
  /// **'From your watch'**
  String get fromYourWatch;

  /// No description provided for @sleepDuration.
  ///
  /// In en, this message translates to:
  /// **'{h}h {m}m'**
  String sleepDuration(int h, int m);

  /// No description provided for @bodybuilding.
  ///
  /// In en, this message translates to:
  /// **'Bodybuilding'**
  String get bodybuilding;

  /// No description provided for @bodybuildingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Splits · weights · progressive overload · PRs'**
  String get bodybuildingSubtitle;

  /// No description provided for @nextSession.
  ///
  /// In en, this message translates to:
  /// **'Next session'**
  String get nextSession;

  /// No description provided for @startSession.
  ///
  /// In en, this message translates to:
  /// **'Start session'**
  String get startSession;

  /// No description provided for @setsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 set} other{{count} sets}}'**
  String setsCount(int count);

  /// No description provided for @personalRecords.
  ///
  /// In en, this message translates to:
  /// **'Personal records'**
  String get personalRecords;

  /// No description provided for @weeklySetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly volume by muscle'**
  String get weeklySetsTitle;

  /// No description provided for @weeklySetsHint.
  ///
  /// In en, this message translates to:
  /// **'Working sets in the last 7 days · 10–20 is optimal for growth'**
  String get weeklySetsHint;

  /// No description provided for @programs.
  ///
  /// In en, this message translates to:
  /// **'Programs'**
  String get programs;

  /// No description provided for @daysPerWeek.
  ///
  /// In en, this message translates to:
  /// **'{count} days / week'**
  String daysPerWeek(int count);

  /// No description provided for @recentSessions.
  ///
  /// In en, this message translates to:
  /// **'Recent sessions'**
  String get recentSessions;

  /// No description provided for @noSessionsYet.
  ///
  /// In en, this message translates to:
  /// **'No sessions yet — start your first one above.'**
  String get noSessionsYet;

  /// No description provided for @tonnes.
  ///
  /// In en, this message translates to:
  /// **'t'**
  String get tonnes;

  /// No description provided for @noSetsDone.
  ///
  /// In en, this message translates to:
  /// **'Mark at least one set as done ✓'**
  String get noSetsDone;

  /// No description provided for @sessionDone.
  ///
  /// In en, this message translates to:
  /// **'Session complete!'**
  String get sessionDone;

  /// No description provided for @setsLabel.
  ///
  /// In en, this message translates to:
  /// **'sets'**
  String get setsLabel;

  /// No description provided for @newPr.
  ///
  /// In en, this message translates to:
  /// **'New PR'**
  String get newPr;

  /// No description provided for @leaveSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave the session?'**
  String get leaveSessionTitle;

  /// No description provided for @leaveSessionText.
  ///
  /// In en, this message translates to:
  /// **'Completed sets will not be saved.'**
  String get leaveSessionText;

  /// No description provided for @finishSession.
  ///
  /// In en, this message translates to:
  /// **'Finish session'**
  String get finishSession;

  /// No description provided for @restSec.
  ///
  /// In en, this message translates to:
  /// **'rest {count}s'**
  String restSec(int count);

  /// No description provided for @lastTime.
  ///
  /// In en, this message translates to:
  /// **'Last time'**
  String get lastTime;

  /// No description provided for @setCol.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get setCol;

  /// No description provided for @repsCol.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get repsCol;

  /// No description provided for @addSet.
  ///
  /// In en, this message translates to:
  /// **'Add set'**
  String get addSet;

  /// No description provided for @restTimer.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get restTimer;

  /// No description provided for @market.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get market;

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'My orders'**
  String get myOrders;

  /// No description provided for @noOrdersYet.
  ///
  /// In en, this message translates to:
  /// **'No orders yet.'**
  String get noOrdersYet;

  /// No description provided for @orderStatusDemo.
  ///
  /// In en, this message translates to:
  /// **'demo order'**
  String get orderStatusDemo;

  /// No description provided for @mealDelivery.
  ///
  /// In en, this message translates to:
  /// **'Meal delivery'**
  String get mealDelivery;

  /// No description provided for @sportNutrition.
  ///
  /// In en, this message translates to:
  /// **'Sport nutrition'**
  String get sportNutrition;

  /// No description provided for @marketDemoNote.
  ///
  /// In en, this message translates to:
  /// **'Demo: products and meal programs are examples, orders are not sent anywhere.'**
  String get marketDemoNote;

  /// No description provided for @yourDailyNorm.
  ///
  /// In en, this message translates to:
  /// **'Your daily norm: {count} kcal'**
  String yourDailyNorm(int count);

  /// No description provided for @ageYears.
  ///
  /// In en, this message translates to:
  /// **'{count} y.o.'**
  String ageYears(int count);

  /// No description provided for @recommendedForYou.
  ///
  /// In en, this message translates to:
  /// **'Recommended for you'**
  String get recommendedForYou;

  /// No description provided for @bestMatch.
  ///
  /// In en, this message translates to:
  /// **'Best match'**
  String get bestMatch;

  /// No description provided for @mealsPerDay.
  ///
  /// In en, this message translates to:
  /// **'{count} meals/day'**
  String mealsPerDay(int count);

  /// No description provided for @matchesYourNorm.
  ///
  /// In en, this message translates to:
  /// **'Matches your norm'**
  String get matchesYourNorm;

  /// No description provided for @kcalFromNorm.
  ///
  /// In en, this message translates to:
  /// **'{diff} kcal vs your norm'**
  String kcalFromNorm(String diff);

  /// No description provided for @perDay.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get perDay;

  /// No description provided for @allCompanies.
  ///
  /// In en, this message translates to:
  /// **'All companies'**
  String get allCompanies;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'from'**
  String get from;

  /// No description provided for @callDemo.
  ///
  /// In en, this message translates to:
  /// **'Demo: calling is not available yet'**
  String get callDemo;

  /// No description provided for @rations.
  ///
  /// In en, this message translates to:
  /// **'Rations'**
  String get rations;

  /// No description provided for @sampleMenu.
  ///
  /// In en, this message translates to:
  /// **'Sample day menu:'**
  String get sampleMenu;

  /// No description provided for @howManyDays.
  ///
  /// In en, this message translates to:
  /// **'How many days?'**
  String get howManyDays;

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String daysCount(int count);

  /// No description provided for @orderFor.
  ///
  /// In en, this message translates to:
  /// **'Order · {sum}'**
  String orderFor(String sum);

  /// No description provided for @proteinNeed.
  ///
  /// In en, this message translates to:
  /// **'Your protein need: ~{grams} g/day · goal: {goal}'**
  String proteinNeed(int grams, String goal);

  /// No description provided for @addedToCart.
  ///
  /// In en, this message translates to:
  /// **'Added to cart'**
  String get addedToCart;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get addToCart;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @cartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmpty;

  /// No description provided for @sportOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Sport nutrition · {count} items'**
  String sportOrderTitle(int count);

  /// No description provided for @cashOnDelivery.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cashOnDelivery;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @deliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivery address'**
  String get deliveryAddress;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get paymentMethod;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'Place order'**
  String get placeOrder;

  /// No description provided for @orderPlaced.
  ///
  /// In en, this message translates to:
  /// **'Order placed!'**
  String get orderPlaced;

  /// No description provided for @orderDemoNote.
  ///
  /// In en, this message translates to:
  /// **'This is a demo order. Real delivery and payment will work once partners are connected.'**
  String get orderDemoNote;

  /// No description provided for @todaysMission.
  ///
  /// In en, this message translates to:
  /// **'Today\'s mission'**
  String get todaysMission;

  /// No description provided for @startNow.
  ///
  /// In en, this message translates to:
  /// **'Start now'**
  String get startNow;

  /// No description provided for @missionDone.
  ///
  /// In en, this message translates to:
  /// **'Mission complete!'**
  String get missionDone;

  /// No description provided for @missionDoneHint.
  ///
  /// In en, this message translates to:
  /// **'Great job — your streak is safe. Rest and recover.'**
  String get missionDoneHint;

  /// No description provided for @missionRest.
  ///
  /// In en, this message translates to:
  /// **'Rest day'**
  String get missionRest;

  /// No description provided for @missionRestHint.
  ///
  /// In en, this message translates to:
  /// **'Recovery is part of training. A light walk counts as a bonus.'**
  String get missionRestHint;

  /// No description provided for @missionLightRun.
  ///
  /// In en, this message translates to:
  /// **'Light walk or run'**
  String get missionLightRun;

  /// No description provided for @missionStreakAtRisk.
  ///
  /// In en, this message translates to:
  /// **'Your {streak}-day streak burns out in {hours} h — don\'t lose it!'**
  String missionStreakAtRisk(int streak, int hours);

  /// No description provided for @missionHoursLeft.
  ///
  /// In en, this message translates to:
  /// **'{hours} h left today. Start your streak now!'**
  String missionHoursLeft(int hours);

  /// No description provided for @levelShort.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String levelShort(int level);

  /// No description provided for @weekProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} / {planned} done'**
  String weekProgress(int done, int planned);

  /// No description provided for @setScheduleCta.
  ///
  /// In en, this message translates to:
  /// **'Set a training schedule — we\'ll remind you and won\'t let you skip.'**
  String get setScheduleCta;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @achFirst.
  ///
  /// In en, this message translates to:
  /// **'First workout'**
  String get achFirst;

  /// No description provided for @achStreak.
  ///
  /// In en, this message translates to:
  /// **'{count}-day streak'**
  String achStreak(int count);

  /// No description provided for @achWorkouts.
  ///
  /// In en, this message translates to:
  /// **'{count} workouts'**
  String achWorkouts(int count);

  /// No description provided for @achKcal.
  ///
  /// In en, this message translates to:
  /// **'{count} kcal burned'**
  String achKcal(int count);

  /// No description provided for @achKm.
  ///
  /// In en, this message translates to:
  /// **'{count} km run'**
  String achKm(int count);

  /// No description provided for @achLevel.
  ///
  /// In en, this message translates to:
  /// **'Reach level {count}'**
  String achLevel(int count);

  /// No description provided for @xpToNext.
  ///
  /// In en, this message translates to:
  /// **'{xp} XP to the next level'**
  String xpToNext(int xp);

  /// No description provided for @xpHowTo.
  ///
  /// In en, this message translates to:
  /// **'Each workout gives 50 XP plus 1 XP for every 5 kcal burned.'**
  String get xpHowTo;

  /// No description provided for @remindersHint.
  ///
  /// In en, this message translates to:
  /// **'Reminders on your training days'**
  String get remindersHint;

  /// No description provided for @trainingDays.
  ///
  /// In en, this message translates to:
  /// **'Training days'**
  String get trainingDays;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get reminderTime;

  /// No description provided for @streakSaverHint.
  ///
  /// In en, this message translates to:
  /// **'If you haven\'t trained by {hour}:00, we\'ll send one more nudge to save your streak.'**
  String streakSaverHint(int hour);

  /// No description provided for @notificationsDenied.
  ///
  /// In en, this message translates to:
  /// **'Notifications are blocked. Allow them in phone settings.'**
  String get notificationsDenied;

  /// No description provided for @reminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Time to train 💪'**
  String get reminderTitle;

  /// No description provided for @reminderBody.
  ///
  /// In en, this message translates to:
  /// **'Today\'s workout is waiting. 20 minutes is enough to keep your streak.'**
  String get reminderBody;

  /// No description provided for @streakSaverTitle.
  ///
  /// In en, this message translates to:
  /// **'Your streak is burning out 🔥'**
  String get streakSaverTitle;

  /// No description provided for @streakSaverBody.
  ///
  /// In en, this message translates to:
  /// **'{count} days in a row — don\'t throw it away. Even a short session counts.'**
  String streakSaverBody(int count);

  /// No description provided for @streakSaverBodyNoStreak.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t trained today yet. Start now — even 10 minutes counts.'**
  String get streakSaverBodyNoStreak;

  /// No description provided for @techniqueVideo.
  ///
  /// In en, this message translates to:
  /// **'Technique video'**
  String get techniqueVideo;

  /// No description provided for @techniqueVideos.
  ///
  /// In en, this message translates to:
  /// **'Technique videos'**
  String get techniqueVideos;

  /// No description provided for @techniqueVideosHint.
  ///
  /// In en, this message translates to:
  /// **'Wrong form causes injuries. Watch how it\'s done before lifting.'**
  String get techniqueVideosHint;

  /// No description provided for @compoundLift.
  ///
  /// In en, this message translates to:
  /// **'Compound · multi-joint'**
  String get compoundLift;

  /// No description provided for @isolationLift.
  ///
  /// In en, this message translates to:
  /// **'Isolation'**
  String get isolationLift;

  /// No description provided for @videoOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the video'**
  String get videoOpenFailed;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @missionRunHint.
  ///
  /// In en, this message translates to:
  /// **'GPS run — distance and real calories'**
  String get missionRunHint;

  /// No description provided for @missionForDay.
  ///
  /// In en, this message translates to:
  /// **'Mission for {day}'**
  String missionForDay(String day);

  /// No description provided for @missionPickHint.
  ///
  /// In en, this message translates to:
  /// **'Choose what you\'ll do on this day every week.'**
  String get missionPickHint;

  /// No description provided for @missionAuto.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get missionAuto;

  /// No description provided for @missionAutoHint.
  ///
  /// In en, this message translates to:
  /// **'The app picks a workout for you'**
  String get missionAutoHint;

  /// No description provided for @missionBbHint.
  ///
  /// In en, this message translates to:
  /// **'Next day of your program:'**
  String get missionBbHint;

  /// No description provided for @dayMissions.
  ///
  /// In en, this message translates to:
  /// **'Mission for each day'**
  String get dayMissions;

  /// No description provided for @letsStart.
  ///
  /// In en, this message translates to:
  /// **'Let\'s start'**
  String get letsStart;

  /// No description provided for @whyFitBody.
  ///
  /// In en, this message translates to:
  /// **'Why FitBody'**
  String get whyFitBody;

  /// No description provided for @userGuide.
  ///
  /// In en, this message translates to:
  /// **'User guide'**
  String get userGuide;

  /// No description provided for @openSection.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openSection;

  /// No description provided for @replayTour.
  ///
  /// In en, this message translates to:
  /// **'Show the intro again'**
  String get replayTour;

  /// No description provided for @noPostsYet.
  ///
  /// In en, this message translates to:
  /// **'No posts yet. Be the first to share your progress!'**
  String get noPostsYet;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotifications;

  /// No description provided for @navScan.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get navScan;

  /// No description provided for @sectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Sections'**
  String get sectionsTitle;

  /// No description provided for @sectionRun.
  ///
  /// In en, this message translates to:
  /// **'Run'**
  String get sectionRun;

  /// No description provided for @sectionGuide.
  ///
  /// In en, this message translates to:
  /// **'Guide'**
  String get sectionGuide;

  /// No description provided for @todayTitle.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayTitle;

  /// No description provided for @workoutsTitle.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get workoutsTitle;

  /// No description provided for @circlesLabel.
  ///
  /// In en, this message translates to:
  /// **'circles'**
  String get circlesLabel;

  /// No description provided for @stepIntoFrameHead.
  ///
  /// In en, this message translates to:
  /// **'Keep your face and shoulders in the frame'**
  String get stepIntoFrameHead;

  /// No description provided for @hintGetInPlank.
  ///
  /// In en, this message translates to:
  /// **'Get into plank, side-on to the camera'**
  String get hintGetInPlank;

  /// No description provided for @hintBiggerCircles.
  ///
  /// In en, this message translates to:
  /// **'Roll your head slowly, in wider circles'**
  String get hintBiggerCircles;

  /// No description provided for @hintBendForward.
  ///
  /// In en, this message translates to:
  /// **'Fold further forward'**
  String get hintBendForward;

  /// No description provided for @hintKeepLegsStraight.
  ///
  /// In en, this message translates to:
  /// **'Keep your knees straight'**
  String get hintKeepLegsStraight;

  /// No description provided for @placePhoneSide.
  ///
  /// In en, this message translates to:
  /// **'Place the phone 2–3 m away, side-on to you — keep your whole body in frame'**
  String get placePhoneSide;

  /// No description provided for @placePhoneFront.
  ///
  /// In en, this message translates to:
  /// **'Place the phone 2–3 m away, facing you — keep your whole body in frame'**
  String get placePhoneFront;

  /// No description provided for @browseArticles.
  ///
  /// In en, this message translates to:
  /// **'Browse articles'**
  String get browseArticles;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
