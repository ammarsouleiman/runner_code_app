const express = require('express');
const nodemailer = require('nodemailer');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Email transporter configuration
const transporter = nodemailer.createTransporter({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER || 'your-email@gmail.com',
    pass: process.env.EMAIL_PASS || 'your-app-password'
  }
});

// Email sending endpoint
app.post('/api/send-email', async (req, res) => {
  try {
    const { name, country, phone, email, date, time } = req.body;

    // Validate required fields
    if (!name || !country || !phone || !email || !date || !time) {
      return res.status(400).json({ 
        success: false, 
        message: 'All fields are required' 
      });
    }

    // Email content
    const mailOptions = {
      from: process.env.EMAIL_USER || 'your-email@gmail.com',
      to: 'info@runner-code.com',
      subject: `Demo Session Booking - ${name}`,
      html: `
        <!DOCTYPE html>
        <html>
        <head>
          <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
            .header { background: linear-gradient(135deg, #8B0000, #B22222); color: white; padding: 20px; text-align: center; }
            .content { padding: 20px; background: #f9f9f9; }
            .info-box { background: white; padding: 15px; margin: 10px 0; border-left: 4px solid #8B0000; }
            .label { font-weight: bold; color: #8B0000; }
          </style>
        </head>
        <body>
          <div class="header">
            <h1>🎓 Demo Session Booking Request</h1>
            <p>New student interested in Runner Code Education</p>
          </div>
          
          <div class="content">
            <div class="info-box">
              <h2>📅 Session Details</h2>
              <p><span class="label">Date:</span> ${date}</p>
              <p><span class="label">Time:</span> ${time}</p>
            </div>
            
            <div class="info-box">
              <h2>👤 Student Information</h2>
              <p><span class="label">Full Name:</span> ${name}</p>
              <p><span class="label">Country:</span> ${country}</p>
              <p><span class="label">Phone Number:</span> ${phone}</p>
              <p><span class="label">Email:</span> ${email}</p>
            </div>
            
            <div class="info-box">
              <h2>📋 Next Steps</h2>
              <p>Please contact the student to:</p>
              <ul>
                <li>Confirm the demo session</li>
                <li>Send Zoom meeting details</li>
                <li>Provide any pre-session materials</li>
                <li>Answer any questions they may have</li>
              </ul>
            </div>
            
            <p style="text-align: center; margin-top: 30px; color: #666;">
              This booking was submitted through the Runner Code Education platform.
            </p>
          </div>
        </body>
        </html>
      `
    };

    // Send email
    const info = await transporter.sendMail(mailOptions);
    
    console.log('Email sent successfully:', info.messageId);
    
    res.json({ 
      success: true, 
      message: 'Email sent successfully',
      messageId: info.messageId 
    });

  } catch (error) {
    console.error('Error sending email:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Failed to send email',
      error: error.message 
    });
  }
});

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ 
    success: true, 
    message: 'Server is running',
    timestamp: new Date().toISOString()
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`Email endpoint: http://localhost:${PORT}/api/send-email`);
}); 