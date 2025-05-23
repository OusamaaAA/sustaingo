document.getElementById('loginForm').addEventListener('submit', async function (e) {
  e.preventDefault();
  const email = document.getElementById('email').value.trim();
  const password = document.getElementById('password').value;

  try {
    const response = await fetch('https://sustaingobackend.onrender.com/api/login/', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ username: email, password })
    });

    const data = await response.json();

    if (!response.ok) {
      throw new Error(data.detail || 'Login failed');
    }

    if (!data.is_staff) {
      throw new Error('Access denied. Not an admin.');
    }

    localStorage.setItem('access_token', data.access);
    localStorage.setItem('refresh_token', data.refresh);
    window.location.href = 'dashboard.html';

  } catch (err) {
    const errorBox = document.getElementById('error');
    errorBox.textContent = err.message;
    errorBox.classList.remove('d-none');
  }
});

// Add this logout function
function logout() {
  // Clear all auth-related data
  localStorage.removeItem('access_token');
  localStorage.removeItem('refresh_token');
  
  // Always redirect to root login page
  window.location.href = 'login.html';
}

// Make logout function available globally
window.logout = logout;