window.addEventListener('load', () => {
  if (!('Temporal' in window)) {
    console.log("Update ya browser");
    return;
  }

  function setIntervalImmediately(func, interval) {
    func();
    return setInterval(func, interval);
  }

  Array.from(
    document.getElementsByClassName("temporal")
  ).forEach(el => {
    let ts = (
      Temporal.Instant.from(el.dataset.ts)
        .toZonedDateTimeISO(Temporal.Now.timeZoneId())
    );

    let tsText = ts.toLocaleString("en-US", { dateStyle: "long", timeStyle: "short" });

    setIntervalImmediately(() => {
      let dt = ts.since(Temporal.Now.zonedDateTimeISO(), {
        largestUnit: "years",
        smallestUnit: "minutes",
      });

      let dtText = dt.abs().toLocaleString("en-US", { style: "short" });
      let relText = dt.sign == 1 ? `in ${dtText}` : `${dtText} ago`;
    
      el.innerHTML = `${tsText} (${relText})`;
    }, 30 * 1000);
  });
});
