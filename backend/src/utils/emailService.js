// backend/src/utils/emailService.js

const nodemailer = require('nodemailer');

// For debugging – see what host/port we're using on startup
console.log('Mailgun SMTP host:', process.env.MAILGUN_SMTP_HOST);
console.log('Mailgun SMTP user:', process.env.MAILGUN_SMTP_USER);

// Create transporter that ALWAYS uses Mailgun host (not localhost)
const transporter = nodemailer.createTransport({
  host: process.env.MAILGUN_SMTP_HOST || 'smtp.mailgun.org',
  port: Number(process.env.MAILGUN_SMTP_PORT) || 587,
  secure: false, // Mailgun with 587 uses STARTTLS, not SSL by default
  auth: {
    user: process.env.MAILGUN_SMTP_USER,
    pass: process.env.MAILGUN_SMTP_PASS,
  },
});

/**
 * Send a simple OTP email
 * @param {string} to - recipient email
 * @param {string} otp - 6-digit OTP code
 */
const sendOtpEmail = async (to, otp) => {
  const mailOptions = {
    from: process.env.MAIL_FROM || 'no-reply@muudhealth.com',
    to,
    subject: 'Your MUUD OTP Code',
    text: `Your verification code is: ${otp}. It will expire in 10 minutes.`,
    html: `<p>Your verification code is:</p>
           <h2>${otp}</h2>
           <p>This code will expire in 10 minutes.</p>`,
  };

  await transporter.sendMail(mailOptions);
};

module.exports = {
  sendOtpEmail,
};
