document.addEventListener('DOMContentLoaded', function() {
  const blockcodes = document.querySelectorAll(".highlight code[data-lang]");

  for (const bc of blockcodes) {
    const title = document.createElement("div");
    title.classList.add("code-title");
    title.innerText = bc.dataset.lang;
    bc.closest(".highlight").prepend(title);
  }
});
