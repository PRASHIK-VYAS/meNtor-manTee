// backend/test_supabase.js
require('dotenv').config();
const { Sequelize } = require('sequelize');

const sequelize = new Sequelize(process.env.DATABASE_URL, {
    dialect: 'postgres',
    logging: console.log,
    dialectOptions: {
        ssl: {
            require: true,
            rejectUnauthorized: false,
        }
    }
});

async function testConnection() {
    try {
        console.log('Testing Supabase connection...');
        await sequelize.authenticate();
        console.log('✅ Connection has been established successfully.');
        
        // Try to list tables
        const [results, metadata] = await sequelize.query("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'");
        console.log('Found tables:', results.map(r => r.table_name).join(', '));
        
        await sequelize.close();
    } catch (error) {
        console.error('❌ Unable to connect to the database:', error.message);
        process.exit(1);
    }
}

testConnection();
