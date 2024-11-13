// /api/transaction/index.js
const clientPromise = require('../../config/mongodb');
const { ObjectId } = require('mongodb');


module.exports = async (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*'); // Allow requests from any origin
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    
    // Handle OPTIONS preflight request
  if (req.method === 'OPTIONS') {
      return res.status(200).end();
    }
  const client = await clientPromise;
  const db = client.db('flutter-portfolio-project'); // Replace with your actual database name
  const transactionCollection = db.collection('transactions');

  // Check if method is GET or POST, and get userId accordingly
  const userId = req.method === 'GET' ? req.query.userId : req.body.userId;

  // Destructure only if req.method is POST to avoid errors
  let action, symbol, quantity, price;
  if (req.method === 'POST') {
    ({ action, symbol, quantity, price } = req.body || {}); // Ensure req.body exists
  }

  if (req.method === 'GET') {
    // Fetch transaction history for a user
    if (!userId) {
      return res.status(400).json({ error: 'Missing userId parameter' });
    }

    try {
      const transactions = await transactionCollection.find({ userId }).sort({ date: -1 }).toArray();
      return res.status(200).json(transactions);
    } catch (error) {
      console.error(error);
      return res.status(500).json({ error: 'An error occurred while fetching transactions' });
    }

  } else if (req.method === 'POST') {
    // Record a new transaction
    if (!userId || !symbol || !quantity || !price || (action !== 'buy' && action !== 'sell')) {
      return res.status(400).json({ error: 'Missing required fields or invalid action' });
    }

    try {
      const transaction = {
        userId,
        symbol,
        quantity,
        price,
        date: new Date(),
        isBuy: action === 'buy'
      };

      await transactionCollection.insertOne(transaction);
      return res.status(201).json({ message: 'Transaction recorded successfully', transaction });
    } catch (error) {
      console.error(error);
      return res.status(500).json({ error: 'An error occurred while recording the transaction' });
    }

  } else {
    return res.status(405).json({ error: 'Method not allowed' });
  }
};