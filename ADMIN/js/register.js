// 🔐 Attach Bearer token for admin access
axios.interceptors.request.use(function (config) {
  const token = localStorage.getItem("access_token"); // Store your token in browser
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

document.getElementById("role").addEventListener("change", () => {
  const role = document.getElementById("role").value;
  document.getElementById("ngoFields").classList.toggle("d-none", role !== "ngo");
  document.getElementById("vendorFields").classList.toggle("d-none", role !== "vendor");
});

document.getElementById("registerForm").addEventListener("submit", async (e) => {
  e.preventDefault();
  const full_name = document.getElementById("full_name").value;
  const email = document.getElementById("email").value;
  const phone = document.getElementById("phone").value;
  const role = document.getElementById("role").value;
  const password = document.getElementById("password").value;
  const confirm_password = document.getElementById("confirm_password").value;
  const message = document.getElementById("message");

  try {
    const registerRes = await axios.post("https://sustaingobackend.onrender.com/api/register/", {
      full_name,
      email,
      phone,
      role,
      password,
      confirm_password
    });

    const access_token = registerRes.data.access;

    if (role === "ngo") {
      await axios.post("https://sustaingobackend.onrender.com/api/create_ngo_profile/", {
        organization_name: document.getElementById("organization_name").value,
        region: document.getElementById("region").value,
        description: document.getElementById("ngo_description").value,
        website: document.getElementById("website").value,
        logo: document.getElementById("ngo_logo").value
      }, {
        headers: { Authorization: "Bearer " + access_token }
      });
    }

    if (role === "vendor") {
      await axios.post("https://sustaingobackend.onrender.com/api/create_vendor_profile/", {
        name: document.getElementById("vendor_name").value,
        description: document.getElementById("vendor_description").value,
        delivery_time_minutes: document.getElementById("delivery_time_minutes").value,
        delivery_available: document.getElementById("delivery_available").value === "true",
        logo: document.getElementById("vendor_logo").value
      }, {
        headers: { Authorization: "Bearer " + access_token }
      });
    }

    message.innerHTML = `<div class="alert alert-success">Successfully registered <strong>${role}</strong> and created profile.</div>`;
    document.getElementById("registerForm").reset();
    document.getElementById("ngoFields").classList.add("d-none");
    document.getElementById("vendorFields").classList.add("d-none");
  } catch (err) {
    console.error(err);
    const msg = err.response?.data?.detail || "Something went wrong.";
    message.innerHTML = `<div class="alert alert-danger">${msg}</div>`;
  }
});