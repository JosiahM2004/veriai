const express = require('express');
const pool = require('../config/db');
const authenticate = require('../middleware/authenticate');

const router = express.Router();

const isValidCategory = (type) => ['formal', 'informal'].includes(type);

//fetch all questions for the selected category type
//category type is passed as a URL parameter. for example: /quiz/content/formal
router.get('/content/:categoryType', authenticate, async (req, res) => {
  const { categoryType } = req.params;

  //reject any category type that isnt formal or informal
  if (!['formal', 'informal'].includes(categoryType)) {
    return res.status(400).json({ error: 'Invalid category type' });
  }

  try {
    //join quiz_content with categories to filter by category type
    //ORDER BY RANDOM() means questions come back in a different order each time
    const result = await pool.query(
      `SELECT qc.id, qc.content_text, qc.ai_generated, qc.explanation, qc.content_type
       FROM quiz_content qc
       JOIN categories c ON qc.category_id = c.id
       WHERE c.type = $1
       ORDER BY RANDOM()`,
      [categoryType]
    );

    return res.status(200).json({ content: result.rows });

  } catch (err) {
    console.error('Error fetching quiz content:', err);
    return res.status(500).json({ error: 'Server error fetching content' });
  }
});

//save a users answers to the database
//requires content_id and user_answer in the request body
router.post('/attempt', authenticate, async (req, res) => {
  const { content_id, user_answer, user_explanation } = req.body;
  const userId = req.user.userId;

  if (content_id === undefined || user_answer === undefined) {
    return res.status(400).json({ error: 'content_id and user_answer are required' });
  }

  try {
    // fetch the correct answer and category from the database
    const contentResult = await pool.query(
      'SELECT ai_generated, category_id FROM quiz_content WHERE id = $1',
      [content_id]
    );

    if (contentResult.rows.length === 0) {
      return res.status(404).json({ error: 'Content not found' });
    }

    const content = contentResult.rows[0];

    // compare the users answer against the ground truth
    const isCorrect = user_answer === content.ai_generated;

    // save the attempt to user_attempts
    await pool.query(
      `INSERT INTO user_attempts (user_id, content_id, user_answer, user_explanation, is_correct)
       VALUES ($1, $2, $3, $4, $5)`,
      [userId, content_id, user_answer, user_explanation || null, isCorrect]
    );

    //upsert pattern - if this is the user's first attempt, a new row is inserted,
    //if the users has attempted beforehand the existing row is updated
    await pool.query(
      `INSERT INTO category_progress (user_id, category_id, total_attempts, correct_answers)
       VALUES ($1, $2, 1, $3)
       ON CONFLICT (user_id, category_id)
       DO UPDATE SET
         total_attempts = category_progress.total_attempts + 1,
         correct_answers = category_progress.correct_answers + $3`,
      [userId, content.category_id, isCorrect ? 1 : 0]
    );

    return res.status(201).json({ is_correct: isCorrect });

  } catch (err) {
    console.error('Error saving attempt:', err);
    return res.status(500).json({ error: 'Server error saving attempt' });
  }
});

//get the logged in users progress per category
router.get('/progress', authenticate, async (req, res) => {
  const userId = req.user.userId;

  try {
    // join category_progress with categories to get the category name
    const result = await pool.query(
      `SELECT c.name, c.type, cp.total_attempts, cp.correct_answers
       FROM category_progress cp
       JOIN categories c ON cp.category_id = c.id
       WHERE cp.user_id = $1`,
      [userId]
    );

    return res.status(200).json({ progress: result.rows });

  } catch (err) {
    console.error('Error fetching progress:', err);
    return res.status(500).json({ error: 'Server error fetching progress' });
  }
});

module.exports = router;