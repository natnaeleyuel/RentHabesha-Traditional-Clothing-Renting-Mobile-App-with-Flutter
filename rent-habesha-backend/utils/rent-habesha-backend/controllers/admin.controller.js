import User from '../models/User.js';
import ClothingItem from '../models/ClothingItem.js';
import Renting from '../models/Renting.js';
import BlacklistedToken from '../models/BlacklistedToken.js';

export const adminDashboardStats = async (req, res) => {
    try {
        const usersCount = await User.countDocuments();
        const itemsCount = await ClothingItem.countDocuments();
        const rentingCount = await Renting.countDocuments();
        const completedRentingCount = await Renting.countDocuments({
            status: 'completed'
        });
        const pendingRentingCount = await Renting.countDocuments({
            status: 'pending'
        });

        const recentUsers = await User.find()
            .sort({ createdAt: -1 })
            .limit(5)
            .select('name email role createdAt');

        const recentRenting = await Renting.find()
            .sort({ createdAt: -1 })
            .limit(5)
            .populate('renter', 'name email')
            .populate('clothingItem', 'title');

        res.status(200).json({
            success: true,
            data: {
                counts: {
                    users: usersCount,
                    items: itemsCount,
                    renting: rentingCount,
                    pending: pendingRentingCount,
                    completed: completedRentingCount
                },
                recentUsers,
                recentRenting
            }
        });

    } catch (error) {
        console.error('Admin dashboard error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to get admin dashboard stats',
            error: error.message
        });
    }
};

export const manageUsers = async (req, res) => {
    try {
        const { page = 1, limit = 10, search, role } = req.query;
        const skip = (page - 1) * limit;

        const query = {};
        if (search) {
            query.$or = [
                { name: new RegExp(search, 'i') },
                { email: new RegExp(search, 'i') }
            ];
        }
        if (role) query.role = role;

        const users = await User.find(query)
            .select('-hash -__v')
            .skip(skip)
            .limit(Number(limit))
            .sort({ createdAt: -1 });

        const total = await User.countDocuments(query);

        res.status(200).json({
            success: true,
            count: users.length,
            total,
            page: Number(page),
            pages: Math.ceil(total / limit),
            data: users
        });

    } catch (error) {
        console.error('Manage users error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch users',
            error: error.message
        });
    }
};

export const manageListings = async (req, res) => {
    try {
        const { page = 1, limit = 10, search, status } = req.query;
        const skip = (page - 1) * limit;

        const query = {};
        if (search) {
            query.$or = [
                { title: new RegExp(search, 'i') },
                { description: new RegExp(search, 'i') }
            ];
        }
        if (status) query.availability = status === 'available';

        const listings = await ClothingItem.find(query)
            .populate('owner', 'name email')
            .skip(skip)
            .limit(Number(limit))
            .sort({ createdAt: -1 });

        const total = await ClothingItem.countDocuments(query);

        res.status(200).json({
            success: true,
            count: listings.length,
            total,
            page: Number(page),
            pages: Math.ceil(total / limit),
            data: listings
        });

    } catch (error) {
        console.error('Manage listings error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch listings',
            error: error.message
        });
    }
};

export const adminDeleteListing = async (req, res) => {
    try {
        const { listingId } = req.params;

        const listing = await ClothingItem.findByIdAndDelete(listingId);
        if (!listing) {
            return res.status(404).json({
                success: false,
                message: 'Listing not found'
            });
        }

        await Renting.deleteMany({ clothingItem: listingId });

        if (listing.images && listing.images.length > 0) {
            const fs = await import('fs');
            const path = await import('path');

            listing.images.forEach(imageUrl => {
                const filename = imageUrl.split('/').pop();
                const filePath = path.join(__dirname, '../../uploads', filename);

                fs.unlink(filePath, err => {
                    if (err) console.error('Error deleting image:', err);
                });
            });
        }

        res.status(200).json({
            success: true,
            message: 'Listing and associated data deleted successfully'
        });

    } catch (error) {
        console.error('Admin delete listing error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to delete listing',
            error: error.message
        });
    }
};

export const manageRenting = async (req, res) => {
    try {
        const { page = 1, limit = 10, status } = req.query;
        const skip = (page - 1) * limit;

        const query = {};
        if (status) query.status = status;

        const renting = await Renting.find(query)
            .populate('renter', 'name email phone')
            .populate('owner', 'name email')
            .populate('clothingItem', 'title images')
            .skip(skip)
            .limit(Number(limit))
            .sort({ startDate: -1 });

        const total = await Renting.countDocuments(query);

        res.status(200).json({
            success: true,
            count: renting.length,
            total,
            page: Number(page),
            pages: Math.ceil(total / limit),
            data: renting
        });

    } catch (error) {
        console.error('Manage renting error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch renting',
            error: error.message
        });
    }
};

export const updateRentingStatus = async (req, res) => {
    try {
        const { rentingId } = req.params;
        const { status } = req.body;

        const validStatuses = ['pending', 'completed', 'available'];
        if (!validStatuses.includes(status)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid renting status'
            });
        }

        const renting = await Renting.findByIdAndUpdate(
            rentingId,
            { status },
            { new: true, runValidators: true }
        )
        .populate('renter', 'name email')
        .populate('clothingItem', 'title');

        if (!renting) {
            return res.status(404).json({
                success: false,
                message: 'Renting not found'
            });
        }

        res.status(200).json({
            success: true,
            data: renting
        });

    } catch (error) {
        console.error('Update renting error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to update renting status',
            error: error.message
        });
    }
};