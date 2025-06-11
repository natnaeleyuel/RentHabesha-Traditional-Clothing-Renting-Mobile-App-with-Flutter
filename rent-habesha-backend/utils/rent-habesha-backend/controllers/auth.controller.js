import User from '../models/User.js';
import bcrypt from 'bcryptjs';
import isEmailValid from '../utils/validators.js';
import jwt from 'jsonwebtoken';
import BlacklistedToken from '../models/BlacklistedToken.js';

export const registerUser = async (req, res) => {
    try {
        const { name, email, password, role, phone} = req.body;

        const { valid, reason, validators } = await isEmailValid(email);
        if(!valid) {
            return res.status(400).json({
                message: 'Invalid email address',
                reason: validators[reason]
            });
        }

        const existingUser = await User.findOne({ email });
        if(existingUser) {
            return res.status(400).json({ message: 'Email already in use' });
        }

        const hash = bcrypt.hashSync(password, 10);

        const userData = {
            name,
            email,
            hash,
            phone,
            role: role || 'renter'
        };

        const user = new User(userData);
        await user.save();

        const userResponse = {
            _id: user._id,
            name: user.name,
            email: user.email,
            role: user.role,
            phone: user.phone,
            createdAt: user.createdAt
        };

        res.status(201).json({
            success: true,
            data: userResponse
        });

    } catch (error) {
        console.error('Registration error:', error);

        if (req.file) {
            const fs = await import('fs');
            fs.unlinkSync(req.file.path);
        }

        res.status(400).json({
            success: false,
            message: 'Registration failed',
            error: error.message
        });
    }
};

export const loginUser = async (req, res) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({ message: 'Email and password are required' });
        }

        const user = await User.findOne({ email });
        if (!user) {
            return res.status(401).json({ message: 'Invalid credentials' });
        }

        const isMatch = bcrypt.compareSync(password, user.hash);
        if (!isMatch) {
            return res.status(401).json({ message: 'Invalid credentials' });
        }

        const token = jwt.sign(
            {
                id: user._id,
                email: user.email,
                role: user.role
            },
            process.env.SECRET,
            { expiresIn: '8h' }
        );

        const response = {
            user: {
                id: user._id,
                name: user.name,
                email: user.email,
                role: user.role
            },
            token
        };

        res.status(200).json(response);
    } catch (error) {
        console.error('Login error:', error);
        res.status(500).json({
            message: 'Login failed',
            error: error.message
        });
    }
};

export const logoutUser = async (req, res) => {
    try {
        const authHeader = req.headers.authorization;

        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return res.status(401).json({
                message: 'Authorization token required'
            });
        }

        const token = authHeader.split(' ')[1];

        const decoded = jwt.verify(token, process.env.SECRET);

        const existingToken = await BlacklistedToken.findOne({ token });
        if (existingToken) {
            return res.status(400).json({
                message: 'Token already invalidated'
            });
        }

        const expiresAt = new Date(decoded.exp * 1000);
        await BlacklistedToken.create({
            token,
            expiresAt,
            userId: decoded.id
        });

        res.status(200).json({
            success: true,
            message: 'Successfully logged out'
        });

    } catch (error) {
        console.error('Logout error:', error);

        if (error.name === 'JsonWebTokenError') {
            return res.status(401).json({
                message: 'Invalid token'
            });
        }

        if (error.name === 'TokenExpiredError') {
            return res.status(401).json({
                message: 'Token already expired'
            });
        }

        res.status(500).json({
            message: 'Logout failed',
            error: error.message
        });
    }
};

