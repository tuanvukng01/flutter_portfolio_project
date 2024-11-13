const bcrypt = require('bcrypt');

async function hashPassword(password) {
  const saltRounds = 10; // Number of salt rounds for bcrypt
  const hashedPassword = await bcrypt.hash(password, saltRounds);
  console.log("Hashed password:", hashedPassword);
}

hashPassword('123456'); // Replace 'your_password_here' with your chosen password