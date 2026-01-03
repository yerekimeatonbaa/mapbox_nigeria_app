const express = require('express');
const router = express.Router();
const { protect, requireAdmin } = require('../middleware/auth');

router.get('/stats', protect, requireAdmin, (req, res) => {
  res.json({ success: true, data: { users: 0, premium: 0, revenue: 0 } });
});

module.exports = router;
