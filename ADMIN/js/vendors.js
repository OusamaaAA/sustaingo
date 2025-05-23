// 🔐 Attach Bearer token for admin access
axios.interceptors.request.use(function (config) {
  const token = localStorage.getItem("access_token"); // Store your token in browser
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

document.addEventListener('DOMContentLoaded', () => {
  loadVendors();
  document.getElementById('searchInput').addEventListener('input', filterVendors);
});

let allVendors = [];

function loadVendors() {
  const token = localStorage.getItem('access_token');
  if (!token) return alert("Please log in first.");

  axios.get('https://sustaingobackend.onrender.com/api/vendors/', {
    headers: { 'Authorization': 'Bearer ' + token }
  })
  .then(res => {
    allVendors = res.data;
    displayVendors(allVendors);
  })
  .catch(err => {
    document.getElementById('error').classList.remove('d-none');
    document.getElementById('error').textContent = 'Error loading vendors.';
    console.error(err);
  });
}

function displayVendors(vendors) {
  const tbody = document.getElementById('vendorTableBody');
  tbody.innerHTML = '';

  vendors.forEach(v => {
    const row = document.createElement('tr');
    row.innerHTML = `
      <td>${v.id}</td>
      <td>${v.name || '-'}</td>
      <td>${v.delivery_available ? 'Yes' : 'No'}</td>
      <td>${v.delivery_time_minutes || 'N/A'} min</td>
      <td>${v.average_rating?.toFixed(1) || 'N/A'}</td>
      <td>${v.description || '-'}</td>
      <td>
        <button class="btn btn-sm btn-danger" onclick="deleteVendor(${v.id})">Delete</button>
      </td>
    `;
    tbody.appendChild(row);
  });
}

function filterVendors() {
  const query = document.getElementById('searchInput').value.toLowerCase();
  const filtered = allVendors.filter(v =>
    v.name?.toLowerCase().includes(query)
  );
  displayVendors(filtered);
}

function deleteVendor(vendorId) {
  const token = localStorage.getItem('access_token');
  if (!token) return;

  const confirmDelete = confirm("Are you sure you want to delete this vendor?");
  if (!confirmDelete) return;

  axios.delete(`https://sustaingobackend.onrender.com/api/admin/vendor/${vendorId}/delete/`, {
    headers: { 'Authorization': 'Bearer ' + token }
  })
  .then(() => loadVendors())
  .catch(err => {
    alert("Failed to delete vendor.");
    console.error(err);
  });
}
