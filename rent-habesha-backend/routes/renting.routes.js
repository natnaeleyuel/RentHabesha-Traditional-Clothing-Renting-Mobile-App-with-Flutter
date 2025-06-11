import express from 'express';
import {
  createRenting,
  getRenting,
  updateRentingStatus
} from '../controllers/renting.controller.js';
import auth from '../middlewares/auth.js';

const router = express.Router();

router.use(auth);

router.post('/', createRenting);
router.get('/', getRenting);
router.patch('/:rentingId/status', updateRentingStatus);

export default router;