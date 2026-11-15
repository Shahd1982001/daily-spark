import 'package:flutter/material.dart';

/// gettext-style translations: the English source string is the lookup key.
///
/// `tr()` falls back to the key (English) when a language has no entry yet,
/// so languages can be added one map at a time without breaking anything.
/// Display strings flow through `figmaText`, which calls `tr` internally —
/// data (habit titles, names) is never translated.
class Strings {
  Strings._();

  /// The active locale — kept in sync by the app root, like `SparkPalette`.
  static Locale locale = const Locale('en');

  static bool get isRtl => locale.languageCode == 'ar';

  /// Language codes that currently have translations.
  static List<String> get available => _maps.keys.toList()..insert(0, 'en');

  static String tr(String key, [Map<String, String>? args]) {
    var s = _maps[locale.languageCode]?[key] ?? key;
    if (args != null) {
      args.forEach((k, v) => s = s.replaceAll('{$k}', v));
    }
    return s;
  }

  static const _maps = <String, Map<String, String>>{
    'ar': _ar,
  };

  // ── العربية ────────────────────────────────────────────────────────────────
  static const _ar = <String, String>{
    // generic
    'Home': 'الرئيسية',
    'Habits': 'العادات',
    'Progress': 'التقدّم',
    'Profile': 'الملف الشخصي',
    'HABITS': 'العادات',
    'DAILY SPARK': 'دايلي سبارك',
    'Daily Spark': 'دايلي سبارك',
    'spark': 'سبارك',
    'Close': 'إغلاق',
    'Save': 'حفظ',
    'Skip': 'تخطّي',
    'Log In': 'تسجيل الدخول',
    'Sign Up': 'إنشاء حساب',
    'Continue as Guest': 'المتابعة كضيف',
    'Explore as Guest': 'استكشف كضيف',
    'Create Account': 'إنشاء حساب',
    'Create your account.': 'أنشئ حسابك.',
    'Welcome back.': 'مرحباً بعودتك.',
    'WELCOME BACK': 'مرحباً بعودتك',
    'START YOUR JOURNEY': 'ابدأ رحلتك',
    'Get Started': 'ابدأ الآن',
    'OR CONTINUE SEAMLESSLY': 'أو تابع مباشرة',
    'EMAIL ADDRESS': 'البريد الإلكتروني',
    'PASSWORD': 'كلمة المرور',
    'CONFIRM PASSWORD': 'تأكيد كلمة المرور',
    'FULL NAME': 'الاسم الكامل',
    'Password': 'كلمة المرور',
    'Forgot password?': 'نسيت كلمة المرور؟',
    'Password recovery': 'استعادة كلمة المرور',
    'Your password': 'كلمة المرور',
    'you@example.com': 'بريدك الإلكتروني',
    'e.g. Maya Lin': 'مثال: مايا لين',
    'maya.lin@example.com': 'name@example.com',
    'Please enter your name': 'الرجاء إدخال اسمك',
    'Please enter your email': 'الرجاء إدخال بريدك الإلكتروني',
    'Please enter your password': 'الرجاء إدخال كلمة المرور',
    'Name is too short': 'الاسم قصير جداً',
    'That email does not look right': 'هذا البريد غير صحيح',
    'Use at least 6 characters': 'استخدم 6 أحرف على الأقل',
    'The passwords do not match': 'كلمتا المرور غير متطابقتين',
    'Incorrect password': 'كلمة المرور غير صحيحة',
    'No account on this device yet — create one first':
        'لا يوجد حساب على هذا الجهاز بعد — أنشئ حساباً أولاً',
    'That account is not on this device': 'هذا الحساب غير موجود على هذا الجهاز',
    'Logged out ✦': 'تم تسجيل الخروج ✦',
    'Welcome back ✦': 'مرحباً بعودتك ✦',
    'Profile updated ✦': 'تم تحديث الملف ✦',
    'Link copied ✦': 'تم نسخ الرابط ✦',
    // onboarding / welcome
    'Make every day count.': 'اجعل كل يوم له قيمة.',
    'Small habits. Big changes.': 'عادات صغيرة. تغييرات كبيرة.',
    'Build habits, stay consistent, and see your progress grow.':
        'ابنِ عاداتك، وحافظ على الانتظام، وشاهد تقدّمك ينمو.',
    'Build one small ritual into your routine without overwhelming your schedule.':
        'اجعل طقساً صغيراً جزءاً من روتينك دون أن يثقل جدولك.',
    'I already have an account': 'لدي حساب بالفعل',
    'By signing up, you agree to our': 'بإنشاء حساب، أنت توافق على',
    'Terms of Service': 'شروط الخدمة',
    'Privacy Policy': 'سياسة الخصوصية',
    '&': 'و',
    // home
    'No rituals yet — add your first one to start your spark.':
        'لا طقوس بعد — أضف أول طقس لتشعل شرارتك.',
    'Your first spark is waiting': 'شرارتك الأولى في الانتظار',
    'Small steps compound. Add one ritual you can keep for a week — the streak starts on day one.':
        'الخطوات الصغيرة تتراكم. أضف طقساً تحافظ عليه أسبوعاً — السلسلة تبدأ من اليوم الأول.',
    'Create your first ritual': 'أنشئ أول طقس لك',
    'Takes about 40 seconds': 'يستغرق نحو 40 ثانية',
    'Today\'s Routine': 'روتين اليوم',
    'New Ritual': 'طقس جديد',
    'DAILY PULSE': 'نبض اليوم',
    'On track': 'على المسار',
    'Days': 'أيام',
    'Record': 'الأفضل',
    'All': 'الكل',
    'Morning': 'صباحاً',
    'Afternoon': 'بعد الظهر',
    'Evening': 'مساءً',
    'Night': 'ليلاً',
    'Anytime': 'أي وقت',
    'DAILY CLARITY': 'وضوح اليوم',
    'Morning Rhythm': 'إيقاع الصباح',
    'Spring Rhythm': 'إيقاع الربيع',
    'Summer Rhythm': 'إيقاع الصيف',
    'Autumn Rhythm': 'إيقاع الخريف',
    'Winter Rhythm': 'إيقاع الشتاء',
    'Good morning': 'صباح الخير',
    'Good afternoon': 'مساء الخير',
    'Good evening': 'مساء الخير',
    // profile
    'PERSONAL SPACE': 'مساحتك الشخصية',
    'Journey': 'الرحلة',
    'Streak': 'السلسلة',
    'Completed': 'الإنجازات',
    'Active Habits': 'العادات النشطة',
    'Consistency Score': 'درجة الاتساق',
    'ACCOUNT & SYNC': 'الحساب والمزامنة',
    'PREFERENCES': 'التفضيلات',
    'SUPPORT & COMMUNITY': 'الدعم والمجتمع',
    'Personal Details': 'البيانات الشخصية',
    'Name, email, and ritual motto': 'الاسم والبريد وشعار الطقس',
    'Spark Cloud Sync': 'مزامنة سبارك السحابية',
    'Stored on this device · private & safe': 'محفوظة على جهازك · خاصة وآمنة',
    'Daily Reminders': 'التذكيرات اليومية',
    'Morning & evening gentle cues': 'تذكيرات لطيفة صباحاً ومساءً',
    'Sound & Haptic Spark': 'الصوت والاهتزاز',
    'Tactile celebration on completion': 'احتفال لمسّي عند الإنجاز',
    'Appearance & Theme': 'المظهر والسمة',
    'Midnight': 'ليلي',
    'Warm Light': 'نهاري',
    'Language': 'اللغة',
    'Ritual Guide & Insights': 'دليل الطقوس والرؤى',
    'About Daily Spark': 'عن دايلي سبارك',
    'Log Out of Daily Spark': 'تسجيل الخروج',
    'Your name and motto travel with you across the app.':
        'اسمك وشعارك يرافقانك في كل التطبيق.',
    'Display name': 'اسم العرض',
    'Ritual motto': 'شعار الطقس',
    'The Ritual Guide': 'دليل الطقوس',
    'Version': 'الإصدار',
    // details / progress / habits / add (core chrome)
    'Edit Habit': 'تعديل العادة',
    'Save Changes': 'حفظ التغييرات',
    'Ignite This Habit': 'أشعل هذه العادة',
    'Discard and return': 'تجاهل وعودة',
    'New Habit': 'عادة جديدة',
    'HABIT TITLE': 'عنوان العادة',
    'What is this ritual for?': 'ما هو هذا الطقس؟',
    'SYMBOL TOKEN': 'الرمز',
    'AURA ACCENT': 'لون الأورا',
    'Rhythm & Repeat': 'الإيقاع والتكرار',
    'Small steps compound into permanent transformations':
        'الخطوات الصغيرة تتحول إلى تغييرات دائمة',
    'Every Day': 'كل يوم',
    'Weekdays': 'أيام العمل',
    'Weekends': 'نهاية الأسبوع',
    'Custom': 'مخصص',
    'Daily Target': 'الهدف اليومي',
    'Flexible metric to measure steady momentum': 'مقياس مرن لقياس الزخم المستمر',
    'TARGET DOSAGE': 'الجرعة المستهدفة',
    'Daily Reminder': 'التذكير اليومي',
    'A quiet chime to anchor your focus': 'جرس هادئ يثبّت تركيزك',
    'Scheduled Moment': 'الموعد المحدد',
    'No reminder': 'بدون تذكير',
    'Spark Stacking Tip': 'نصيحة تكديس الشرارة',
    'Mindful Streak': 'سلسلة الوعي',
    'Create New Habit': 'أنشئ عادة جديدة',
    'Build your routine, one habit at a time.':
        'ابنِ روتينك، عادة واحدة في كل مرة.',
    'Create': 'أنشئ',
    'Filter': 'تصفية',
    'Sort & filter — coming in a later piece ✦':
        'الفرز والتصفية — في قطعة لاحقة ✦',
  };
}

/// Convenience translation helper.
String tr(String key, [Map<String, String>? args]) => Strings.tr(key, args);
