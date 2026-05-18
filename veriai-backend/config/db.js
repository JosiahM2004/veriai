// loads the environment variables from the .env file
require('dotenv').config();

const { Pool } = require('pg');

// creates a pool of reusable database connections using the .env variables
// a pool is used instead of a single connection so multiple requests can be handled at the same time without queuing
const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
});

// test the connection when the server starts so I know immediately if something is wrong with the database credentials
pool.connect((err, client, release) => {
  if (err) {
    console.error('Error connecting to the database:', err.message);
  } else {
    console.log('Successfully connected to the veriai database');
    // release the client back to the pool after the test
    release();
  }
});

// export the pool so any other file can import it and run queries
module.exports = pool;