const ping = (req, res) => {
  res.status(200).json({
    status: 'ok',
    message: 'Backend is awake',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
};

module.exports = {
  ping
};
