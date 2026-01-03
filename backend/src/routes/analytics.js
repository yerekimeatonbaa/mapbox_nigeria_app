const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth');

router.post('/event', protect, (req, res) => {
  res.json({ success: true, message: 'Event tracked' });
});

module.exports = router;
