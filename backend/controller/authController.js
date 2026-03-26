const { Student, Mentor } = require('../model');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const SALT_ROUNDS = 10;

exports.registerMentor = async (req, res) => {
    try {
        let { email, password, fullName, full_name, department, mentorCode, mentor_code, phoneNumber, phone_number } = req.body;
        const finalFullName = (full_name || fullName || "").trim();
        const rawPassword = (password || "").trim();
        const finalPassword = await bcrypt.hash(rawPassword, SALT_ROUNDS);
        const finalEmail = (email || "").toLowerCase().trim();

        if (!finalEmail || !password || !finalFullName || !department || !req.body.otp) {
            return res.status(400).json({ message: 'Missing required fields (including OTP)' });
        }

        // Verify OTP
        const storedOtp = otpStore.get(finalEmail);
        if (!storedOtp || storedOtp.otp !== req.body.otp || Date.now() > storedOtp.expiry) {
            return res.status(400).json({ message: 'Invalid or expired OTP' });
        }

        const existingMentor = await Mentor.findOne({ where: { email: finalEmail } });
        if (existingMentor) {
            return res.status(409).json({ message: 'User already exists' });
        }

        let resolvedMentorCode = mentor_code || mentorCode;
        if (!resolvedMentorCode) {
            const shortDept = department.substring(0, 3).toUpperCase();
            const random = Math.floor(1000 + Math.random() * 9000);
            resolvedMentorCode = `MTR-${shortDept}-${random}`;
        }

        const mentor = await Mentor.create({
            email: finalEmail,
            password: finalPassword,
            full_name: finalFullName,
            department,
            mentor_code: resolvedMentorCode,
            phone_number: phone_number || phoneNumber,
            role: 'mentor'
        });

        // Clean up OTP
        otpStore.delete(finalEmail);

        // Send Welcome Email
        emailService.sendWelcomeEmail(mentor.email, mentor.full_name, 'Mentor')
            .catch(e => console.error('Failed to send mentor welcome email:', e.message));

        res.status(201).json({ message: 'Mentor registered successfully', user: mentor });
    } catch (error) {
        console.error('Register Mentor Error:', error);
        res.status(500).json({ message: 'Internal server error', error: error.message });
    }
};

exports.registerStudent = async (req, res) => {
    try {
        const {
            email, password, fullName, full_name, department,
            studentId, student_id, admissionType, admission_type,
            dateOfBirth, date_of_birth, dateOfJoining, date_of_joining,
            mentorCode, mentor_code, currentSemester, current_semester,
            phoneNumber, phone_number
        } = req.body;

        const finalEmail = (email || "").toLowerCase().trim();
        const rawPassword = (password || "").trim();
        const finalFullName = (full_name || fullName || "").trim();
        const finalStudentId = (student_id || studentId || "").trim();

        if (!finalEmail || !rawPassword || !finalFullName || !department || !finalStudentId || !req.body.otp) {
            return res.status(400).json({ message: 'Missing required fields (including OTP)' });
        }

        const finalPassword = await bcrypt.hash(rawPassword, SALT_ROUNDS);

        // Verify OTP
        const storedOtp = otpStore.get(finalEmail);
        if (!storedOtp || storedOtp.otp !== req.body.otp || Date.now() > storedOtp.expiry) {
            return res.status(400).json({ message: 'Invalid or expired OTP' });
        }

        const existingStudent = await Student.findOne({ where: { email: finalEmail } });
        if (existingStudent) {
            return res.status(409).json({ message: 'User already exists' });
        }

        let mentor_id = null;
        if (mentor_code || mentorCode) {
            const mentor = await Mentor.findOne({ where: { mentor_code: mentor_code || mentorCode } });
            if (mentor) mentor_id = mentor.id;
        }

        const student = await Student.create({
            email: finalEmail,
            password: finalPassword,
            full_name: finalFullName,
            department,
            student_id: finalStudentId,
            admission_type: admission_type || admissionType,
            date_of_birth: date_of_birth || dateOfBirth,
            date_of_joining: date_of_joining || dateOfJoining,
            current_semester: current_semester || currentSemester || 1,
            phone_number: phone_number || phoneNumber,
            mentor_id,
            role: 'student',
            document_statuses: {
                "10th Marksheet": "Pending",
                "12th Marksheet": "Pending",
                "Aadhar Card": "Pending",
                "College ID": "Pending",
                "Photo": "Pending",
                "Signature": "Pending"
            }
        });

        // Clean up OTP
        otpStore.delete(finalEmail);

        // Send Welcome Email
        emailService.sendWelcomeEmail(student.email, student.full_name, 'Student')
            .catch(e => console.error('Failed to send student welcome email:', e.message));

        res.status(201).json({ message: 'Student registered successfully', user: student });
    } catch (error) {
        console.error('Register Student Error:', error);
        res.status(500).json({ message: 'Internal server error', error: error.message });
    }
};

