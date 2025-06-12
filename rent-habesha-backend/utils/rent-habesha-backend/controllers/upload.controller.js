import { singleUpload } from '../utils/upload.js';
import path from 'path';

export const uploadSingleImage = (req, res) => {
  singleUpload(req, res, (err) => {
    if (err) {
      return res.status(400).json({
        success: false,
        message: err.message
      });
    }

    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'No file uploaded'
      });
    }

    res.status(200).json({
      success: true,
      imageUrl: `/uploads/clothing.photos/${req.file.filename}`,
      filename: req.file.filename
    });
  });
};