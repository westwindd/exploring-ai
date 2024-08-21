<template>
    <v-container>
      <v-row>
        <v-col cols="12" md="8" offset-md="2">
          <v-card>
            <v-card-title class="text-h5">Project Data Overview</v-card-title>
            <v-card-text>
              <v-btn color="primary" @click="fetchOverviewReport">Load Overview Report</v-btn>
              <v-card-text v-if="overviewReport">
                <h4>Overview Report:</h4>
                <pre>{{ overviewReport }}</pre>
                <h4>Insights:</h4>
                <pre>{{ insights }}</pre>
              </v-card-text>
              <bar-chart v-if="chartData" :chart-data="chartData" />
            </v-card-text>
          </v-card>
        </v-col>
      </v-row>
    </v-container>
  </template>
  
  <script>
  import axios from 'axios';
  import { Bar } from 'vue-chartjs';
  
  export default {
    components: {
      BarChart: {
        extends: Bar,
        props: {
          chartData: {
            type: Object,
            required: true,
          },
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
        },
      },
    },
    data() {
      return {
        overviewReport: null,
        insights: null,
        chartData: null,
      };
    },
    methods: {
      async fetchOverviewReport() {
        try {
          const res = await axios.get('http://localhost:3000/clickup-report');
          this.overviewReport = res.data.clickupData;
          this.insights = res.data.insights;
          this.generateChartData(res.data.clickupData);
        } catch (error) {
          this.overviewReport = `Error: ${error.message}`;
        }
      },
      generateChartData(report) {
        // Dynamic chart generation from report data
        const labels = report[0]?.users.map(user => user.user_name) || [];
        const taskCounts = report[0]?.users.map(user => user.tasks.length) || [];
  
        this.chartData = {
          labels,
          datasets: [
            {
              label: 'Tasks Completed',
              backgroundColor: '#42A5F5',
              data: taskCounts,
            },
          ],
        };
      },
    },
  };
  </script>
  
  <style scoped>
  pre {
    background: #f5f5f5;
    padding: 10px;
    border-radius: 4px;
    white-space: pre-wrap;
  }
  </style>
  