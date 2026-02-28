window.addEventListener("load", () => {
  Array.from(document.getElementsByClassName("tablesort")).forEach((el) => {
    new Tablesort(el);
  });
});
