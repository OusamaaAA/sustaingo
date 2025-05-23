// Check if user is authenticated
export function isAuthenticated() {
  return !!localStorage.getItem('access_token');
}

// Redirect to login if not authenticated
export function requireAuth() {
  if (!isAuthenticated()) {
    window.location.href = 'login.html';
  }
}

// Get auth headers for API calls
export function getAuthHeaders() {
  return {
    'Authorization': `Bearer ${localStorage.getItem('access_token')}`
  };
}

// Logout function
export function logout() {
  console.log('Logout function called');
  localStorage.removeItem('access_token');
  localStorage.removeItem('refresh_token');
  window.location.replace('login.html');
}
window.logout = logout;