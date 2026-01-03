const mongoose = require('mongoose');

const savedPlaceSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  name: {
    type: String,
    required: true,
    trim: true
  },
  address: {
    type: String,
    required: true
  },
  location: {
    type: {
      type: String,
      enum: ['Point'],
      default: 'Point'
    },
    coordinates: {
      type: [Number],
      required: true
    }
  },
  category: {
    type: String,
    enum: ['Home', 'Work', 'Favorite', 'Restaurant', 'Shopping', 'Other'],
    default: 'Other'
  },
  notes: {
    type: String
  },
  photos: [{
    type: String
  }],
  isPublic: {
    type: Boolean,
    default: false
  },
  syncedAt: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true
});

// Create geospatial index
savedPlaceSchema.index({ location: '2dsphere' });

// Compound index for user queries
savedPlaceSchema.index({ userId: 1, category: 1 });

module.exports = mongoose.model('SavedPlace', savedPlaceSchema);
