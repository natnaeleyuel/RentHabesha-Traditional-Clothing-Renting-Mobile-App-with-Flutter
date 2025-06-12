import jwt from 'jsonwebtoken';
import BlacklistedToken from '../models/BlacklistedToken.js';

export const auth = async (req, res, next) => {
    try {
        const authHeader = req.headers.authorization;
        if (!authHeader?.startsWith('Bearer ')) {
            return res.status(401).json({ message: 'Unauthorized - No token provided' });
        }

        const token = authHeader.split(' ')[1];

        const isBlacklisted = await BlacklistedToken.exists({ token });
        if (isBlacklisted) {
            return res.status(401).json({ message: 'Unauthorized - Token revoked' });
        }

        const decoded = jwt.verify(token, process.env.SECRET);

        req.user = {
            id: decoded.id,
            email: decoded.email,
            role: decoded.role
        };

        next();
    } catch (error) {
        if (error.name === 'TokenExpiredError') {
            return res.status(401).json({ message: 'Session expired - Please log in again' });
        }
        if (error.name === 'JsonWebTokenError') {
            return res.status(401).json({ message: 'Invalid token' });
        }
        res.status(500).json({ message: 'Authentication failed' });
    }
};