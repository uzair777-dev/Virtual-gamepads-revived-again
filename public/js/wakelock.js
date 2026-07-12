// Screen Wake Lock API to keep screen on
var wakeLock = null;
async function requestWakeLock() {
  try {
    if ('wakeLock' in navigator) {
      wakeLock = await navigator.wakeLock.request('screen');
      wakeLock.addEventListener('release', function() { console.log('Wake Lock released'); });
      console.log('Wake Lock is active');
    }
  } catch (err) {
    console.error('Wake Lock error:', err);
  }
}
document.addEventListener('visibilitychange', async function() {
  if (wakeLock !== null && document.visibilityState === 'visible') {
    requestWakeLock();
  }
});
requestWakeLock();
