// 🔐 Attach Bearer token for admin access
axios.interceptors.request.use(function (config) {
  const token = localStorage.getItem("access_token"); // Store your token in browser
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

document.addEventListener('DOMContentLoaded', loadUsers);

function loadUsers() {
  const token = localStorage.getItem('access_token');
  if (!token) {
    alert("No token found. Please log in.");
    return;
  }

  axios.get('https://sustaingobackend.onrender.com/api/admin/users/', {
    headers: {
      'Authorization': 'Bearer ' + token
    }
  })
  .then(res => {
    const users = res.data;
    const tbody = document.getElementById('userTableBody');
    tbody.innerHTML = '';

    users.forEach(user => {
      const row = document.createElement('tr');
      row.innerHTML = `
        <td>${user.id}</td>
        <td>${user.email}</td>
        <td>${user.role || '-'}</td>
        <td>${user.is_active ? 'Active' : 'Blocked'}</td>
        <td>
          <button class="btn btn-sm btn-warning me-2" onclick="toggleUser(${user.id})">
            ${user.is_active ? 'Block' : 'Unblock'}
          </button>
          <button class="btn btn-sm btn-danger" onclick="deleteUser(${user.id})">Delete</button>
        </td>
      `;
      tbody.appendChild(row);
    });
  })
  .catch(err => {
    document.getElementById('error').classList.remove('d-none');
    document.getElementById('error').textContent = 'Failed to load users: ' + (err.response?.status || '');
    console.error(err);
  });
}

function toggleUser(userId) {
  const token = localStorage.getItem('access_token');
  axios.patch(`https://sustaingobackend.onrender.com/api/admin/user/${userId}/toggle-active/`, {}, {
    headers: { 'Authorization': 'Bearer ' + token }
  }).then(() => loadUsers())
    .catch(err => alert('Failed to toggle user: ' + (err.response?.status || '')));
}

function deleteUser(userId) {
  if (!confirm('Are you sure you want to delete this user?')) return;
  const token = localStorage.getItem('access_token');
  axios.delete(`https://sustaingobackend.onrender.com/api/admin/user/${userId}/delete/`, {
    headers: { 'Authorization': 'Bearer ' + token }
  }).then(() => loadUsers())
    .catch(err => alert('Failed to delete user: ' + (err.response?.status || '')));
}
