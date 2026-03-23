const { Sequelize } = require('sequelize');
require('dotenv').config();

/*
  Validate DATABASE_URL early
  This prevents Sequelize from crashing with unclear errors
*/
const DATABASE_URL = process.env.DATABASE_URL;

if (!DATABASE_URL) {
  console.error("CRITICAL ERROR: DATABASE_URL is missing from environment variables.");
  console.error("Make sure it exists in .env or in your hosting platform environment settings.");
  process.exit(1);
}

/*
  Validate that the URL is a proper postgres URL
*/
if (!DATABASE_URL.startsWith("postgresql://") && !DATABASE_URL.startsWith("postgres://")) {
  console.error("CRITICAL ERROR: DATABASE_URL is not a valid PostgreSQL connection string.");
  process.exit(1);
}

/*
  Create Sequelize instance
*/
const sequelize = new Sequelize(DATABASE_URL, {
  dialect: "postgres",
  logging: false,

  dialectOptions: {
    ssl: {
      require: true,
      rejectUnauthorized: false
    }
  },

  pool: {
    max: 5,
    min: 0,
    acquire: 30000,
    idle: 10000
  },

  retry: {
    max: 3
  }
});

/*
  Test connection function
  This allows server.js to call it safely
*/
async function testDatabaseConnection() {
  try {
    await sequelize.authenticate();
    console.log("Database connection established successfully.");
  } catch (error) {
    console.error("CRITICAL: Unable to connect to the database.");
    console.error(error.message);
    throw error;
  }
}

/*
  Export both sequelize and connection tester
*/
module.exports = {
  sequelize,
  testDatabaseConnection
};