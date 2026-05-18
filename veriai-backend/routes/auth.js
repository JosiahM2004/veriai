const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const pool = require('../config/db');

const router = express.Router();

// how many times bcrypt runs its hashing algorithm
const SALT_ROUNDS = 8;

//REGISTER PROCESS---

//data sent from the app when the user fills in the register form, checks the data is present and meets basic requirments before doing anything with the database
router.post('/register', async (req, res) => {
  const { email, username, password } = req.body;

  //ensure all required fields were sent
  if (!email || !username || !password) {
    return res.status(400).json({ error: 'Email, username and password are required' });
  }

  //enforce a minimum password length
  if (password.length < 8) {
    return res.status(400).json({ error: 'Password must be at least 8 characters' });
  }

  try {
    //check if the email or username is already registered
    const existing = await pool.query(
      'SELECT id FROM users WHERE email = $1 OR username = $2',
      [email.toLowerCase(), username]
    );

    if (existing.rows.length > 0) {
      return res.status(409).json({ error: 'Email or username already in use' });
    }

    //hash the password before storing it
    //bcrypt automatically generates a unique salt and embeds it in the hash
    const passwordHash = await bcrypt.hash(password, SALT_ROUNDS);

    //insert the new user and return the fields we need
    //$1 $2 $3 are parameterised placeholders that prevent SQL injection
    const result = await pool.query(
      `INSERT INTO users (email, username, password_hash)
       VALUES ($1, $2, $3)
       RETURNING id, email, username, created_at`,
      [email.toLowerCase(), username, passwordHash]
    );

    const user = result.rows[0];

    //sign a JWT so the user is immediately logged in after registering
    const token = jwt.sign(
      { userId: user.id, role: 'user' },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN }
    );

    return res.status(201).json({
      token,
      user: {
        id: user.id,
        email: user.email,
        username: user.username,
      },
    });

  } catch (err) {
    console.error('Registration error:', err);
    return res.status(500).json({ error: 'Server error during registration' });
  }
});

//LOGIN PROCESS---


router.post('/login', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password are required' });
  }

  try {
    //fetch the user by email
    const result = await pool.query(
      'SELECT id, email, username, password_hash, role FROM users WHERE email = $1',
      [email.toLowerCase()]
    );

    const user = result.rows[0];

    //return the same error whether the email doesnt exist or the password is wrong — prevents username enumeration attacks where an attacker tests emails to find which ones are registered
    if (!user) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    //compare the submitted password against the stored hash
    const passwordMatch = await bcrypt.compare(password, user.password_hash);

    if (!passwordMatch) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    //sign a new JWT for the user
    const token = jwt.sign(
      { userId: user.id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN }
    );

    return res.status(200).json({
      token,
      user: {
        id: user.id,
        email: user.email,
        username: user.username,
        role: user.role,
      },
    });

  } catch (err) {
    console.error('Login error:', err);
    return res.status(500).json({ error: 'Server error during login' });
  }
});

module.exports = router;