//loads environment variables from .env before anything else runs
require('dotenv').config();

const express = require('express');
const validateEnv = require('./config/env');
const authRoutes = require('./routes/auth');
const quizRoutes = require('./routes/quiz');
const questionnaireRoutes = require('./routes/questionnaire');

//validate all environment variables are present before starting
validateEnv();

//creates the express application
const app = express();

//tells express to parse incoming JSON request bodies without this req.body would be undefined in all route handlers
app.use(express.json());

//register the auth routes under the /auth prefix, so /auth/register and /auth/login become available
app.use('/auth', authRoutes);
app.use('/quiz', quizRoutes);
app.use('/questionnaire', questionnaireRoutes);

//health check - can be called from Flutter or a browser to confirm the backened is,
//reachable before making any real requests 
app.get('/health', (req, res) => {
  res.status(200).json({ message: 'VeriAI backend is running' });
});

//start the server on the port defined in .env
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`VeriAI backend running on port ${PORT}`);
});