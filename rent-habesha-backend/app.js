import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import authRoutes from './routes/auth.routes.js';
import clothingRoutes from './routes/clothing.routes.js';
import bookingRoutes from './routes/booking.routes.js';
import adminRoutes from './routes/admin.routes.js';
import errorHandler from './middlewares/errorHandler.js';
import path from 'path';
import { fileURLToPath } from 'url';
import paymentRoutes from './routes/payment.routes.js';

dotenv.config();

const app = express();
app.use(cors(
    origin: '*',
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization']
));

app.use(express.json());
app.use(limiter);

const __filename = fileURLToPath(import.meta.url) ;
const __dirname =  path.dirname(__filename) ;

app.use('/uploads', express.static(path.join(__dirname, 'uploads'))) ;
app.use('/api/auth', authRoutes );
app.use('/api/clothing', clothingRoutes );
app.use('/api/bookings', bookingRoutes );
app.use('/api/admin', adminRoutes);
app.use('/api/payments', paymentRoutes )

// Handle GET requests to '/api/auth/register' endpoint,
// log the request, and send a confirmation JSON response
app.get('/api/auth/register', (req, res) => {
  console.log('GET request received') ;
  res.json({ message: 'Backend is working!' }) ;
});

export default app;