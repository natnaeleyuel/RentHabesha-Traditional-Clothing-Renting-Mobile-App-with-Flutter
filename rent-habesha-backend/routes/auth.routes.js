import express from 'express';
import {
    registerUser,
    loginUser,
    logoutUser,
    changeUserPassword,
    deleteUser,
} from '../controllers/auth.controller.js';

const router = express.Router();

router.post('/register', registerUser);
router.post('/login', loginUser);
router.post('/logout', logoutUser);
router.post('/change-password', changeUserPassword);
router.post('/delete-user', deleteUser);


export default router;