// /api/stock/index.js
require('dotenv').config();
const clientPromise = require('../../config/mongodb');
const axios = require('axios');

module.exports = async (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  const symbol = req.query.symbol; // Use query parameter for symbol
  const apiKey = process.env.API_KEY;
  const baseUrl = 'https://api.polygon.io';

  if (!symbol) {
    return res.status(400).json({ error: 'Stock symbol is required' });
  }

  try {
    if (req.method === 'GET') {
      // Fetch current price for the stock
      const currentPriceUrl = `${baseUrl}/v2/aggs/ticker/${symbol}/prev?apiKey=${apiKey}`;
      const currentResponse = await axios.get(currentPriceUrl);

      if (currentResponse.status !== 200 || !currentResponse.data.results || currentResponse.data.results.length === 0) {
        console.error(`Current price data error:`, currentResponse.data);
        throw new Error('Failed to fetch current stock data');
      }
      const currentPrice = currentResponse.data.results[0].c;

      // Fetch historical prices for the last 1 year
      const endDate = new Date().toISOString().split('T')[0];
      const startDate = new Date(new Date().setFullYear(new Date().getFullYear() - 1)).toISOString().split('T')[0];
      const historyUrl = `${baseUrl}/v2/aggs/ticker/${symbol}/range/1/day/${startDate}/${endDate}?apiKey=${apiKey}`;
      const historyResponse = await axios.get(historyUrl);

      if (historyResponse.status !== 200 || !historyResponse.data.results) {
        console.error(`History data error:`, historyResponse.data);
        throw new Error('Failed to fetch historical stock data');
      }

      const priceHistory = historyResponse.data.results.map(entry => ({
        date: new Date(entry.t).toISOString().split('T')[0],
        close: entry.c
      }));

      const stockData = {
        symbol,
        currentPrice,
        priceHistory
      };

      return res.status(200).json(stockData);
    } else {
      return res.status(405).json({ error: 'Method not allowed' });
    }
  } catch (error) {
    console.error(error);
    return res.status(500).json({ error: 'An error occurred while fetching stock data' });
  }
};