export const changeUserPassword = async (req, res) => {
    try {

        const authHeader = req.headers.authorization;

        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return res.status(401).json({
                message: 'Authorization token required'
            });
        }

        const token = authHeader.split(' ')[1];

        const { currentPassword, newPassword, userId } = req.body;

        if (!currentPassword || !newPassword) {
            return res.status(400).json({
                message: 'Current and new password are required'
            });
        }

        if (currentPassword === newPassword) {
            return res.status(400).json({
                message: 'New password must be different'
            });
        }

        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        const isMatch = bcrypt.compareSync(currentPassword, user.hash);
        if (!isMatch) {
            return res.status(401).json({ message: 'Current password is incorrect' });
        }

        user.hash = bcrypt.hashSync(newPassword, 10);
        await user.save();

        await BlacklistedToken.create({
           token: token,
           expiresAt: new Date(Date.now() + 3600000),
           userId: userId
        });

        res.status(200).json({
            success: true,
            message: 'Password changed successfully'
        });

    } catch (error) {
        console.error('Password change error:', error);
        res.status(500).json({
            message: 'Password change failed',
            error: error.message
        });
    }
};

export const deleteUser = async (req, res) => {
    try {
        const authHeader = req.headers.authorization;

        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return res.status(401).json({
                message: 'Authorization token required'
            });
        }

        const token = authHeader.split(' ')[1];

        const { password, userId } = req.body;

        if (!password || !userId) {
            return res.status(400).json({ message: 'Password and user ID are required' });
        }

        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        const isMatch = await bcrypt.compare(password, user.hash);
        if (!isMatch) {
            return res.status(401).json({ message: 'Invalid password' });
        }

        await BlacklistedToken.create({
            token: token,
            expiresAt: new Date(Date.now() + 3600000),
            userId: userId
        });

        await User.findByIdAndDelete(userId);

        return res.status(200).json({
            success: true,
            message: 'Account deleted successfully'
        });

    } catch (error) {
        console.error('Account deletion error:', error);
        return res.status(500).json({
            message: 'Account deletion failed',
            error: error.message
        });
    }
};


/*
// For future implementation

import { sendPasswordResetEmail } from '../utils/emailService.js';
import crypto from 'crypto';

export const forgotPassword = async (req, res) => {
    try {
        const { email } = req.body;
        if (!email) {
            return res.status(400).json({ message: 'Email is required' });
        }

        const user = await User.findOne({ email });
        if (!user) {
            // Don't reveal whether email exists
            return res.status(200).json({
                message: 'If an account exists, a reset link has been sent'
            });
        }

        // Generate reset token
        const resetToken = crypto.randomBytes(32).toString('hex');
        const resetTokenExpiry = Date.now() + 3600000; // 1 hour

        user.resetToken = resetToken;
        user.resetTokenExpiry = resetTokenExpiry;
        await user.save();

        // Send email
        const resetUrl = `${process.env.FRONTEND_URL}/reset-password?token=${resetToken}`;
        await sendEmail({
            to: user.email,
            subject: 'Password Reset Request',
            html: `Click <a href="${resetUrl}">here</a> to reset your password.`
        });

        res.status(200).json({
            success: true,
            message: 'Password reset link sent'
        });

    } catch (error) {
        console.error('Forgot password error:', error);
        res.status(500).json({
            message: 'Password reset failed',
            error: error.message
        });
    }
};

export const resetPassword = async (req, res) => {
    try {
        const { token, newPassword } = req.body;
        if (!token || !newPassword) {
            return res.status(400).json({
                message: 'Token and new password are required'
            });
        }

        const user = await User.findOne({
            resetToken: token,
            resetTokenExpiry: { $gt: Date.now() }
        });

        if (!user) {
            return res.status(400).json({
                message: 'Invalid or expired token'
            });
        }

        user.hash = bcrypt.hashSync(newPassword, 10);
        user.resetToken = undefined;
        user.resetTokenExpiry = undefined;
        await user.save();

        await BlacklistedToken.deleteMany({ userId: user._id });

        res.status(200).json({
            success: true,
            message: 'Password reset successful'
        });

    } catch (error) {
        console.error('Password reset error:', error);
        res.status(500).json({
            message: 'Password reset failed',
            error: error.message
        });
    }
};
*/
