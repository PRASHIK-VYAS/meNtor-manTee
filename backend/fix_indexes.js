require('dotenv').config();
const { sequelize } = require('./model');

async function cleanIndexes() {
  try {
    console.log('Connecting to database...');
    await sequelize.authenticate();
    
    const tables = ['mentors', 'students'];
    
    for (const table of tables) {
      console.log(`\nFetching indexes for ${table} table...`);
      const [results] = await sequelize.query(`SHOW INDEX FROM ${table}`);
      
      // Group by column name
      const indexesByColumn = {};
      for (const idx of results) {
        if (idx.Key_name === 'PRIMARY') continue; // Don't mess with primary keys
        
        if (!indexesByColumn[idx.Column_name]) {
          indexesByColumn[idx.Column_name] = [];
        }
        indexesByColumn[idx.Column_name].push(idx);
      }
      
      console.log(`Found ${results.length} total indexes in ${table}.`);
      
      let duplicateCount = 0;
      for (const [column, indexes] of Object.entries(indexesByColumn)) {
        if (indexes.length > 1) {
          console.log(`Found ${indexes.length} indexes on column ${column} in ${table}. Removing duplicates...`);
          // Keep the first one, drop the rest
          const duplicates = indexes.slice(1);
          
          for (const idx of duplicates) {
            console.log(`Dropping index: ${idx.Key_name}`);
            try {
              await sequelize.query(`ALTER TABLE ${table} DROP INDEX \`${idx.Key_name}\``);
              duplicateCount++;
            } catch (err) {
              console.error(`Failed to drop index ${idx.Key_name}:`, err.message);
            }
          }
        }
      }
      
      if (duplicateCount > 0) {
        console.log(`Successfully removed ${duplicateCount} duplicate indexes from ${table}.`);
      } else {
        console.log(`No duplicate indexes found in ${table}.`);
      }
    }
    
  } catch (error) {
    console.error('Error:', error);
  } finally {
    await sequelize.close();
  }
}

cleanIndexes();
