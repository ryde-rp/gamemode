function createNotify(ntype, ntime, mesaj, customIcon) {
  var nid = Math.floor(Math.random() * Date.now());
  var nicon = "fas fa-info";

  if (ntype != "info") {
    nicon = (ntype == "error") ? "fas fa-ban" : "fas fa-check"

    if (ntype == "warning") {
      nicon = "fas fa-triangle-exclamation"
    }
  }

  let notifData = `

  <div class="main__notify-item ${ntype || 'info'}" id="notification_${nid}">
    <div class="main__notify-grid">
        <div class="main__nofity-icon-container ${ntype || 'info'}"><i class="${customIcon || nicon}"></i></div>
        <div class="main__nofity-text-container">
            <div class="main__notify-text-title">Notificare</div>
            <div class="main__notify-text-description">${mesaj || 'Textul notificarii nu a fost gasit!'}</div>
        </div>
    </div>
  </div
  
  `

  $('.main__notify-container').append(notifData);

  var sound = new Audio("sounds/notificari.mp3");
  sound.volume = 0.4;
  sound.play();

  if (!ntime || (ntime < 5000)){
    ntime = 5000;
  };

  setTimeout(() => {
    anime({
      targets: `#notification_${nid}`,
      left: '30vh',
      duration: 750,
      easing: 'spring(5, 80, 5, 0)'
    })

    setTimeout(function () {
        $(`#notification_${nid}`).remove()
    }, 750)
  }, ntime);
}