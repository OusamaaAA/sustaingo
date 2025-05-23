document.addEventListener('DOMContentLoaded', function() {
    // Get the hamburger button and the navigation element
    const hamburger = document.querySelector('.hamburger');
    const nav = document.querySelector('nav');
  
    // Check if both elements exist before adding event listener
    if (hamburger && nav) {
      // Add click event listener to the hamburger button
      hamburger.addEventListener('click', function() {
        // Toggle the 'nav-open' class on the nav element
        nav.classList.toggle('nav-open');
      });
    } else {
      console.error("Hamburger button or Nav element not found!");
    }
  
  });