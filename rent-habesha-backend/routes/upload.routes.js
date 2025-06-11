import express from 'express';
import {
  uploadSingleImage,
} from '../controllers/upload.controller.js';
import auth from '../middlewares/auth.js';

const router = express.Router();

router.use(auth);

router.post('/single', uploadSingleImage);

export default router;