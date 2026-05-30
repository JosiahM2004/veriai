const express = require('express');
const router = express.Router();
const pool = require('../config/db');
const authenticateToken = require('../middleware/authenticate');

router.use(authenticateToken);

//GET /questionnaire/status
router.get('/status', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id FROM questionnaire_responses WHERE user_id = $1',
      [req.user.userId]
    );
    res.status(200).json({ completed: result.rows.length > 0 });
  } catch (err) {
    console.error('Error checking questionnaire status:', err.message);
    res.status(500).json({ error: 'Server error' });
  }
});

//POST /questionnaire/submit
router.post('/submit', async (req, res) => {
  const { q1_score, q2_score, q3_score, q4_score, q5_score } = req.body;

  //check all five scores were sent 
  if (
    q1_score == null || q2_score == null || q3_score == null ||
    q4_score == null || q5_score == null
  ) {
    return res.status(400).json({ error: 'All five question scores are required' });
  }

  try {
    const result = await pool.query(
      `INSERT INTO questionnaire_responses 
        (user_id, q1_score, q2_score, q3_score, q4_score, q5_score)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING total_score`,
      [req.user.userId, q1_score, q2_score, q3_score, q4_score, q5_score]
    );

    res.status(201).json({
      message: 'Questionnaire submitted successfully',
      total_score: result.rows[0].total_score,
    });

  } catch (err) {
    //23505 is postgres unique constraint violation — user already submitted
    if (err.code === '23505') {
      return res.status(409).json({ error: 'Questionnaire already completed' });
    }
    console.error('Error submitting questionnaire:', err.message);
    res.status(500).json({ error: 'Server error' });
  }
});

router.get('/responses', async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT q1_score, q2_score, q3_score, q4_score, q5_score
       FROM questionnaire_responses
       WHERE user_id = $1`,
      [req.user.userId]
    );

    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'No questionnaire responses found' });
    }

    res.status(200).json({ responses: result.rows[0] });

  } catch (err) {
    console.error('Error fetching questionnaire responses:', err.message);
    res.status(500).json({ error: 'Server error' });
  }
});
module.exports = router;