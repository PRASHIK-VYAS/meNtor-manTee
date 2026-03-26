// backend/server.js
console.log("==========================================");
console.log("ANTIGRAVITY BACKEND STARTING - v1.2.0");
console.log("==========================================");

require('dotenv').config();

const express = require('express');
const cors = require('cors');
const { sequelize, testDatabaseConnection } = require('./config/database');

const mentorRoutes = require('./routes/mentorRoutes');
const studentRoutes = require('./routes/studentRoutes');
const activityRoutes = require('./routes/activityRoutes');
const broadcastRoutes = require('./routes/broadcastRoutes');
const certificationRoutes = require('./routes/certificationRoutes');
const documentRoutes = require('./routes/documentRoutes');
const internshipRoutes = require('./routes/internshipRoutes');
const meetingRoutes = require('./routes/meetingRoutes');
const taskRoutes = require('./routes/taskRoutes');
const semesterRoutes = require('./routes/semesterRoutes');
const subjectMarkRoutes = require('./routes/subjectMarkRoutes');
const authRoutes = require('./routes/authRoutes');
const notificationRoutes = require('./routes/notificationRoutes');

const app = express();

// Middleware
app.use(cors());
app.disable('x-powered-by');
app.use(express.json({ limit: '1mb' }));
app.use(express.urlencoded({ extended: true, limit: '1mb' }));

// Health check
app.get('/health', async (req, res) => {
  try {
    await testDatabaseConnection();
    return res.status(200).json({ status: 'ok', database: 'connected' });
  } catch (error) {
    console.error("Health check DB error:", error.message);
    return res.status(503).json({ status: 'degraded', database: 'disconnected' });
  }
});

// Root route
app.get('/', (req, res) => {
  res.json({ message: 'Backend running' });
});

// Routes
app.use('/api/mentors', mentorRoutes);
app.use('/api/students', studentRoutes);
app.use('/api/activities', activityRoutes);
app.use('/api/broadcasts', broadcastRoutes);
app.use('/api/certifications', certificationRoutes);
app.use('/api/documents', documentRoutes);
app.use('/api/internships', internshipRoutes);
app.use('/api/meetings', meetingRoutes);
app.use('/api/tasks', taskRoutes);
app.use('/api/semesters', semesterRoutes);
app.use('/api/subject-marks', subjectMarkRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/notifications', notificationRoutes);

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    message: `Route not found: ${req.method} ${req.originalUrl}`
  });
});

// Error handler
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  if (res.headersSent) return next(err);

  res.status(500).json({
    message: 'Internal server error'
  });
});

const port = Number(process.env.PORT || 5000);
let server;

const startServer = async () => {
  try {
    console.log('Starting backend server initialization...');

    if (!process.env.DATABASE_URL) {
      console.error("DATABASE_URL is missing in environment variables");
      process.exit(1);
    }

    console.log('Connecting to Supabase PostgreSQL...');

    await sequelize.authenticate();

    console.log('Database connection established successfully');

    console.log('Syncing Sequelize models...');
    await sequelize.sync({ alter: true });

    console.log('Database models synced');

    // Automatically kill any existing process on the port
    const kill = require('kill-port');
    try {
      await kill(port, 'tcp');
      console.log(`Port ${port} cleared`);
    } catch (e) {
      // Ignore errors if port was already free
    }

    server = app.listen(port, () => {
      console.log(`Server running on port ${port}`);
      console.log('Backend ready to handle requests');
      
      // Start heartbeat monitor only after successful listen
      startHeartbeat();
    });

    server.on('error', (error) => {
      if (error.code === 'EADDRINUSE') {
        console.error(`Port ${port} already in use after attempt to clear. Please try again in a few seconds.`);
      } else {
        console.error('Server error:', error);
      }
      process.exit(1);
    });

  } catch (error) {
    console.error('CRITICAL: Startup failed during initialization!');
    console.error(error);
    process.exit(1);
  }
};

// Graceful shutdown
const shutdown = async (signal) => {
  console.log(`${signal} received. Closing server...`);

  try {
    if (server) {
      await new Promise((resolve) => server.close(resolve));
    }

    await sequelize.close();

    console.log("Server shutdown complete");
    process.exit(0);

  } catch (error) {
    console.error('Shutdown failed:', error.message);
    process.exit(1);
  }
};

process.on('SIGINT', () => shutdown('SIGINT'));
process.on('SIGTERM', () => shutdown('SIGTERM'));

process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection:', reason);
});

process.on('uncaughtException', (error) => {
  console.error('Uncaught Exception:', error);
  process.exit(1);
});

// Heartbeat monitor function
const startHeartbeat = () => {
  setInterval(() => {
    const memory = process.memoryUsage();

    console.log(
      `[${new Date().toISOString()}] Heartbeat - RSS: ${
        Math.round(memory.rss / 1024 / 1024)
      }MB | Heap: ${
        Math.round(memory.heapUsed / 1024 / 1024)
      }MB`
    );
  }, 10000);
};

startServer();