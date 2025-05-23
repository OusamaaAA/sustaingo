// 🔐 Attach Bearer token for admin access
axios.interceptors.request.use(function (config) {
  const token = localStorage.getItem("access_token"); // Store your token in browser
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});


const BASE_URL = "https://sustaingobackend.onrender.com";

document.addEventListener("DOMContentLoaded", function () {
  loadVendorReservationsChart();
  loadVendorRatingChart();
  loadReservationTrendsChart();
  loadPaymentChart();
  loadReservationStatusChart();
  loadBagStatusChart();
  loadBagsPerVendorChart();
  loadMostReviewedVendorsChart();
  loadUserRoleChart();
  loadNgoRegionChart();
  loadNewUserTrendChart();
});

async function loadVendorReservationsChart() {
  const res = await axios.get(`${BASE_URL}/api/vendor-analytics/`);
  const data = res.data;

  const labels = data.map(v => v.name);
  const reservations = data.map(v => v.reservations);

  new Chart(document.getElementById('vendorReservationsChart'), {
    type: 'bar',
    data: {
      labels: labels,
      datasets: [{
        label: 'Reservations',
        data: reservations,
        backgroundColor: 'rgba(54, 162, 235, 0.7)'
      }]
    },
    options: {
      responsive: true,
      plugins: {
        title: { display: true, text: 'Reservations per Vendor' },
        legend: { display: false }
      }
    }
  });
}

async function loadVendorRatingChart() {
  const res = await axios.get(`${BASE_URL}/api/review-analytics/`);
  const data = res.data.avg_ratings;

  const labels = Object.keys(data);
  const ratings = Object.values(data);

  new Chart(document.getElementById('vendorRatingChart'), {
    type: 'bar',
    data: {
      labels: labels,
      datasets: [{
        label: 'Average Rating',
        data: ratings,
        backgroundColor: 'rgba(255, 206, 86, 0.7)'
      }]
    },
    options: {
      indexAxis: 'y',
      scales: { x: { min: 0, max: 5 } },
      plugins: {
        title: { display: true, text: 'Average Ratings per Vendor' },
        legend: { display: false }
      }
    }
  });
}

async function loadReservationTrendsChart() {
  const res = await axios.get(`${BASE_URL}/api/reservation-analytics/`);
  const data = res.data;

  const labels = Object.keys(data.daily_counts);
  const values = Object.values(data.daily_counts);

  new Chart(document.getElementById('reservationTrendsChart'), {
    type: 'line',
    data: {
      labels: labels,
      datasets: [{
        label: 'Reservations',
        data: values,
        fill: true,
        tension: 0.3,
        backgroundColor: 'rgba(75,192,192,0.2)',
        borderColor: 'rgba(75,192,192,1)'
      }]
    },
    options: {
      responsive: true,
      plugins: {
        title: { display: true, text: 'Daily Reservation Count (Last 30 Days)' },
        legend: { display: false }
      }
    }
  });
}

async function loadPaymentChart() {
  const res = await axios.get(`${BASE_URL}/api/reservation-analytics/`);
  const data = res.data;

  new Chart(document.getElementById('paymentChart'), {
    type: 'doughnut',
    data: {
      labels: ['Paid', 'Unpaid'],
      datasets: [{
        data: [data.paid, data.unpaid],
        backgroundColor: ['#4caf50', '#f44336']
      }]
    },
    options: {
      plugins: {
        title: { display: true, text: 'Payment Status Breakdown' }
      }
    }
  });
}

async function loadReservationStatusChart() {
  const res = await axios.get(`${BASE_URL}/api/reservation-analytics/`);
  const data = res.data;

  const labels = Object.keys(data.status_counts);
  const values = Object.values(data.status_counts);

  new Chart(document.getElementById('reservationStatusChart'), {
    type: 'bar',
    data: {
      labels: labels,
      datasets: [{
        label: 'Reservations',
        data: values,
        backgroundColor: 'rgba(255, 159, 64, 0.7)'
      }]
    },
    options: {
      plugins: {
        title: { display: true, text: 'Reservation Status Distribution' },
        legend: { display: false }
      }
    }
  });
}

