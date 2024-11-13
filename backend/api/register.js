const clientPromise = require('../../config/mongodb');
const bcrypt = require('bcrypt');
require('dotenv').config();

module.exports = async (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  if (req.method === 'POST') {
    const { email, password, name } = req.body;
    if (!email || !password || !name) {
      return res.status(400).json({ error: 'Missing required fields: email, password, or name' });
    }

    try {
      const client = await clientPromise;
      const db = client.db('flutter-portfolio-project');
      const usersCollection = db.collection('users');

      const existingUser = await usersCollection.findOne({ email });
      if (existingUser) {
        return res.status(409).json({ error: 'User already exists with this email' });
      }

      const saltRounds = 10;
      const hashedPassword = await bcrypt.hash(password, saltRounds);

      const newUser = {
        email,
        password: hashedPassword,
        name,
      };

      const result = await usersCollection.insertOne(newUser);

      return res.status(201).json({
        message: 'Account created successfully',
        userId: result.insertedId,
      });
    } catch (error) {
      console.error(error);
      return res.status(500).json({ error: 'An error occurred during registration' });
    }
  } else {
    return res.status(405).json({ error: 'Method not allowed' });
  }
};