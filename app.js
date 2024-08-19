require('dotenv').config();
const express = require('express');
const mysql = require('mysql2');
const OpenAI = require('openai'); // Using the updated OpenAI package

const app = express();
const port = 3000;

// Set up OpenAI configuration
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY, // Add your OpenAI API key to the .env file
});

// Set up MySQL database connection
const db = mysql.createConnection({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});

// Connect to the database
db.connect((err) => {
  if (err) {
    console.error('Database connection failed: ' + err.stack);
    return;
  }
  console.log('Connected to the database.');
});

// Middleware to parse JSON bodies
app.use(express.json());

// Route for natural language to SQL queries
app.post('/query', async (req, res) => {
  const userQuestion = req.body.question; // Get the natural language input from the request

  try {
    // Use OpenAI to translate the question into an SQL query
    const completion = await openai.chat.completions.create({
      model: 'gpt-3.5-turbo',
      messages: [
        { role: 'system', content: 'You are a helpful assistant that converts natural language questions into SQL queries.' },
        { role: 'user', content: `Convert this question into an SQL query: "${userQuestion}"` },
      ],
    });

    const sqlQuery = completion.choices[0].message.content.trim();
    console.log(`Generated SQL query: ${sqlQuery}`);

    // Run the SQL query against the database
    db.query(sqlQuery, (error, results) => {
      if (error) {
        console.error('SQL Query Error:', error);
        return res.status(500).send('Error executing SQL query.');
      }

      // Return the results as a JSON response
      res.json({ results });
    });
  } catch (err) {
    console.error('OpenAI API Error:', err);
    res.status(500).send(err);
  }
});

// Start the server
app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
