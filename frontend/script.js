// Simple JS placeholder for future interactivity.
// Example: reveal an alert when a menu item is clicked.

document.addEventListener("DOMContentLoaded", () => {
    document.querySelectorAll(".menu-item").forEach(card => {
      card.addEventListener("click", () => {
        const dish = card.textContent.trim();
        alert(`Hungry for ${dish}? It's one of our favorites!`);
      });
    });
  });
  