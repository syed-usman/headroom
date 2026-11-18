// Headroom Interactive App & Terminal Showcase

// Mock Tab Switching
function switchMockTab(tabName) {
  // Update nav buttons
  const tabs = document.querySelectorAll('.mock-tab');
  tabs.forEach(tab => tab.classList.remove('active'));

  // Update content sections
  const contents = document.querySelectorAll('.mock-tab-content');
  contents.forEach(content => content.classList.remove('active'));

  const activeContent = document.getElementById(`tab-${tabName}`);
  if (activeContent) {
    activeContent.classList.add('active');
  }

  // Find clicked button
  event.currentTarget.classList.add('active');
}

// Terminal Tab Switching
function switchTermTab(cmdName) {
  const tabs = document.querySelectorAll('.term-tab');
  tabs.forEach(tab => tab.classList.remove('active'));

  const bodies = document.querySelectorAll('.term-body');
  bodies.forEach(body => body.classList.remove('active'));

  const activeBody = document.getElementById(`term-${cmdName}`);
  if (activeBody) {
    activeBody.classList.add('active');
  }

  event.currentTarget.classList.add('active');
}

// Copy Terminal Command
function copyInstallCmd() {
  const cmd = document.getElementById('install-cmd').innerText;
  navigator.clipboard.writeText(cmd).then(() => {
    const box = document.querySelector('.terminal-copy-box');
    const originalText = document.getElementById('install-cmd').innerText;
    document.getElementById('install-cmd').innerText = 'Copied to clipboard! ✓';
    box.style.borderColor = '#00e676';
    setTimeout(() => {
      document.getElementById('install-cmd').innerText = originalText;
      box.style.borderColor = '';
    }, 2000);
  });
}

// Direct Download Handler
document.addEventListener('DOMContentLoaded', () => {
  const downloadButtons = document.querySelectorAll('.download-trigger');
  downloadButtons.forEach(btn => {
    btn.addEventListener('click', (e) => {
      // Create feedback indicator on button
      const originalText = btn.innerHTML;
      btn.style.opacity = '0.85';
      setTimeout(() => {
        btn.style.opacity = '1';
      }, 1000);
    });
  });
});
