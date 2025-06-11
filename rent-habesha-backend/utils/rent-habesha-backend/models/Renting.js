import mongoose from 'mongoose';

const rentingSchema = new mongoose.Schema({
  clothingItem: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'ClothingItem',
    required: true
  },
  renter: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  owner: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  startDate: {
    type: Date,
    required: true
  },
  endDate: {
    type: Date,
    required: true
  },
  totalPrice: {
    type: Number,
    required: true
  },
  status: {
    type: String,
    enum: ['pending', 'completed', 'available'],
    default: 'pending'
  },
  paymentStatus: {
    type: String,
    enum: ['pending', 'paid', 'failed'],
    default: 'pending'
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  paymentMethod: {
    type: String,
    enum: ['card'],
    required: true
  },
  cardLast4: String,
  transactionId: String,
  paidAt: Date
}, {
  timestamps: true
});

rentingSchema.index({ clothingItem: 1 });
rentingSchema.index({ renter: 1 });
rentingSchema.index({ owner: 1 });
rentingSchema.index({ status: 1 });

rentingSchema.index(
  { clothingItem: 1, startDate: 1, endDate: 1 },
  { unique: true, partialFilterExpression: { status: { $in: ['pending', 'completed'] } }}
);

const Renting = mongoose.model('Renting', rentingSchema);

export default Renting;