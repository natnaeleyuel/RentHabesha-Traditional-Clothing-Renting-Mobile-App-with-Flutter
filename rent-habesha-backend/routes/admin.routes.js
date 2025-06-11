import express from 'express';
import auth from '../middlewares/auth.js';
import adminCheck from '../middlewares/roles.js';

import {
    adminDashboardStats,
    manageUsers,
    manageListings,
    adminDeleteListing,
    manageRenting,
    updateRentingStatus
} from '../controllers/admin.controller.js';

const router = express.Router();

router.use(auth);
router.use(adminCheck);

router.get('/dashboard', adminDashboardStats);

router.get('/users', manageUsers);

router.get('/listings', manageListings);
router.delete('/listings/:listingId', adminDeleteListing);

router.get('/renting', manageRenting);
router.patch('/renting/:rentingId/status', updateRentingStatus);

export default router;