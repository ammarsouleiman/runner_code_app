# Runner Code Email Server

خادم إرسال البريد الإلكتروني لطلبات حجز الجلسات التجريبية في Runner Code Education.

## 🚀 الإعداد السريع

### 1. تثبيت المتطلبات
```bash
npm install
```

### 2. إعداد البريد الإلكتروني

#### للـ Gmail:
1. **تفعيل المصادقة الثنائية** على حساب Gmail
2. **إنشاء كلمة مرور للتطبيق**:
   - اذهب إلى إعدادات Google
   - اختر "الأمان"
   - اختر "كلمات مرور التطبيقات"
   - أنشئ كلمة مرور جديدة للتطبيق

3. **إنشاء ملف `.env`**:
```env
EMAIL_USER=your-email@gmail.com
EMAIL_PASS=your-app-password
PORT=3000
```

### 3. تشغيل الخادم
```bash
# للتطوير
npm run dev

# للإنتاج
npm start
```

## 📧 نقاط النهاية (Endpoints)

### إرسال البريد الإلكتروني
```
POST /api/send-email
```

**المعاملات المطلوبة:**
```json
{
  "name": "اسم الطالب",
  "country": "البلد",
  "phone": "رقم الهاتف",
  "email": "البريد الإلكتروني",
  "date": "تاريخ الجلسة",
  "time": "وقت الجلسة"
}
```

**الاستجابة:**
```json
{
  "success": true,
  "message": "Email sent successfully",
  "messageId": "message-id"
}
```

### فحص حالة الخادم
```
GET /api/health
```

## 🌐 النشر

### Heroku
```bash
# إنشاء تطبيق Heroku
heroku create your-app-name

# إضافة متغيرات البيئة
heroku config:set EMAIL_USER=your-email@gmail.com
heroku config:set EMAIL_PASS=your-app-password

# النشر
git push heroku main
```

### Railway
```bash
# تثبيت Railway CLI
npm install -g @railway/cli

# تسجيل الدخول
railway login

# إنشاء مشروع جديد
railway init

# إضافة متغيرات البيئة
railway variables set EMAIL_USER=your-email@gmail.com
railway variables set EMAIL_PASS=your-app-password

# النشر
railway up
```

### Render
1. اربط مستودع GitHub بـ Render
2. أضف متغيرات البيئة في لوحة التحكم
3. النشر التلقائي عند كل تحديث

## 🔧 التخصيص

### تغيير عنوان البريد الإلكتروني المستلم
في ملف `server.js`، غيّر السطر:
```javascript
to: 'info@runner-code.com',
```

### تخصيص محتوى البريد الإلكتروني
عدّل متغير `mailOptions.html` في ملف `server.js`

## 🛡️ الأمان

- استخدم HTTPS في الإنتاج
- لا تشارك متغيرات البيئة
- استخدم كلمات مرور قوية للتطبيقات
- فعّل المصادقة الثنائية

## 📝 السجلات

الخادم يسجل:
- طلبات إرسال البريد الإلكتروني
- الأخطاء والاستثناءات
- معرفات الرسائل المرسلة

## 🆘 استكشاف الأخطاء

### مشاكل Gmail:
- تأكد من تفعيل المصادقة الثنائية
- استخدم كلمة مرور التطبيق وليس كلمة المرور العادية
- تأكد من صحة عنوان البريد الإلكتروني

### مشاكل الشبكة:
- تأكد من تشغيل الخادم على المنفذ الصحيح
- تحقق من إعدادات CORS
- تأكد من صحة عنوان URL

## 📞 الدعم

للمساعدة، راسل: info@runner-code.com 