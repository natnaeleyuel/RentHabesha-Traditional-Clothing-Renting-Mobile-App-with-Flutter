import express from 'express';
import { auth } from '../middlewares/auth.js';
import { multipleUpload } from '../utils/upload.js';

import {
  addClothingItem,
  getAllClothingItems,
  getClothingItemById,
  updateClothingItem,
  deleteClothingItem,
  updateItemAvailability
} from '../controllers/clothing.controller.js';

const router = express.Router();

router.use(auth);

router.post('/', auth, multipleUpload, addClothingItem);
router.get('/', getAllClothingItems);
router.get('/:id', getClothingItemById);
router.patch('/:id', auth, multipleUpload, updateClothingItem);
router.delete('/:id', auth, deleteClothingItem);
router.patch('/:id/availability', auth, updateItemAvailability);

export default router;