mixin Translate{
  String APP_NAME_USES = "HELLO APP";

  dynamic? Trans(String Text){
    Map<String, Map> Words = {
      'en': {
        'ENT_LANG': 'Please select your preferred language:',
        'fa' : 'Persian',
        'en' : 'English',
        'ar' : 'Arabic',
        'ai' : 'Artificial intelligence',
        'calendar': 'Calendar',
        'today' : 'To Day',
        'setting' : 'Settings',
        'event' : 'Event',
        'events' : 'Events'
      },
      'fa' : {
        'ENT_LANG' : 'لطفا زبان خود را انتخاب کنید:',
        'fa' : "فارسی",
        'en' : 'انگلیسی',
        'ar' : 'عربی',
        'ai' : 'هوش مصنوعی',
        'calendar' : 'تقویم',
        'today' : 'امروز',
        'setting' : 'تنظیمات',
        'event' : 'رویداد',
        'events' : 'رویداد ها'
      }
    };
    var getMatching = Text.split(':');
    return Words[getMatching[0]]![getMatching[1]];
  }
}