// 🔐 Attach Bearer token for admin access
axios.interceptors.request.use(function (config) {
  const token = localStorage.getItem("access_token"); // Store your token in browser
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

document.addEventListener('DOMContentLoaded', () => {
  loadBags();
  document.getElementById('searchInput').addEventListener('input', filterBags);
});

let allBags = [];

function loadBags() {
  const token = localStorage.getItem('access_token');
  if (!token) return alert("Please log in first.");

  axios.get('https://sustaingobackend.onrender.com/api/bags/', {
    headers: { 'Authorization': 'Bearer ' + token }
  })
  .then(res => {
    allBags = res.data;
    displayBags(allBags);
  })
  .catch(err => {
    document.getElementById('error').classList.remove('d-none');
    document.getElementById('error').textContent = 'Error loading mystery bags.';
    console.error(err);
  });
}

function displayBags(bags) {
  const tbody = document.getElementById('bagTableBody');
  tbody.innerHTML = '';

  bags.forEach(b => {
    const row = document.createElement('tr');
    row.innerHTML = `
      <td>${b.id}</td>
      <td>${b.title || '-'}</td>
      <td>${b.vendor?.name || '-'}</td>
      <td>${b.delivery ? 'Yes' : 'No'}</td>
      <td>${b.expiry_date || '-'}</td>
      <td>${b.is_active ? 'Active' : 'Inactive'}</td>
      <td>
        <button class="btn btn-sm btn-warning me-2" onclick="toggleBag(${b.id})">
          ${b.is_active ? 'Deactivate' : 'Activate'}
        </button>
        <button class="btn btn-sm btn-danger" onclick="deleteBag(${b.id})">Delete</button>
      </td>
    `;
    tbody.appendChild(row);
  });
}

function filterBags() {
  const query = document.getElementById('searchInput').value.toLowerCase();
  const filtered = allBags.filter(b =>
    b.title?.toLowerCase().includes(query)
  );
  displayBags(filtered);
}

function toggleBag(bagId) {
  const token = localStorage.getItem('access_token');
  if (!token) return alert("No token found.");

  axios.patch(`https://sustaingobackend.onrender.com/api/admin/bag/${bagId}/toggle-active/`, {}, {
    headers: { 'Authorization': 'Bearer ' + token }
  })
  .then(() => loadBags())
  .catch(err => {
    alert('Failed to toggle bag status.');
    console.error(err);
  });
}

function deleteBag(bagId) {
  const confirmDelete = confirm("Are you sure you want to delete this bag?");
  if (!confirmDelete) return;

  const token = localStorage.getItem('access_token');
  axios.delete(`https://sustaingobackend.onrender.com/api/admin/bag/${bagId}/delete/`, {
    headers: { 'Authorization': 'Bearer ' + token }
  })
  .then(() => loadBags())
  .catch(err => {
    alert('Failed to delete bag.');
    console.error(err);
  });
}
