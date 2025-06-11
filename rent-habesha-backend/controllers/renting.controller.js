import Renting from '../models/Renting.js';
import ClothingItem from '../models/ClothingItem.js';
import User from '../models/User.js';

export const createRenting = async (req, res) => {
  try {
    const { clothingItemId, startDate, endDate } = req.body;
    const renterId = req.user.id;

    const start = new Date(startDate);
    const end = new Date(endDate);

    if (start >= end) {
      return res.status(400).json({ message: 'End date must be after start date' });
    }

    const clothingItem = await ClothingItem.findById(clothingItemId)
      .populate('owner', 'name email phone');

    if (!clothingItem || !clothingItem.availability) {
      return res.status(400).json({ message: 'Item not available for renting' });
    }

    const existingRenting = await Renting.findOne({
      clothingItem: clothingItemId,
      status: { $in: ['pending', 'confirmed'] },
      $or: [
        { startDate: { $lt: end }, endDate: { $gt: start } }
      ]
    });

    if (existingRenting) {
      return res.status(400).json({
        message: 'Item already rented for selected dates',
        conflictingDates: {
          start: existingRenting.startDate,
          end: existingRenting.endDate
        }
      });
    }

    const days = Math.ceil((end - start) / (1000 * 60 * 60 * 24));
    const totalPrice = days * clothingItem.pricePerDay;

    const renting = new Renting({
      clothingItem: clothingItemId,
      renter: renterId,
      owner: clothingItem.owner._id,
      startDate: start,
      endDate: end,
      totalPrice,
      status: 'pending'
    });

    await renting.save();

    const populatedRenting = await Booking.findById(booking._id)
      .populate('clothingItem', 'title images pricePerDay')
      .populate('renter', 'name email')
      .populate('owner', 'name email');

    res.status(201).json(populatedRenting);

  } catch (error) {
    console.error('Renting creation error:', error);
    res.status(500).json({
      message: 'Renting creation failed',
      error: error.message
    });
  }
};

export const getRenting = async (req, res) => {
  try {
    const userId = req.user.id;
    const { role } = req.user;
    const { status } = req.query;

    let query = {};

    if (role === 'renter') {
      query.renter = userId;
    } else if (role === 'owner') {
      query.owner = userId;
    }

    if (status) {
      query.status = status;
    }

    const renting = await Renting.find(query)
      .populate('clothingItem', 'title images pricePerDay')
      .populate('renter', 'name email phone')
      .populate('owner', 'name email phone')
      .sort({ createdAt: -1 });

    res.status(200).json(renting);

  } catch (error) {
    console.error('Get renting error:', error);
    res.status(500).json({
      message: 'Failed to get renting',
      error: error.message
    });
  }
};

export const updateRentingStatus = async (req, res) => {
  try {
    const { rentingId } = req.params;
    const { status } = req.body;
    const userId = req.user.id;

    const renting = await Renting.findById(rentingId);

    if (!renting) {
      return res.status(404).json({ message: 'Renting not found' });
    }

    if (renting.owner.toString() !== userId) {
      return res.status(403).json({ message: 'Not authorized to update this renting' });
    }

    const allowedTransitions = {
      owner: {
        pending: ['available'],
        confirmed: ['available']
      }
    };

    const userRole = renting.owner.toString() === userId ? 'owner' : 'renter';

    if (!allowedTransitions[userRole][renting.status]?.includes(status)) {
      return res.status(400).json({
        message: `Invalid status transition from ${renting.status} to ${status} for ${userRole}`
      });
    }

    renting.status = status;
    await renting.save();

    res.status(200).json(renting);

  } catch (error) {
    console.error('Update renting error:', error);
    res.status(500).json({
      message: 'Failed to update renting',
      error: error.message
    });
  }
};