export const ownerCheck = (req, res, next) => {
  if (req.user.role !== 'owner') {
    return res.status(403).json({ success: false, message: 'Only clothing owners can perform this action' });
  }
  next();
};

export const adminCheck = (req, res, next) => {
  if (req.user.role !== 'admin') {
    return res.status(403).json({ success: false, message: 'Admin access required' });
  }
  next();
};