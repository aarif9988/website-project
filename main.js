// main.js
// JavaScript for Portfolio Website

// Check that JavaScript is connected
console.log("Portfolio website loaded");

// Change navbar style when scrolling (safe + debounced)
const nav = document.querySelector("nav");
if (nav) {
  let scrollTimer = null;
  window.addEventListener("scroll", () => {
    if (scrollTimer) clearTimeout(scrollTimer);
    scrollTimer = setTimeout(() => {
      if (window.scrollY > 50) nav.classList.add("scrolled");
      else nav.classList.remove("scrolled");
    }, 100);
  });
}
