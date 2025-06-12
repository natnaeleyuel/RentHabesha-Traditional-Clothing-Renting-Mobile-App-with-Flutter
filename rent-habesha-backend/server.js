import express from 'express' ;
import dotenv from 'dotenv' ;
import cors from 'cors' ;
import connectDB from './config/database.js' ;

import authRoutes from './routes/auth.routes.js' ;
import clothingRoutes from './routes/clothing.routes.js' ;
import paymentRoutes from './routes/payment.routes.js' ;

dotenv.config() ;
const app = express() ;

connectDB() ;

app.use(cors(

)) ;
app.use(express.json()) ;
app.use(express.urlencoded({ extended: true })) ;

app.use('/api/auth', authRoutes) ;
app.use('/api/clothing', clothingRoutes) ;
app.use('/api/payments', paymentRoutes) ;

app.use('/uploads', express.static('uploads')) ;

const PORT = process.env.PORT || 5000 ;
app.listen(PORT,() => {
  console.log(`RentHabesha backend running in ${process.env.NODE_ENV} mode on port ${PORT}`) ;
}) ;
// Listen for unhandled promise rejections, log the error mesage
process.on('unhandledRejection', (err) => {
  console.error(`Unhandled Rejection: ${err.message}`) ;
  server.close(() => process.exit(1)) ;
}) ;