
document.addEventListener('DOMContentLoaded', () => {
  loadDashboardStats();
});

function loadDashboardStats() {
  const token = localStorage.getItem('access_token');
  if (!token) {
    alert("No token found. Please log in.");
    return;
  }

  axios.get('https://sustaingobackend.onrender.com/api/admin-dashboard-stats/', {
    headers: {
      'Authorization': 'Bearer ' + token
    }
  })
  .then(res => {
    const data = res.data;
    const stats = [
      { title: 'Total Users', value: data.total_users, color: 'primary' },
      { title: 'Total Vendors', value: data.total_vendors, color: 'warning' },
      { title: 'Total NGOs', value: data.total_ngos, color: 'success' },
      { title: 'Mystery Bags', value: data.total_bags, color: 'info' },
      { title: 'Reservations', value: data.total_reservations, color: 'secondary' },
      { title: 'Donated Bags', value: data.donated_bags, color: 'danger' },
    ];
    const container = document.getElementById('dashboard');
    container.innerHTML = '';
    stats.forEach(stat => {
      const col = document.createElement('div');
      col.className = 'col-md-4';
      col.innerHTML = `
        <div class="card border-start border-4 border-${stat.color} shadow-sm p-3">
          <h5>${stat.title}</h5>
          <h2 class="text-${stat.color}">${stat.value}</h2>
        </div>
      `;
      container.appendChild(col);
    });
  })
  .catch(err => {
    console.error(err);
    alert('Failed to load dashboard stats.');
  });
}