const emailService = require('../services/emailService');

exports.login = async (req, res) => {
    try {
        const { email, password } = req.body;
        const finalEmail = (email || "").toLowerCase().trim();
        const finalPassword = (password || "").trim();

        console.log(`[DIAGNOSTIC] Login attempt for: "${finalEmail}"`);

        let user = await Mentor.findOne({ where: { email: finalEmail } });
        let role = 'mentor';

        if (!user) {
            user = await Student.findOne({ where: { email: finalEmail } });
            role = 'student';
        }

        if (!user) {
            console.log(`[DIAGNOSTIC] User "${finalEmail}" not found in database.`);
            return res.status(401).json({ message: 'Invalid credentials' });
        }

        console.log(`[DIAGNOSTIC] User found in ${role} table.`);

        const isMatch = await bcrypt.compare(finalPassword, user.password);

        if (!isMatch) {
            return res.status(401).json({ message: 'Invalid credentials' });
        }

        const accessToken = jwt.sign(
            { userId: user.id, email: user.email, role: user.role || role },
            process.env.JWT_SECRET,
            { expiresIn: '24h' }
        );

        emailService.sendLoginAlert(user.email, user.full_name || user.fullName)
            .catch(e => console.error('Failed to send login alert:', e.message));

        res.status(200).json({
            accessToken,
            refreshToken: 'dummy_refresh_token',
            user: {
                id: user.id.toString(),
                email: user.email,
                role: user.role || role,
                fullName: user.full_name || user.fullName,
                department: user.department
            }
        });
    } catch (error) {
        console.error('Login Error:', error);
        res.status(500).json({ message: 'Internal server error', error: error.message, stack: error.stack });
    }
};

