const { Sequelize } = require('sequelize');
require('dotenv').config();

const DATABASE_URL = process.env.DATABASE_URL;

if (!DATABASE_URL) {
  console.error("CRITICAL ERROR: DATABASE_URL is missing from environment variables.");
  console.error("Make sure it exists in .env or in your hosting platform environment settings.");
  process.exit(1);
}

if (!DATABASE_URL.startsWith("postgresql://") && !DATABASE_URL.startsWith("postgres://")) {
  console.error("CRITICAL ERROR: DATABASE_URL is not a valid PostgreSQL connection string.");
  process.exit(1);
}

function parseDatabaseUrl(connectionString) {
  try {
    return new URL(connectionString);
  } catch (error) {
    console.error("CRITICAL ERROR: DATABASE_URL could not be parsed.");
    console.error(error.message);
    process.exit(1);
  }
}

function getConnectionSummary(parsedUrl) {
  return {
    host: parsedUrl.hostname,
    port: parsedUrl.port || "5432",
    database: parsedUrl.pathname.replace(/^\//, "") || "postgres",
    username: decodeURIComponent(parsedUrl.username || "")
  };
}

function getSupabaseHints(parsedUrl) {
  const host = parsedUrl.hostname.toLowerCase();
  const username = decodeURIComponent(parsedUrl.username || "");
  const hints = [];
  const poolerMatch = host.match(/^(aws-\d+-[a-z0-9-]+)\.pooler\.supabase\.com$/);
  const directMatch = host.match(/^db\.([a-z0-9]+)\.supabase\.co$/);
  const usernameProjectRef = username.startsWith("postgres.")
    ? username.slice("postgres.".length)
    : null;

  if (poolerMatch) {
    hints.push("Detected a Supabase pooler connection.");

    if (!usernameProjectRef) {
      hints.push("Pooler usernames must use the format postgres.<project-ref>.");
    }

    if (parsedUrl.port && !["5432", "6543"].includes(parsedUrl.port)) {
      hints.push("Supabase pooler connections usually use port 5432 or 6543.");
    }
  }

  if (directMatch) {
    hints.push("Detected a direct Supabase database host.");

    if (usernameProjectRef && usernameProjectRef !== directMatch[1]) {
      hints.push(
        `The username project ref (${usernameProjectRef}) does not match the host project ref (${directMatch[1]}).`
      );
    }
  }

  return hints;
}

function logDatabaseTroubleshooting(error, parsedUrl) {
  const summary = getConnectionSummary(parsedUrl);
  const hints = getSupabaseHints(parsedUrl);
  const detailMessage =
    error.original?.message ||
    error.parent?.message ||
    error.message ||
    "No additional database error message was provided.";
  const errorCode = error.original?.code || error.parent?.code || error.code;

  console.error("Database target:", `${summary.host}:${summary.port}/${summary.database}`);
  console.error("Database user:", summary.username || "<missing>");
  console.error("Database error detail:", detailMessage);

  if (errorCode) {
    console.error("Database error code:", errorCode);
  }

  if (hints.length > 0) {
    hints.forEach((hint) => console.error("Hint:", hint));
  }

  if (/Tenant or user not found/i.test(detailMessage)) {
    console.error("Supabase rejected the tenant/user combination in DATABASE_URL.");
    console.error("Update backend/.env with the exact PostgreSQL connection string from Supabase for this project.");
  } else if (errorCode === "28P01") {
    console.error("The database password in DATABASE_URL was rejected.");
  } else if (errorCode === "ENOTFOUND") {
    console.error("The database host could not be resolved. The project ref or host may be outdated.");
  }
}

const parsedDatabaseUrl = parseDatabaseUrl(DATABASE_URL);

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

async function testDatabaseConnection() {
  try {
    await sequelize.authenticate();
    console.log("Database connection established successfully.");
  } catch (error) {
    console.error("CRITICAL: Unable to connect to the database.");
    logDatabaseTroubleshooting(error, parsedDatabaseUrl);
    throw error;
  }
}

module.exports = {
  sequelize,
  testDatabaseConnection
};