async function loadBagStatusChart() {
  const res = await axios.get(`${BASE_URL}/api/bag-analytics/`);
  const data = res.data;

  new Chart(document.getElementById('bagStatusChart'), {
    type: 'pie',
    data: {
      labels: ['Active', 'Expired'],
      datasets: [{
        data: [data.active, data.expired],
        backgroundColor: ['#4caf50', '#f44336']
      }]
    },
    options: {
      plugins: {
        title: { display: true, text: 'Active vs Expired Bags' }
      }
    }
  });
}

async function loadBagsPerVendorChart() {
  const res = await axios.get(`${BASE_URL}/api/bag-analytics/`);
  const vendorData = res.data.bags_per_vendor;

  const labels = Object.keys(vendorData);
  const values = Object.values(vendorData);

  new Chart(document.getElementById('bagsPerVendorChart'), {
    type: 'bar',
    data: {
      labels: labels,
      datasets: [{
        label: 'Bag Count',
        data: values,
        backgroundColor: 'rgba(153, 102, 255, 0.7)'
      }]
    },
    options: {
      plugins: {
        title: { display: true, text: 'Bags Listed per Vendor' },
        legend: { display: false }
      },
      responsive: true
    }
  });
}

async function loadMostReviewedVendorsChart() {
  const res = await axios.get(`${BASE_URL}/api/review-analytics/`);
  const data = res.data.review_counts;

  const labels = Object.keys(data);
  const values = Object.values(data);

  new Chart(document.getElementById('mostReviewedChart'), {
    type: 'bar',
    data: {
      labels: labels,
      datasets: [{
        label: 'Review Count',
        data: values,
        backgroundColor: 'rgba(54, 162, 235, 0.7)'
      }]
    },
    options: {
      plugins: {
        title: { display: true, text: 'Most Reviewed Vendors' },
        legend: { display: false }
      }
    }
  });
}

async function loadUserRoleChart() {
  const res = await axios.get(`${BASE_URL}/api/user-analytics/`);
  const data = res.data.role_counts;

  const labels = Object.keys(data);
  const values = Object.values(data);

  new Chart(document.getElementById('userRoleChart'), {
    type: 'pie',
    data: {
      labels: labels,
      datasets: [{
        data: values,
        backgroundColor: ['#4caf50', '#2196f3', '#ff9800']
      }]
    },
    options: {
      plugins: {
        title: { display: true, text: 'User Role Distribution' }
      }
    }
  });
}

async function loadNgoRegionChart() {
  const res = await axios.get(`${BASE_URL}/api/user-analytics/`);
  const data = res.data.ngo_regions;

  const labels = Object.keys(data);
  const values = Object.values(data);

  new Chart(document.getElementById('ngoRegionChart'), {
    type: 'bar',
    data: {
      labels: labels,
      datasets: [{
        label: 'NGOs',
        data: values,
        backgroundColor: 'rgba(255, 99, 132, 0.7)'
      }]
    },
    options: {
      plugins: {
        title: { display: true, text: 'NGOs by Region' },
        legend: { display: false }
      }
    }
  });
}

async function loadNewUserTrendChart() {
  const res = await axios.get(`${BASE_URL}/api/user-analytics/`);
  const data = res.data.new_users;

  const labels = Object.keys(data);
  const values = Object.values(data);

  new Chart(document.getElementById('newUserChart'), {
    type: 'line',
    data: {
      labels: labels,
      datasets: [{
        label: 'New Users',
        data: values,
        borderColor: 'rgba(0, 123, 255, 0.7)',
        fill: true,
        tension: 0.3
      }]
    },
    options: {
      plugins: {
        title: { display: true, text: 'New User Registrations (Last 30 Days)' },
        legend: { display: false }
      }
    }
  });
}
