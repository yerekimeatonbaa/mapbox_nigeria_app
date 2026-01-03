const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth');

router.get('/profile', protect, async (req, res) => {
  res.json({ success: true, data: req.user });
});

router.put('/profile', protect, async (req, res) => {
  res.json({ success: true, message: 'Profile updated' });
});

router.get('/usage', protect, async (req, res) => {
  res.json({ success: true, data: req.user.usage });
});

module.exports = router;
