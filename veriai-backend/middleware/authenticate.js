const jwt = require('jsonwebtoken');

//this function runs before any protected route handler it checks the request has a valid JWT token before allowing access
const authenticate = (req, res, next) => {

  // tokens are sent in the Authorisation header in this format:
  // "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  const authHeader = req.headers.authorization;

  // reject the request immediately if no token was provided
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'No token provided' });
  }

  // split "Bearer <token>" and take just the token part
  const token = authHeader.split(' ')[1];

  try {
    //jwt.verify checks two things:
    //1. the token was signed with JWT_SECRET so it hasnt been tampered with
    //2. the token hasnt expired based on the JWT_EXPIRES_IN value
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    //attach the decoded payload to the request so route handlers can access req.user.userId to know who is making the request
    req.user = decoded;

    //pass control to the next function in the chain (the route handler)
    next();

  } catch (err) {
    //catches both expired tokens and tampered tokens
    return res.status(401).json({ error: 'Invalid or expired token' });
  }
};

module.exports = authenticate;