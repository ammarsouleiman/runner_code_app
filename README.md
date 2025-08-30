# Runner Code - AI-Powered Development Assistant

تطبيق Flutter للويب يوفر مساعد ذكي للتطوير البرمجي.

## 🚀 النشر على GitHub Pages

### الخطوات المطلوبة:

1. **تفعيل GitHub Pages**:
   - اذهب إلى إعدادات المستودع (Repository Settings)
   - اختر "Pages" من القائمة الجانبية
   - اختر "GitHub Actions" كمصدر للنشر

2. **إعداد GitHub Actions**:
   - الملف `.github/workflows/deploy.yml` موجود بالفعل
   - سيتم البناء والنشر تلقائياً عند كل push إلى main/master

3. **الوصول للتطبيق**:
   - بعد النشر، سيكون التطبيق متاح على: `https://[username].github.io/[repository-name]`

## 🛠️ التطوير المحلي

```bash
# تثبيت التبعيات
flutter pub get

# تشغيل التطبيق للويب
flutter run -d chrome

# بناء التطبيق للويب
flutter build web
```

## 📁 بنية المشروع

- `lib/` - كود Dart الرئيسي
- `web/` - ملفات الويب (HTML, CSS, JS)
- `assets/` - الصور والموارد
- `.github/workflows/` - إعدادات GitHub Actions

## 🔧 المتطلبات

- Flutter SDK 3.8.1+
- Dart SDK 3.8.1+
- متصفح ويب حديث

## 📝 ملاحظات

- تم استبعاد ملفات الخادم الخلفي (Node.js) من النشر
- التطبيق يعمل كتطبيق ويب مستقل
- يدعم التوجيه (routing) في GitHub Pages

