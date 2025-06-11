import mongoose from 'mongoose';

const cartItemSchema = new mongoose.Schema({
  clothingItem: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'ClothingItem',
    required: true
  },
  quantity: {
    type: Number,
    default: 1
  },
  startDate: Date,
  endDate: Date,
  pricePerDay: Number
});

const cartSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    unique: true
  },
  items: [cartItemSchema],
  createdAt: {
    type: Date,
    default: Date.now
  }
});

export default mongoose.model('Cart', cartSchema);