// 🔐 Attach Bearer token for admin access
axios.interceptors.request.use(function (config) {
  const token = localStorage.getItem("access_token"); // Store your token in browser
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});



document.addEventListener('DOMContentLoaded', () => {
  loadReservations();
  document.getElementById('searchInput').addEventListener('input', filterReservations);
});

let allReservations = [];

function loadReservations() {
  const token = localStorage.getItem('access_token');
  if (!token) return alert("Please log in first.");

  axios.get('https://sustaingobackend.onrender.com/api/admin/reservations/', {
    headers: { 'Authorization': 'Bearer ' + token }
  })
  .then(res => {
    allReservations = res.data;
    displayReservations(allReservations);
  })
  .catch(err => {
    document.getElementById('error').classList.remove('d-none');
    document.getElementById('error').textContent = 'Error loading reservations.';
    console.error(err);
  });
}

function displayReservations(reservations) {
  const tbody = document.getElementById('reservationTableBody');
  tbody.innerHTML = '';

  reservations.forEach(r => {
    const row = document.createElement('tr');
    row.innerHTML = `
      <td>${r.id}</td>
      <td>${r.vendor_name || '-'}</td>
      <td>${r.bag_title || '-'}</td>
      <td>${r.bag_contents || '-'}</td>
      <td>$${parseFloat(r.price_paid).toFixed(2)}</td>
      <td>${r.payment_method}</td>
      <td>${r.is_collected ? 'Collected' : 'Pending'}</td>
      <td>${r.reserved_at.split('T')[0]}</td>
      <td>
        ${r.is_collected ? '' : `<button class="btn btn-sm btn-primary me-2" onclick="markCollected(${r.id})">Mark Collected</button>`}
        <button class="btn btn-sm btn-danger" onclick="deleteReservation(${r.id})">Delete</button>
      </td>
    `;
    tbody.appendChild(row);
  });
}

function filterReservations() {
  const query = document.getElementById('searchInput').value.toLowerCase();
  const filtered = allReservations.filter(r =>
    r.vendor_name?.toLowerCase().includes(query)
  );
  displayReservations(filtered);
}

function markCollected(reservationId) {
  const token = localStorage.getItem('access_token');
  axios.patch(`https://sustaingobackend.onrender.com/api/reservations/${reservationId}/collected/`, {}, {
    headers: { 'Authorization': 'Bearer ' + token }
  })
  .then(() => loadReservations())
  .catch(err => {
    alert('Failed to mark as collected.');
    console.error(err);
  });
}

function deleteReservation(reservationId) {
  const confirmDelete = confirm("Are you sure you want to delete this reservation?");
  if (!confirmDelete) return;

  const token = localStorage.getItem('access_token');
  axios.delete(`https://sustaingobackend.onrender.com/api/admin/reservation/${reservationId}/delete/`, {
    headers: { 'Authorization': 'Bearer ' + token }
  })
  .then(() => loadReservations())
  .catch(err => {
    alert("Failed to delete reservation.");
    console.error(err);
  });
}
