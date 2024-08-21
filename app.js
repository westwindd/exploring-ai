require('dotenv').config();
const axios = require('axios');
const express = require('express');
const OpenAI = require('openai');
const fs = require('fs');
const cors = require('cors');

const app = express();
const port = 3000;

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

app.use(cors());
app.use(express.json());

const clickupApi = axios.create({
  baseURL: 'https://api.clickup.com/api/v2',
  headers: {
    Authorization: process.env.CLICKUP_API_TOKEN,
  },
});

// Function to fetch and structure ClickUp data
async function fetchClickUpData() {
  try {
    const { data: teamsData } = await clickupApi.get('/team');
    const teams = teamsData.teams;

    if (!teams || teams.length === 0) {
      throw new Error('No teams found in ClickUp.');
    }
//return teams[1].name;
    const reportData = [];
    for (const team of teams) {
      const teamReport = { team_name: team.name, users: [] };

      const { data: spacesData } = await clickupApi.get(`/team/${team.id}/space`);
      if (!spacesData || !spacesData.spaces) continue;

      for (const space of spacesData.spaces) {
        const { data: listsData } = await clickupApi.get(`/space/${space.id}/folder`);
        if (!listsData || !listsData.folders) continue;

        for (const folder of listsData.folders) {
          const { data: lists } = await clickupApi.get(`/folder/${folder.id}/list`);
          if (!lists || !lists.lists) continue;

          for (const list of lists.lists) {
            const { data: tasksData } = await clickupApi.get(`/list/${list.id}/task`, {
              params: { status: 'open', include_closed: true },
            });

            if (!tasksData || !tasksData.tasks) continue;
              
            tasksData.tasks.forEach((task) => {
              const assignee = task.assignees && task.assignees.length > 0 ? task.assignees[0] : null;
              if (!assignee || !assignee.username) return;

              const userReport = teamReport.users.find((user) => user.user_name === assignee.username);

              if (!userReport) {
                teamReport.users.push({
                  user_name: assignee.username,
                  tasks: [{ project_name: list.name, task_name: task.name, due_date: task.due_date }],
                });
              } else {
                userReport.tasks.push({
                  project_name: list.name,
                  task_name: task.name,
                  due_date: task.due_date,
                });
              }
            });
          }
        }
      }
      reportData.push(teamReport);
    }

    // Store the structured data in a JSON file for quick access
    fs.writeFileSync('clickupData.json', JSON.stringify(reportData, null, 2));
    return reportData;
  } catch (error) {
    console.error('Error fetching ClickUp data:', error.message);
    throw new Error('Failed to fetch ClickUp data');
  }
}

// Function to generate insights for a batch of data
async function preprocessData(reportData) {
  // Preprocess and summarize data to reduce size
  return reportData.map(team => {
    // Ensure the team has a users array
    if (!team.users || !Array.isArray(team.users)) {
      return {
        team_name: team.team_name,
        total_users: 0,
        total_tasks: 0,
        users: []
      };
    }

    return {
      team_name: team.team_name,
      total_users: team.users.length,
      total_tasks: team.users.reduce((acc, user) => {
        // If user.tasks is undefined or not an array, set it to an empty array
        const tasks = Array.isArray(user.tasks) ? user.tasks : [];

        return acc + tasks.length;
      }, 0),
      users: team.users.map(user => {
        // Safeguard against user.tasks being undefined or not an array
        const tasks = Array.isArray(user.tasks) ? user.tasks : [];

        return {
          username: user.user_name,
          tasks_assigned: tasks.length,
          tasks_completed: tasks.filter(task => task.completed).length,
          projects: tasks.map(task => task.project_name)
        };
      })
    };
  });
}

async function generateInsights(preprocessedData) {
  const prompt = `
    Provide an analysis of the following summarized project data:
    ${JSON.stringify(preprocessedData, null, 2)}
    
    Include key insights such as:
    - Overall project progress
    - Task completion rates by user
    - Areas of concern
  `;

  try {
    const response = await openai.chat.completions.create({
      model: 'gpt-4',
      messages: [
        { role: 'system', content: 'You are an AI assistant providing project management insights.' },
        { role: 'user', content: prompt },
      ],
    });

    return response.choices[0].message.content.trim();
  } catch (error) {
    console.error('Error generating insights:', error.message);
    return 'Failed to generate insights.';
  }
}

// Usage within your existing endpoint
app.get('/clickup-report', async (req, res) => {
  try {
    let clickupData = [];
    if (fs.existsSync('clickupData.json')) {
      clickupData = JSON.parse(fs.readFileSync('clickupData.json', 'utf-8'));
    } else {
      clickupData = await fetchClickUpData();
    }

    console.log('Raw ClickUp Data:', clickupData); // Log the raw data to check structure

    const preprocessedData = await preprocessData(clickupData);
    const insights = await generateInsights(preprocessedData);

    res.json({ clickupData: preprocessedData, insights });
  } catch (error) {
    res.status(500).send('Error generating report.');
  }
});


app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
