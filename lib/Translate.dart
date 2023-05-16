mixin Translate {
  String APP_NAME_USES = "HELLO APP";

  dynamic? Trans(String Text) {
    Map<String, Map> Words = {
      'en': {
        'ENT_LANG': 'Please select your preferred language:',
        'fa': 'Persian',
        'en': 'English',
        'ar': 'Arabic',
        'ai': 'Artificial intelligence',
        'calendar': 'Calendar',
        'today': 'To Day',
        'setting': 'Settings',
        'event': 'Event',
        'events': 'Events',
        'sun': 'SunDay',
        'sat': 'Saturday',
        'mon': 'Monday',
        'tue': 'Tuesday',
        'wed': 'Wednesday',
        'thu': 'Thursday',
        'fri': 'Friday',
        'nevent': 'No event',
        'internetERR': 'Internet Connection Error',
        'internetDesc': 'No internet data available! Please connect to mobile data or WIFI network'
      },
      'fa': {
        'ENT_LANG': 'لطفا زبان خود را انتخاب کنید:',
        'fa': "فارسی",
        'en': 'انگلیسی',
        'ar': 'عربی',
        'ai': 'هوش مصنوعی',
        'calendar': 'تقویم',
        'today': 'امروز',
        'setting': 'تنظیمات',
        'event': 'رویداد',
        'events': 'رویداد ها',
        'sun': 'یکشنبه',
        'sat': 'شنبه',
        'mon': 'دوشنبه',
        'tue': 'سه‌شنبه',
        'wed': 'چهارشنبه',
        'thu': 'پنجشنبه',
        'fri': 'جمعه',
        'nevent': 'بدون رویداد',
        'internetERR': 'مشکل اتصال به اینترنت',
        'internetDesc': 'داده اینترنت موجود نمی باشید! لطفا داده های تلفن همراه یا شبکه اینترنت WIFI را متصل نمایید'
      },
      'ar': {
        'ENT_LANG': 'يرجى اختيار لغتك:',
        'fa': 'الفارسية',
        'en': 'الإنجليزية',
        'ar': 'العربية',
        'ai': 'الذكاء الاصطناعي',
        'calendar': 'التقويم',
        'today': 'اليوم',
        'setting': 'الإعدادات',
        'event': 'الحدث',
        'events': 'الأحداث',
        'sun': 'الأحد',
        'sat': 'السبت',
        'mon': 'الاثنين',
        'tue': 'الثلاثاء',
        'wed': 'الأربعاء',
        'thu': 'الخميس',
        'fri': 'الجمعة',
        'nevent': 'لا يوجد حدث',
        'internetERR': 'خطأ في اتصال الإنترنت',
        'internetDesc': 'لا تتوفر بيانات الإنترنت! يرجى الاتصال ببيانات الجوال أو شبكة واي فاي'

      }
    };
    var getMatching = Text.split(':');
    return Words[getMatching[0]]![getMatching[1]];
  }
}
