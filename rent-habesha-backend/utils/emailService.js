/* import nodemailer from 'nodemailer';

import { config } from 'dotenv';

config();

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USERNAME,
    pass: process.env.EMAIL_PASSWORD,
  },
});


// Send password reset email
 @param {string} email - Recipient email
 @param {string} resetUrl - Password reset link

export const sendPasswordResetEmail = async (email, resetUrl) => {
  const htmlTemplate = `
    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
      <h2 style="color: #2563eb;">Password Reset Request</h2>
      <p>You requested a password reset for your Rent Habesha account.</p>
      <p>Click the button below to reset your password (valid for 1 hour):</p>
      <a
        href="${resetUrl}"
        style="
          display: inline-block;
          padding: 10px 20px;
          background-color: #2563eb;
          color: white;
          text-decoration: none;
          border-radius: 5px;
          margin: 15px 0;
        "
      >
        Reset Password
      </a>
      <p>If you didn't request this, please ignore this email.</p>
      <hr />
      <p style="color: #6b7280;">
        <small>Rent Habesha Team</small>
      </p>
    </div>
  `;

  try {
    await transporter.sendMail({
      from: `"Rent Habesha" <${process.env.EMAIL_USERNAME}>`,
      to: email,
      subject: 'Password Reset Request',
      html: htmlTemplate,
    });
  } catch (error) {
    console.error('Email sending error:', error);
    throw new Error('Failed to send password reset email');
  }
};


// Required .env variables
EMAIL_USERNAME = your@gmail.com
EMAIL_PASSWORD = your-app-password  # Gmail App Password
FRONTEND_URL = http//localhost:3000  # Your frontend URL

*/