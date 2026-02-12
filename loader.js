// loader.js
window.addEventListener('load', function() {
    const loader = document.getElementById('loading-overlay');
    
    // Minimum time (in ms) to show the loader, to ensure the "vibe" is appreciated
    const minDisplayTime = 1500; 
    
    // performance.now() returns the time elapsed since the time origin (navigation start)
    const timeSinceStart = performance.now();
    
    // If the page loaded faster than minDisplayTime, wait the difference.
    // If it took longer, hide it immediately (0 wait).
    const delay = Math.max(0, minDisplayTime - timeSinceStart);

    setTimeout(() => {
        loader.style.opacity = '0';
        setTimeout(() => {
            loader.style.display = 'none';
        }, 500); // Wait for the fade out transition
    }, delay);
});
