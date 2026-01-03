const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth');

router.get('/plans', (req, res) => {
  res.json({
    success: true,
    data: [
      { id: 'monthly', name: 'Monthly Premium', price: 2000, currency: 'NGN', duration: '1 month' },
      { id: 'yearly', name: 'Yearly Premium', price: 20000, currency: 'NGN', duration: '1 year', discount: '17%' }
    ]
  });
});

router.post('/subscribe', protect, async (req, res) => {
  res.json({ success: true, message: 'Subscription endpoint - integrate Paystack here' });
});

module.exports = router;
