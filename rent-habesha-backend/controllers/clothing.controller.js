import ClothingItem from '../models/ClothingItem.js';
import { multipleUpload } from '../utils/upload.js';
import jwt from 'jsonwebtoken';
import BlacklistedToken from '../models/BlacklistedToken.js';
import User from '../models/User.js';
import mongoose from 'mongoose';
import fs from 'fs';
import path from 'path';
import Renting from '../models/Renting.js';

export const addClothingItem = async (req, res) => {
    try {
        const authHeader = req.headers.authorization;
        if (!authHeader) {
            return res.status(401).json({ message: 'Authorization required' });
        }

        const token = authHeader.split(' ')[1];
        const decoded = jwt.verify(token, process.env.SECRET);

        const blacklistedToken = await BlacklistedToken.findOne({ token });
        if (blacklistedToken) {
            return res.status(401).json({ message: 'Token revoked' });
        }

        const { title, description, rentalDuration, pricePerDay, type, careInstruction } = req.body;

        if (!title || !description || !pricePerDay || !type || !careInstruction) {
            if (req.files && req.files.length > 0) {
                req.files.forEach(file => {
                    fs.unlinkSync(file.path);
                });
            }
            return res.status(400).json({ message: 'Missing required fields' });
        }

        const user = await User.findById(decoded.id);

        const imagePaths = req.files?.map(file => `/uploads/clothing.photos/${file.filename}`) ||
                         ['/uploads/no.image.png'];

        const clothingItem = new ClothingItem({
            title,
            description,
            rentalDuration,
            owner: user._id,
            pricePerDay,
            type,
            location: 'Addis Ababa',
            careInstruction,
            images: imagePaths
        });

        await clothingItem.save();

        const response = clothingItem.toObject();
        delete response.__v;

        res.status(201).json(response);

    } catch (error) {
        console.error('Add clothing error:', error);

        if (req.files && req.files.length > 0) {
            req.files.forEach(file => {
                try {
                    fs.unlinkSync(file.path);
                } catch (unlinkError) {
                    console.error('Failed to delete file:', file.path, unlinkError);
                }
            });
        }

        if (error.name === 'ValidationError') {
            return res.status(400).json({
                message: 'Validation failed',
                errors: error.errors
            });
        }

        if (error.name === 'JsonWebTokenError') {
            return res.status(401).json({ message: 'Invalid token' });
        }

        res.status(500).json({
            message: 'Failed to add clothing item',
            error: error.message
        });

    }
};


export const getAllClothingItems = async (req, res) => {
    try {
        const {
            type,
            size,
            location,
            search,
            page = 1,
            limit = 10
        } = req.query;

        const filter = { availability: true };

        if (type) filter.type = type;
        if (size) filter.size = size;
        if (location) filter.location = new RegExp(location, 'i');

        if (search) {
            filter.$or = [
                { title: new RegExp(search, 'i') },
                { description: new RegExp(search, 'i') }
            ];
        }

        const skip = (page - 1) * limit;

        const total = await ClothingItem.countDocuments(filter);

        const items = await ClothingItem.find(filter)
            .populate('owner', 'name email phone')
            .sort({ createdAt: -1 })
            .skip(skip)
            .limit(Number(limit));

        res.status(200).json({
            success: true,
            count: items.length,
            total,
            page: Number(page),
            pages: Math.ceil(total / limit),
            data: items
        });
    } catch (error) {
        console.error('Get clothing items error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch clothing items',
            error: error.message
        });
    }
};


export const getClothingItemById = async (req, res) => {
    try {
        if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid clothing item ID'
            });
        }

        const item = await ClothingItem.findById(req.params.id)
            .populate('owner', 'name email phone rating')

        if (!item) {
            return res.status(404).json({
                success: false,
                message: 'Clothing item not found'
            });
        }
Q
        const relatedItems = await ClothingItem.find({
            owner: item.owner._id,
            _id: { $ne: item._id },
            availability: true
        })
        .limit(4)
        .select('title images pricePerDay');

        res.status(200).json({
            success: true,
            data: {
                ...item.toObject(),
                relatedItems
            }
        });

    } catch (error) {
        console.error('Get clothing item error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch clothing item',
            error: error.message
        });
    }
};

