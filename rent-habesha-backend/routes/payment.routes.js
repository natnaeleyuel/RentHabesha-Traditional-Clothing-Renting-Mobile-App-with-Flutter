import express from 'express';
import { processCheckout } from '../controllers/payment.controller.js';
import { auth } from '../middlewares/auth.js';

const router = express.Router();

router.post('/checkout', auth, processCheckout);

export default router;