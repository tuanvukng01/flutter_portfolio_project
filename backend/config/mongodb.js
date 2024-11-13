// /config/mongodb.js
require('dotenv').config();
const { MongoClient } = require('mongodb');


const uri = process.env.MONGODB_URI ;

let client;
let clientPromise;

// if (!process.env.MONGODB_URI) {
//   throw new Error('Please add your MongoDB URI to the .env file');
// }

if (process.env.NODE_ENV === 'development') {
  // In development, use a global variable so the client is not constantly recreated
  if (!global._mongoClientPromise) {
    client = new MongoClient(uri);
    global._mongoClientPromise = client.connect();
  }
  clientPromise = global._mongoClientPromise;
} else {
  // In production, use a new client instance for each request
  client = new MongoClient(uri);
  clientPromise = client.connect();
}

module.exports = clientPromise;