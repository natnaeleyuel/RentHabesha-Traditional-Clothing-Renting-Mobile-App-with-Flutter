import mongoose from 'mongoose';

const clothingItemSchema = new mongoose.Schema({
   title: {
      type: String,
      required: true
   },
   description: {
      type: String,
      required: true
   },
   owner: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
   },
   pricePerDay: {
      type: Number,
      required: true
   },
   images: [{ type: String }],
   type: {
      type: String,
      enum: ['Men', 'Women', 'Kids'],
      required: true
   },
   availability: {
      type: Boolean,
      default: true
   },
   location: {
      type: String,
      required: true
   },
   careInstruction: {
      type: String,
      required: true
   },
   rentalDuration: {
      type: String,
      enum: ['1 day', '3 days', '1 week', '2 weeks', '1 month'],
      required: true
   },
   createdAt: {
      type: Date,
      default: Date.now
   },
});

export default mongoose.model('ClothingItem', clothingItemSchema);