const clientPromise = require('../../config/mongodb');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
require('dotenv').config();
const SECRET_KEY = process.env.SECRET_KEY;

module.exports = async (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  if (req.method === 'POST') {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ error: 'Missing email or password' });
    }

    try {
      const client = await clientPromise;
      const db = client.db('flutter-portfolio-project');
      const usersCollection = db.collection('users');
      
      const user = await usersCollection.findOne({ email });
      if (!user) {
        return res.status(404).json({ error: 'User not found' });
      }

      const isPasswordValid = await bcrypt.compare(password, user.password);
      if (!isPasswordValid) {
        return res.status(401).json({ error: 'Invalid password' });
      }

      const token = jwt.sign({ id: user._id }, SECRET_KEY, { expiresIn: '1h' });

      return res.status(200).json({
        message: 'Login successful',
        userId: user._id,
        token,
      });
    } catch (error) {
      console.error(error);
      return res.status(500).json({ error: 'An error occurred during login' });
    }
  } else {
    return res.status(405).json({ error: 'Method not allowed' });
  }
};