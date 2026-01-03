const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth');
const SavedPlace = require('../models/SavedPlace');

// Get all saved places for user
router.get('/', protect, async (req, res) => {
  try {
    const places = await SavedPlace.find({ userId: req.user._id })
      .sort({ createdAt: -1 });
    
    res.json({
      success: true,
      count: places.length,
      data: places
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
});

// Create saved place
router.post('/', protect, async (req, res) => {
  try {
    const { name, address, latitude, longitude, category, notes } = req.body;
    
    const place = new SavedPlace({
      userId: req.user._id,
      name,
      address,
      location: {
        type: 'Point',
        coordinates: [longitude, latitude]
      },
      category,
      notes
    });
    
    await place.save();
    
    res.status(201).json({
      success: true,
      data: place
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
});

// Update saved place
router.put('/:id', protect, async (req, res) => {
  try {
    const place = await SavedPlace.findOne({
      _id: req.params.id,
      userId: req.user._id
    });
    
    if (!place) {
      return res.status(404).json({
        success: false,
        message: 'Place not found'
      });
    }
    
    Object.assign(place, req.body);
    await place.save();
    
    res.json({
      success: true,
      data: place
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
});

// Delete saved place
router.delete('/:id', protect, async (req, res) => {
  try {
    const place = await SavedPlace.findOneAndDelete({
      _id: req.params.id,
      userId: req.user._id
    });
    
    if (!place) {
      return res.status(404).json({
        success: false,
        message: 'Place not found'
      });
    }
    
    res.json({
      success: true,
      message: 'Place deleted successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
});

// Bulk sync places
router.post('/sync', protect, async (req, res) => {
  try {
    const { places } = req.body;
    
    // Delete existing places
    await SavedPlace.deleteMany({ userId: req.user._id });
    
    // Insert new places
    const savedPlaces = places.map(p => ({
      userId: req.user._id,
      name: p.name,
      address: p.address,
      location: {
        type: 'Point',
        coordinates: [p.longitude, p.latitude]
      },
      category: p.category,
      notes: p.notes
    }));
    
    await SavedPlace.insertMany(savedPlaces);
    
    res.json({
      success: true,
      message: 'Places synced successfully',
      count: savedPlaces.length
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
});

module.exports = router;
