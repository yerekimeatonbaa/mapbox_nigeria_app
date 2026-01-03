const express = require('express');
const router = express.Router();

router.get('/search', (req, res) => {
  res.json({ success: true, data: [], message: 'Business search endpoint' });
});

module.exports = router;
