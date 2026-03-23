require('dotenv').config();
const express = require('express');
const path = require('path');

const app = express();
const port = process.env.PORT || 3000;

// Host the build output directory
app.use(express.static(path.join(__dirname, 'build', 'web')));

// Any path should fallback to the index.html
app.get(/(.*)/, (req, res) => {
  res.sendFile(path.join(__dirname, 'build', 'web', 'index.html'));
});

app.listen(port, () => {
  console.log(`Server listening on port ${port}`);
});
