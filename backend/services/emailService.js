// backend/services/emailService.js
const nodemailer = require('nodemailer');
require('dotenv').config();

// Create a transporter using SMTP or a service (e.g., Gmail)
const transporter = nodemailer.createTransport({
    service: process.env.EMAIL_SERVICE || 'gmail',
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS,
    },
});

// Verify connection configuration
transporter.verify((error, success) => {
    if (error) {
        console.warn('⚠️ SMTP Connection Warning:', error.message);
    } else {
        console.log('✅ SMTP Server reaches successfully');
    }
});

/**
 * Sends a 6-digit OTP for password reset.
 */
exports.sendOTPEmail = async (email, otp, name) => {
    const mailOptions = {
        from: `"MenTora Security" <${process.env.EMAIL_USER}>`,
        to: email,
        subject: 'Your Password Reset OTP - MenTora',
        html: `
        <div style="font-family: Arial, sans-serif; padding: 20px; border: 1px solid #eee; border-radius: 10px;">
            <h2 style="color: #4f46e5;">Password Reset Request</h2>
            <p>Hello ${name},</p>
            <p>You requested to reset your password. Use the code below to complete the process. This code is valid for 10 minutes.</p>
            <div style="background: #f3f4f6; padding: 15px; border-radius: 8px; text-align: center; font-size: 24px; font-weight: bold; letter-spacing: 5px; color: #1f2937;">
                ${otp}
            </div>
            <p style="margin-top: 20px; color: #6b7280; font-size: 12px;">If you didn't request this, please ignore this email or secure your account.</p>
        </div>
        `,
    };

    return transporter.sendMail(mailOptions);
};

/**
 * Sends a security alert email upon successful login.
 */
exports.sendLoginAlert = async (email, name, device = 'Unknown Device') => {
    const timestamp = new Date().toLocaleString();
    const mailOptions = {
        from: `"MenTora Security" <${process.env.EMAIL_USER}>`,
        to: email,
        subject: 'Security Alert: New Login to MenTora',
        html: `
        <div style="font-family: Arial, sans-serif; padding: 20px; border: 1px solid #eee; border-radius: 10px;">
            <h2 style="color: #ef4444;">New Login Detected</h2>
            <p>Hello ${name},</p>
            <p>Your MenTora account was just signed into from a new device.</p>
            <div style="background: #fef2f2; padding: 15px; border-radius: 8px;">
                <p style="margin: 0; font-size: 14px;"><strong>Time:</strong> ${timestamp}</p>
                <p style="margin: 5px 0 0; font-size: 14px;"><strong>Location:</strong> Mumbai, India (Detected via IP)</p>
            </div>
            <p style="margin-top: 20px;">If this was you, you can safely ignore this email. If not, please reset your password immediately.</p>
            <p style="color: #6b7280; font-size: 12px; margin-top: 30px;">This is an automated security notification.</p>
        </div>
        `,
    };

    return transporter.sendMail(mailOptions);
};

/**
 * Sends a welcome email to new users.
 */
exports.sendWelcomeEmail = async (email, name, role) => {
    const mailOptions = {
        from: `"MenTora" <${process.env.EMAIL_USER}>`,
        to: email,
        subject: 'Welcome to MenTora!',
        html: `
        <div style="font-family: Arial, sans-serif; padding: 20px; border: 1px solid #eee; border-radius: 10px;">
            <h2 style="color: #4f46e5;">Welcome to MenTora!</h2>
            <p>Hello ${name},</p>
            <p>Welcome to MenTora, your professional mentorship platform. Your account as a <strong>${role}</strong> has been successfully created.</p>
            <p>You can now login and start exploring the platform. We're excited to have you with us!</p>
            <div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee; color: #6b7280; font-size: 12px;">
                <p>Best regards,<br>The MenTora Team</p>
            </div>
        </div>
        `,
    };

    return transporter.sendMail(mailOptions);
};
/**
 * Sends a 6-digit OTP for account registration.
 */
exports.sendVerificationOTPEmail = async (email, otp) => {
    const mailOptions = {
        from: `"MenTora" <${process.env.EMAIL_USER}>`,
        to: email,
        subject: 'Verify Your Email - MenTora',
        html: `
        <div style="font-family: Arial, sans-serif; padding: 20px; border: 1px solid #eee; border-radius: 10px;">
            <h2 style="color: #4f46e5;">Email Verification</h2>
            <p>Thank you for choosing MenTora! Use the code below to verify your email and complete your registration.</p>
            <div style="background: #f3f4f6; padding: 15px; border-radius: 8px; text-align: center; font-size: 24px; font-weight: bold; letter-spacing: 5px; color: #1f2937;">
                ${otp}
            </div>
            <p style="margin-top: 20px; color: #6b7280; font-size: 12px;">If you didn't request this, please ignore this email.</p>
            <div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee; color: #6b7280; font-size: 12px;">
                <p>Best regards,<br>The MenTora Team</p>
            </div>
        </div>
        `,
    };

    return transporter.sendMail(mailOptions);
};
