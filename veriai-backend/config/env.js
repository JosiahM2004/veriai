// list of every environment variable the backend needs to function
const requiredVars = [
  'DB_HOST',
  'DB_PORT', 
  'DB_NAME',
  'DB_USER',
  'DB_PASSWORD',
  'JWT_SECRET',
  'JWT_EXPIRES_IN',
  'PORT',
];

const validateEnv = () => {
  const missing = requiredVars.filter(key => !process.env[key]);

  if (missing.length > 0) {
    console.error('Missing required environment variables:', missing.join(', '));
    // exit code 1 tells the operating system the process crashed with an error
    process.exit(1);
  }

  console.log('All environment variables loaded successfully');
};

module.exports = validateEnv;