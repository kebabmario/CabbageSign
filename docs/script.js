// =========================================
// CabbageSign Docs — script.js
// =========================================

(function () {
  "use strict";

  // ── Active nav link on scroll ───────────
  const sections = document.querySelectorAll("section[id]");
  const navLinks = document.querySelectorAll(".nav-links a[href^='#']");

  function setActiveLink() {
    let current = "";
    const scrollY = window.scrollY + 100;

    sections.forEach((section) => {
      if (scrollY >= section.offsetTop) {
        current = section.id;
      }
    });

    navLinks.forEach((link) => {
      link.classList.toggle(
        "active",
        link.getAttribute("href") === `#${current}`
      );
    });
  }

  window.addEventListener("scroll", setActiveLink, { passive: true });
  setActiveLink();

  // ── Navbar shadow on scroll ─────────────
  const nav = document.querySelector("nav");
  window.addEventListener(
    "scroll",
    () => {
      nav.classList.toggle("scrolled", window.scrollY > 10);
    },
    { passive: true }
  );

  // ── Smooth reveal on scroll ─────────────
  const revealEls = document.querySelectorAll(
    ".card, .step, .preview-item, details, .banner"
  );

  if ("IntersectionObserver" in window) {
    const io = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.add("visible");
            io.unobserve(entry.target);
          }
        });
      },
      { threshold: 0.1 }
    );

    revealEls.forEach((el) => {
      el.classList.add("reveal");
      io.observe(el);
    });
  }
})();
