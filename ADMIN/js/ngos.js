// 🔐 Attach Bearer token for admin access
axios.interceptors.request.use(function (config) {
  const token = localStorage.getItem("access_token"); // Store your token in browser
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

document.addEventListener('DOMContentLoaded', () => {
  loadNGOs();
  document.getElementById('searchInput').addEventListener('input', filterNGOs);
});

let allNGOs = [];

function loadNGOs() {
  const token = localStorage.getItem('access_token');
  if (!token) return alert("Please log in first.");

  axios.get('https://sustaingobackend.onrender.com/api/public_ngos/', {
    headers: { 'Authorization': 'Bearer ' + token }
  })
  .then(res => {
    allNGOs = res.data;
    displayNGOs(allNGOs);
  })
  .catch(err => {
    document.getElementById('error').classList.remove('d-none');
    document.getElementById('error').textContent = 'Error loading NGOs.';
    console.error(err);
  });
}

function displayNGOs(ngos) {
  const tbody = document.getElementById('ngoTableBody');
  tbody.innerHTML = '';

  ngos.forEach(n => {
    const row = document.createElement('tr');
    row.innerHTML = `
      <td>${n.organization_name || '-'}</td>
      <td>${n.region || '-'}</td>
      <td>${n.phone_number || '-'}</td>
      <td>${n.email || '-'}</td>
      <td>${n.description || '-'}</td>
      <td>
        <button class="btn btn-sm btn-danger" onclick="deleteNGO('${n.email}')">Delete</button>
      </td>
    `;
    tbody.appendChild(row);
  });
}

function filterNGOs() {
  const query = document.getElementById('searchInput').value.toLowerCase();
  const filtered = allNGOs.filter(n =>
    n.organization_name?.toLowerCase().includes(query)
  );
  displayNGOs(filtered);
}

function deleteNGO(email) {
  const token = localStorage.getItem('access_token');
  if (!token) return;

  const confirmDelete = confirm(`Delete NGO with email: ${email}?`);
  if (!confirmDelete) return;

  axios.delete(`https://sustaingobackend.onrender.com/api/admin/ngo/${email}/delete/`, {
    headers: { 'Authorization': 'Bearer ' + token }
  })
  .then(() => loadNGOs())
  .catch(err => {
    alert("Failed to delete NGO.");
    console.error(err);
  });
}
