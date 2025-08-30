# Runner Code App

تطبيق Flutter متعدد الوظائف يوفر خدمات تعليمية وتقنية متنوعة.

## المميزات

- **تعليم البرمجة**: دروس تفاعلية لتعلم لغات البرمجة المختلفة
- **شرح الكود**: أداة لشرح وتحليل الكود البرمجي
- **خدمات تقنية**: مجموعة من الخدمات التقنية المفيدة
- **مولد الصور**: إنشاء صور باستخدام الذكاء الاصطناعي
- **دردشة مفتوحة**: محادثة تفاعلية مع المساعد الذكي

## التقنيات المستخدمة

- Flutter
- Dart
- SQLite (للتخزين المحلي)
- Node.js (للخادم)

## التثبيت والتشغيل

### المتطلبات
- Flutter SDK
- Dart SDK
- Android Studio / VS Code

### خطوات التثبيت

1. استنساخ المشروع:
```bash
git clone https://github.com/your-username/runner_code_app.git
cd runner_code_app
```

2. تثبيت التبعيات:
```bash
flutter pub get
```

3. تشغيل التطبيق:
```bash
flutter run
```

## هيكل المشروع

```
lib/
├── main.dart                 # نقطة البداية للتطبيق
├── dashboard.dart           # الشاشة الرئيسية
├── login.dart              # شاشة تسجيل الدخول
├── splash_screen.dart      # شاشة البداية
├── education_screen.dart   # شاشة التعليم
├── code_explainer_screen.dart # شاشة شرح الكود
├── image_generator_screen.dart # شاشة مولد الصور
├── it_services_screen.dart # شاشة الخدمات التقنية
├── openchat_screen.dart    # شاشة الدردشة
├── database_helper.dart    # مساعد قاعدة البيانات
└── email_service.dart      # خدمة البريد الإلكتروني
```

## المساهمة

نرحب بمساهماتكم! يرجى اتباع الخطوات التالية:

1. Fork المشروع
2. إنشاء فرع جديد للميزة (`git checkout -b feature/AmazingFeature`)
3. Commit التغييرات (`git commit -m 'Add some AmazingFeature'`)
4. Push إلى الفرع (`git push origin feature/AmazingFeature`)
5. فتح Pull Request

## الترخيص

هذا المشروع مرخص تحت رخصة MIT - انظر ملف [LICENSE](LICENSE) للتفاصيل.

## التواصل

لأي استفسارات أو اقتراحات، يرجى التواصل معنا عبر:
- فتح issue في GitHub
- إرسال بريد إلكتروني إلى: your-email@example.com
