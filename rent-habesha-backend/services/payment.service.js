import Cart from '../models/Cart.js';
import Renting from '../models/Renting.js';
import ClothingItem from '../models/ClothingItem.js';

const paymentService = {
  processCheckout: async (userId, paymentMethod) => {
    try {
      const cart = await Cart.findOne({ user: userId }).populate('items.clothingItem');
      if (!cart || cart.items.length === 0) {
        throw new Error('Cart is empty');
      }

      for (const item of cart.items) {
        const clothing = await ClothingItem.findById(item.clothingItem._id);
        if (!clothing.availability) {
          throw new Error(`${item.clothingItem.title} is no longer available`);
        }
      }

      const renting = await Promise.all(cart.items.map(async (item) => {
        const days = Math.ceil((item.endDate - item.startDate) / (1000 * 60 * 60 * 24));
        const totalPrice = days * item.pricePerDay;

        return await Renting.create({
          clothingItem: item.clothingItem._id,
          renter: userId,
          owner: item.clothingItem.owner,
          startDate: item.startDate,
          endDate: item.endDate,
          totalPrice,
          paymentMethod,
          cardLast4: paymentMethod.cardNumber.slice(-4),
          paymentStatus: 'pending'
        });
      }));

      await new Promise(resolve => setTimeout(resolve, 1500));
      const isSuccess = Math.random() < 0.85;

      if (!isSuccess) {
        throw new Error('Payment failed: Insufficient funds');
      }

      const transactionId = `txn_${Math.random().toString(36).substring(2, 15)}`;
      await Renting.updateMany(
        { _id: { $in: bookings.map(b => b._id) } },
        {
          paymentStatus: 'paid',
          transactionId,
          paidAt: new Date()
        }
      );

      await ClothingItem.updateMany(
        { _id: { $in: cart.items.map(i => i.clothingItem._id) } },
        { availability: false }
      );

      await Cart.deleteOne({ user: userId });

      return {
        success: true,
        transactionId,
        renting: renting.map(b => b._id)
      };

    } catch (error) {
      await Booking.updateMany(
        { renter: userId, paymentStatus: 'pending' },
        { paymentStatus: 'failed' }
      );
      throw error;
    }
  }
};

export default paymentService;