exports.getProfile = async (req, res) => {
    try {
        const { userId, role } = req.user;
        const model = role === 'mentor' ? Mentor : Student;

        const user = await model.findByPk(userId, {
            attributes: { exclude: ['password'] }
        });

        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        const userData = user.toJSON();
        userData.id = userData.id.toString();

        res.json(userData);
    } catch (error) {
        console.error('Get Profile Error:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
};

exports.updateProfile = async (req, res) => {
    try {
        const { userId, role } = req.user;
        const model = role === 'mentor' ? Mentor : Student;

        const user = await model.findByPk(userId);
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        const updates = { ...req.body };
        
        // Handle field mapping for document statuses
        if (updates.documentStatuses) {
            updates.document_statuses = updates.documentStatuses;
            delete updates.documentStatuses;
        }

        // Handle field mapping for other common fields
        if (updates.documentFilePaths) {
            updates.document_file_paths = updates.documentFilePaths;
            delete updates.documentFilePaths;
        }

        if (updates.fullName) {
            updates.full_name = updates.fullName;
            delete updates.fullName;
        }

        if (updates.mentorCode) {
            updates.mentor_code = updates.mentorCode;
            delete updates.mentorCode;
        }

        await user.update(updates);
        
        const updatedUser = user.toJSON();
        delete updatedUser.password;
        updatedUser.id = updatedUser.id.toString();

        res.status(200).json({
            message: 'Profile updated successfully',
            user: updatedUser
        });
    } catch (error) {
        console.error('Update Profile Error:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
};

exports.sendRegistrationOTP = async (req, res) => {
    try {
        const { email } = req.body;
        if (!email) return res.status(400).json({ message: 'Email is required' });
        const normalizedEmail = email.toLowerCase().trim();

        // 1. Check if user already exists
        let user = await Student.findOne({ where: { email: normalizedEmail } });
        if (!user) {
            user = await Mentor.findOne({ where: { email: normalizedEmail } });
        }
        
        if (user) {
            return res.status(409).json({ message: 'User already exists with this email' });
        }

        // 2. Generate 6-digit OTP
        const otp = Math.floor(100000 + Math.random() * 900000).toString();
        
        // 3. Store OTP with Expiry (10 minutes)
        otpStore.set(normalizedEmail, {
            otp,
            expiry: Date.now() + 10 * 60 * 1000 // 10 mins
        });

        // 4. Send Verification Email
        try {
            await emailService.sendVerificationOTPEmail(normalizedEmail, otp);
            console.log(`✅ Registration OTP Email sent to ${normalizedEmail}`);
        } catch (mailError) {
            console.error('Failed to send registration OTP email:', mailError.message);
            return res.status(500).json({ message: 'Failed to send verification email. Please try again later.' });
        }

        return res.status(200).json({ 
            message: 'A verification code has been sent to your email address.', 
        });

    } catch (error) {
        console.error('Send Registration OTP Error:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
};

// --- FORGOT PASSWORD FLOW ---
// In-memory store for OTPs (For Production, use Redis or a Database Table)
const otpStore = new Map();

exports.forgotPassword = async (req, res) => {
    try {
        const { email } = req.body;
        if (!email) return res.status(400).json({ message: 'Email is required' });
        const normalizedEmail = email.toLowerCase().trim();

        // 1. Verify User Exists
        let user = await Student.findOne({ where: { email: normalizedEmail } });
        let role = 'student';
        if (!user) {
            user = await Mentor.findOne({ where: { email: normalizedEmail } });
            role = 'mentor';
        }
        
        if (!user) {
            return res.status(404).json({ message: 'User not found with that email' });
        }

        // 2. Generate 6-digit OTP
        const otp = Math.floor(100000 + Math.random() * 900000).toString();
        
        // 3. Store OTP with Expiry (10 minutes)
        otpStore.set(normalizedEmail, {
            otp,
            expiry: Date.now() + 10 * 60 * 1000 // 10 mins
        });

        // 4. Send OTP Email
        try {
            await emailService.sendOTPEmail(normalizedEmail, otp, user.full_name || user.fullName);
            console.log(`✅ OTP Email sent to ${normalizedEmail}`);
        } catch (mailError) {
            console.error('Failed to send OTP email:', mailError.message);
            // In a real app, you might want to return an error here, but we'll return the success message
            // to avoid leaking if email delivery specifically failed vs user not found.
        }

        return res.status(200).json({ 
            message: 'A 6-digit OTP has been sent to your email address.', 
        });

    } catch (error) {
        console.error('Forgot Password Error:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
};

exports.verifyOTP = async (req, res) => {
    try {
        const { email, otp } = req.body;
        if (!email || !otp) return res.status(400).json({ message: 'Email and OTP are required' });
        const normalizedEmail = email.toLowerCase().trim();

        const storedData = otpStore.get(normalizedEmail);
        
        if (!storedData) {
            return res.status(400).json({ message: 'No OTP found or expired' });
        }

        if (Date.now() > storedData.expiry) {
            otpStore.delete(normalizedEmail);
            return res.status(400).json({ message: 'OTP has expired' });
        }

        if (storedData.otp !== otp) {
            return res.status(400).json({ message: 'Invalid OTP' });
        }

        return res.status(200).json({ message: 'OTP verified successfully' });
    } catch (error) {
        console.error('Verify OTP Error:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
};

exports.resetPassword = async (req, res) => {
    try {
        const { email, newPassword, otp } = req.body; // Requiring OTP again for security
        if (!email || !newPassword || !otp) return res.status(400).json({ message: 'Required fields missing' });
        const normalizedEmail = email.toLowerCase().trim();

        // Final OTP verify to prevent forced resets
        const storedData = otpStore.get(normalizedEmail);
        if (!storedData || storedData.otp !== otp || Date.now() > storedData.expiry) {
            return res.status(400).json({ message: 'Invalid or expired session. Please request a new OTP.' });
        }

        // Find user
        let user = await Student.findOne({ where: { email: normalizedEmail } });
        if (!user) {
            user = await Mentor.findOne({ where: { email: normalizedEmail } });
        }
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        // Save new password as hashed
        const hashedNewPassword = await bcrypt.hash(newPassword, SALT_ROUNDS);
        await user.update({ password: hashedNewPassword });

        // Clean up OTP to prevent reuse
        otpStore.delete(normalizedEmail);

        return res.status(200).json({ message: 'Password reset successfully. You may now login.' });
    } catch (error) {
        console.error('Reset Password Error:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
};