export const updateClothingItem = async (req, res) => {
    try {
        const authHeader = req.headers.authorization;
        if (!authHeader) {
            return res.status(401).json({
                success: false,
                message: 'Authorization required'
            });
        }

        const token = authHeader.split(' ')[1];
        const decoded = jwt.verify(token, process.env.SECRET);

        const blacklistedToken = await BlacklistedToken.findOne({ token });
        if (blacklistedToken) {
            return res.status(401).json({
                success: false,
                message: 'Token revoked'
            });
        }

        const user = await User.findById(decoded.id);
        const clothingItem = await ClothingItem.findById(req.params.id);
        if (!clothingItem) {
            return res.status(404).json({
                success: false,
                message: 'Clothing item not found'
            });
        }

        if (clothingItem.owner.toString() !== user._id.toString() && user.role !== 'admin') {
            return res.status(403).json({
                success: false,
                message: 'Not authorized to update this item'
            });
        }

        const { title, description, rentalDuration, pricePerDay, type, careInstruction, existingImages } = req.body;

        // Parse existingImages if it's a string (from JSON)
        let parsedExistingImages = [];
        try {
            parsedExistingImages = typeof existingImages === 'string'
                ? JSON.parse(existingImages)
                : existingImages || [];
        } catch (e) {
            console.error('Error parsing existingImages:', e);
            parsedExistingImages = [];
        }

        // Update fields if they exist in the request
        if (title) clothingItem.title = title;
        if (description) clothingItem.description = description;
        if (pricePerDay) clothingItem.pricePerDay = pricePerDay;
        if (type) clothingItem.type = type;
        if (careInstruction) clothingItem.careInstruction = careInstruction;
        if (rentalDuration) clothingItem.rentalDuration = rentalDuration;

        // Handle new image uploads
        let newImagePaths = [];
        if (req.files && req.files.length > 0) {
            newImagePaths = req.files.map(file => `/uploads/clothing.photos/${file.filename}`);
        }

        // Handle existing images (delete if needed)
        if (parsedExistingImages && parsedExistingImages.length > 0) {
            // Delete old images that are not in the existingImages list
            const imagesToKeep = new Set(parsedExistingImages);
            const imagesToDelete = clothingItem.images.filter(img => !imagesToKeep.has(img));

            await Promise.all(imagesToDelete.map(async (imageUrl) => {
                try {
                    const filename = imageUrl.split('/').pop();
                    const filePath = path.join(__dirname, '../../uploads/clothing.photos', filename);

                    if (fs.existsSync(filePath)) {
                        await fs.promises.unlink(filePath);
                    }
                } catch (err) {
                    console.error('Error deleting image:', err);
                }
            }));

            // Update images array with kept existing images + new images
            clothingItem.images = [...parsedExistingImages, ...newImagePaths];
        } else {
            // If no existing images specified, keep old ones and add new ones
            clothingItem.images = [...clothingItem.images, ...newImagePaths];
        }

        const updatedItem = await clothingItem.save();

        res.status(200).json({
            success: true,
            data: updatedItem
        });

    } catch (error) {
        console.error('Update clothing error:', error);

        // Clean up uploaded files if error occurs
        if (req.files && req.files.length > 0) {
            req.files.forEach(file => {
                try {
                    fs.unlinkSync(file.path);
                } catch (unlinkError) {
                    console.error('Failed to delete file:', file.path, unlinkError);
                }
            });
        }

        if (error.name === 'ValidationError') {
            return res.status(400).json({
                success: false,
                message: 'Validation failed',
                errors: error.errors
            });
        }

        if (error.name === 'CastError') {
            return res.status(400).json({
                success: false,
                message: 'Invalid clothing item ID'
            });
        }

        if (error.name === 'JsonWebTokenError') {
            return res.status(401).json({
                success: false,
                message: 'Invalid token'
            });
        }

        res.status(500).json({
            success: false,
            message: 'Failed to update clothing item',
            error: error.message
        });
    }
};

export const deleteClothingItem = async (req, res) => {
    console.log('DELETE /api/clothing received');
    console.log('Headers:', req.headers);
    console.log('Params:', req.params);
    try {
        if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid clothing item ID'
            });
        }

        const authHeader = req.headers.authorization;
        if (!authHeader) {
            return res.status(401).json({
                success: false,
                message: 'Authorization token required'
            });
        }

        const token = authHeader.split(' ')[1];
        const decoded = jwt.verify(token, process.env.SECRET);

        const blacklistedToken = await BlacklistedToken.findOne({ token });
        if (blacklistedToken) {
            return res.status(401).json({
                success: false,
                message: 'Token revoked'
            });
        }

        const user = await User.findById(decoded.id);
        const id = req.params.id;
        const clothingItem = await ClothingItem.findById(id);

        if (!clothingItem) {
            return res.status(404).json({
                success: false,
                message: 'Clothing item not found'
        });

        if (clothingItem.owner.toString() !== user._id.toString() && user.role !== 'admin') {
            return res.status(403).json({
                success: false,
                message: 'Not authorized to delete this item'
            });
        }

        const imagesToDelete = clothingItem.images;

        await clothingItem.deleteOne();

        if (imagesToDelete && imagesToDelete.length > 0) {

            await Promise.all(imagesToDelete.map(async (imageUrl) => {
                try {
                    const filename = imageUrl.split('/').pop();

                    const filePath = path.join('C:/Users/LENOVO/Flutter/rent-habesha-backend/uploads/clothing.photos', filename);

                    console.log('Image URL:', imageUrl);
                    console.log('Filename:', filename);
                    console.log('Full path:', filePath);

                    if (fs.existsSync(filePath)) {
                        await fs.promises.unlink(filePath);
                    }
                } catch (err) {
                    console.error('Error deleting image:', err);
                    throw err;
                }
            }));
        }

        await Renting.deleteMany({ clothingItem: req.params.id });

        res.status(200).json({
            success: true,
            message: 'Clothing item deleted successfully'
        });}

    } catch (error) {
        console.error('Delete clothing error:', error);

        if (error.name === 'JsonWebTokenError') {
            return res.status(401).json({
                success: false,
                message: 'Invalid token'
            });
        }

        if (error.name === 'CastError') {
            return res.status(400).json({
                success: false,
                message: 'Invalid clothing item ID'
            });
        }

        res.status(500).json({
            success: false,
            message: 'Failed to delete clothing item',
            error: error.message
        });
    }
};


export const updateItemAvailability = async (req, res) => {
  try {
    const { clothingItemId } = req.params;
    const { available } = req.body;
    const userId = req.user.id;

    const item = await ClothingItem.findById(clothingItemId);

    if (!item) {
      return res.status(404).json({ message: 'Clothing item not found' });
    }

    if (item.owner.toString() !== userId) {
      return res.status(403).json({ message: 'Not authorized to update this item' });
    }

    if (available == "available") {
      item.availability = true;
    } else if (available == "not available") {
      item.availability = false;
    } else {
      return res.status(400).json({ message: 'Invalid availability status' });
    }

    await item.save();

    res.status(200).json(item);
  } catch (error) {
    console.error('Availability update error:', error);
    res.status(500).json({
      message: 'Failed to update availability',
      error: error.message
    });
  }
};