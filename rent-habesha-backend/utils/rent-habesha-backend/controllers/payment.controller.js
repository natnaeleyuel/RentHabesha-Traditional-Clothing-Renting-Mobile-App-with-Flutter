import paymentService from '../services/payment.service.js';

export const processCheckout = async (req, res) => {
  try {
    const { paymentMethod } = req.body;
    const userId = req.user._id;

    if (!paymentMethod?.cardNumber || !paymentMethod.expiry || !paymentMethod.cvv) {
      return res.status(400).json({
        success: false,
        message: 'Invalid payment method details'
      });
    }

    const result = await paymentService.processCheckout(userId, {
      type: 'card',
      cardNumber: paymentMethod.cardNumber,
      expiry: paymentMethod.expiry,
      cvv: paymentMethod.cvc
    });

    res.status(200).json({
      success: true,
      transactionId: result.transactionId,
      rentingID: result.renting
    });

  } catch (error) {
    res.status(400).json({
      success: false,
      message: error.message
    });
  }
};