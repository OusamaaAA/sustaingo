// 🔐 Attach Bearer token for admin access
axios.interceptors.request.use(function (config) {
  const token = localStorage.getItem("access_token"); // Store your token in browser
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

document.addEventListener('DOMContentLoaded', () => {
  loadReviews();
  document.getElementById('searchInput').addEventListener('input', filterReviews);
});

let allReviews = [];

function loadReviews() {
  const token = localStorage.getItem('access_token');
  if (!token) return alert("Please log in first.");

  axios.get('https://sustaingobackend.onrender.com/api/admin/reviews/', {
    headers: { 'Authorization': 'Bearer ' + token }
  })
  .then(res => {
    allReviews = res.data;
    displayReviews(allReviews);
  })
  .catch(err => {
    document.getElementById('error').classList.remove('d-none');
    document.getElementById('error').textContent = 'Error loading reviews.';
    console.error(err);
  });
}

function displayReviews(reviews) {
  const tbody = document.getElementById('reviewTableBody');
  tbody.innerHTML = '';

  reviews.forEach(r => {
    const row = document.createElement('tr');
    row.innerHTML = `
      <td>${r.id}</td>
      <td>${r.vendor?.name || '-'}</td>
      <td>${r.user?.email || '-'}</td>
      <td>${r.rating}</td>
      <td>${r.comment || '-'}</td>
      <td>
        <button class="btn btn-sm btn-danger" onclick="deleteReview(${r.id})">Delete</button>
      </td>
    `;
    tbody.appendChild(row);
  });
}

function filterReviews() {
  const query = document.getElementById('searchInput').value.toLowerCase();
  const filtered = allReviews.filter(r =>
    r.vendor?.name?.toLowerCase().includes(query)
  );
  displayReviews(filtered);
}

function deleteReview(reviewId) {
  const token = localStorage.getItem('access_token');
  if (!token) return;

  const confirmDelete = confirm("Are you sure you want to delete this review?");
  if (!confirmDelete) return;

  axios.delete(`https://sustaingobackend.onrender.com/api/admin/review/${reviewId}/delete/`, {
    headers: { 'Authorization': 'Bearer ' + token }
  })
  .then(() => loadReviews())
  .catch(err => {
    alert("Failed to delete review.");
    console.error(err);
  });
}
