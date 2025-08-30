import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailService {
  // Working Formspree endpoint
  static const String _formspreeUrl = 'https://formspree.io/f/xkgzdlgy';

  static Future<bool> sendDemoBookingEmail({
    required String name,
    required String country,
    required String phone,
    required String email,
    required String date,
    required String time,
  }) async {
    try {
      print('📧 Sending demo booking request via Formspree...');

      // Using Formspree to send email
      final response = await http.post(
        Uri.parse(_formspreeUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          // Student information
          'name': name,
          'email': email,
          'phone': phone,
          'country': country,

          // Session details
          'demo_date': date,
          'demo_time': time,

          // Email configuration
          '_replyto': email,
          '_subject': 'Demo Session Booking - $name',

          // Main message
          'message':
              '''
🎓 Demo Session Booking Request

👤 Student Information:
• Full Name: $name
• Email: $email
• Phone: $phone
• Country: $country

📅 Session Details:
• Date: $date
• Time: $time

📋 Action Required:
Please contact this student to:
1. Confirm the demo session
2. Send Zoom meeting details
3. Provide any pre-session materials
4. Answer any questions

This booking was submitted through the Runner Code Education platform.

Best regards,
Runner Code Education System
          ''',
        }),
      );

      print('Formspree Response Status: ${response.statusCode}');
      print('Formspree Response Body: ${response.body}');

      // Formspree returns 200 for success
      if (response.statusCode == 200) {
        print(
          '✅ Email sent successfully via Formspree to info@runner-code.com',
        );
        return true;
      } else {
        print('❌ Formspree error: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Email sending error: $e');
      return false;
    }
  }

  static Future<bool> sendConsultationRequest({
    required String name,
    required String company,
    required String phone,
    required String email,
    required String project,
    required String date,
    required String time,
  }) async {
    try {
      print('📧 Sending IT consultation request via Formspree...');

      // Using Formspree to send email
      final response = await http.post(
        Uri.parse(_formspreeUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          // Client information
          'name': name,
          'company': company,
          'email': email,
          'phone': phone,

          // Project details
          'project_description': project,
          'consultation_date': date,
          'consultation_time': time,

          // Email configuration
          '_replyto': email,
          '_subject': 'IT Consultation Request - $name',

          // Main message
          'message':
              '''
💼 IT Consultation Request

👤 Client Information:
• Full Name: $name
• Company: $company
• Email: $email
• Phone: $phone

📅 Consultation Details:
• Date: $date
• Time: $time

📋 Project Description:
$project

📋 Action Required:
Please contact this client to:
1. Schedule the consultation meeting
2. Discuss project requirements in detail
3. Provide initial project estimates
4. Answer any technical questions

This consultation request was submitted through the Runner Code IT Services platform.

Best regards,
Runner Code IT Services System
          ''',
        }),
      );

      print('Formspree Response Status: ${response.statusCode}');
      print('Formspree Response Body: ${response.body}');

      // Formspree returns 200 for success
      if (response.statusCode == 200) {
        print(
          '✅ IT consultation email sent successfully via Formspree to info@runner-code.com',
        );
        return true;
      } else {
        print('❌ Formspree error: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Email sending error: $e');
      return false;
    }
  }

  // Method 3: Using local server (Node.js + Express)
  static Future<bool> sendEmailViaLocalServer({
    required String name,
    required String country,
    required String phone,
    required String email,
    required String date,
    required String time,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/send-email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'country': country,
          'phone': phone,
          'email': email,
          'date': date,
          'time': time,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['success'] == true;
      }

      return false;
    } catch (e) {
      print('Email sending error: $e');
      return false;
    }
  }

  // Method 4: Using deployed server (Heroku/Railway/Render)
  static Future<bool> sendEmailViaDeployedServer({
    required String name,
    required String country,
    required String phone,
    required String email,
    required String date,
    required String time,
  }) async {
    try {
      // Replace with your deployed server URL
      final response = await http.post(
        Uri.parse('https://your-deployed-server.herokuapp.com/api/send-email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'country': country,
          'phone': phone,
          'email': email,
          'date': date,
          'time': time,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['success'] == true;
      }

      return false;
    } catch (e) {
      print('Email sending error: $e');
      return false;
    }
  }
}
