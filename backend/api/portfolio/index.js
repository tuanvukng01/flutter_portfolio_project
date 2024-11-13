// /api/portfolio/index.js
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
  const portfolioCollection = db.collection('portfolios');
  const transactionCollection = db.collection('transactions'); // Ensure transactions are logged here

  // Separate logic for GET and POST methods
  if (req.method === 'GET') {
    const userId = req.query.userId;

    if (!userId) {
      return res.status(400).json({ error: 'Missing userId parameter' });
    }

    try {
      // Fetch the user's portfolio
      const portfolio = await portfolioCollection.findOne({ userId });

      if (!portfolio) {
        return res.status(404).json({ error: 'Portfolio not found' });
      }

      return res.status(200).json({
        message: 'Portfolio details retrieved successfully',
        portfolio
      });
    } catch (error) {
      console.error(error);
      return res.status(500).json({ error: 'An error occurred while retrieving the portfolio' });
    }

  } else if (req.method === 'POST') {
    // POST method logic for buy/sell actions
    const { userId, action, symbol, quantity, currentPrice } = req.body;

    if (!userId || !symbol || !quantity || !currentPrice) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    try {
      // Fetch or create the user's portfolio
      let portfolio = await portfolioCollection.findOne({ userId });
      if (!portfolio) {
        portfolio = {
          userId,
          stocks: [],
          availableFunds: 10000, // Initial fund amount
          totalValue: 0
        };
        await portfolioCollection.insertOne(portfolio);
      }

      // Find the stock in the portfolio
      const stockIndex = portfolio.stocks.findIndex(stock => stock.symbol === symbol);
      const stock = portfolio.stocks[stockIndex];
      let updatedFunds = portfolio.availableFunds;

      if (action === 'buy') {
        const totalCost = currentPrice * quantity;
        if (totalCost > updatedFunds) {
          return res.status(400).json({ error: 'Insufficient funds' });
        }

        updatedFunds -= totalCost;
        if (stock) {
          stock.quantity += quantity;
          stock.currentPrice = currentPrice;
        } else {
          portfolio.stocks.push({
            symbol,
            quantity,
            currentPrice,
            priceHistory: []
          });
        }

        await transactionCollection.insertOne({
          userId,
          symbol,
          quantity,
          price: currentPrice,
          date: new Date(),
          isBuy: true
        });

      } else if (action === 'sell') {
        if (!stock || stock.quantity < quantity) {
          return res.status(400).json({ error: 'Insufficient stock quantity' });
        }

        updatedFunds += currentPrice * quantity;
        stock.quantity -= quantity;

        if (stock.quantity === 0) {
          portfolio.stocks.splice(stockIndex, 1);
        }

        await transactionCollection.insertOne({
          userId,
          symbol,
          quantity,
          price: currentPrice,
          date: new Date(),
          isBuy: false
        });
      } else {
        return res.status(400).json({ error: 'Invalid action' });
      }

      const updatedTotalValue = portfolio.stocks.reduce((acc, stock) => {
        return acc + (stock.currentPrice * stock.quantity);
      }, updatedFunds);

      await portfolioCollection.updateOne(
        { userId },
        { $set: { stocks: portfolio.stocks, availableFunds: updatedFunds, totalValue: updatedTotalValue } }
      );

      return res.status(200).json({
        message: `${action} transaction successful`,
        portfolio: { stocks: portfolio.stocks, availableFunds: updatedFunds, totalValue: updatedTotalValue }
      });

    } catch (error) {
      console.error(error);
      return res.status(500).json({ error: 'An error occurred while processing the transaction' });
    }
  } else {
    return res.status(405).json({ error: 'Method not allowed' });
  }
};