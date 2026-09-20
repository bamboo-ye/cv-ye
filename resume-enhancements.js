(() => {
    const root = document.documentElement;
    const motionButton = document.querySelector('.motion-toggle');
    const motionLabel = motionButton?.querySelector('span');
    const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)');
    const finePointer = window.matchMedia('(hover: hover) and (pointer: fine)');
    let userPaused = false;
    try { userPaused = localStorage.getItem('cv-motion') === 'off'; } catch { /* Storage may be unavailable. */ }

    function syncMotion() {
        const enabled = !reducedMotion.matches && !userPaused;
        root.dataset.motion = enabled ? 'on' : 'off';
        if (!motionButton) return;
        motionButton.hidden = false;
        motionButton.disabled = reducedMotion.matches;
        motionButton.setAttribute('aria-checked', String(enabled));
        motionButton.title = reducedMotion.matches ? '已跟随系统的减少动态效果设置' : '切换页面动画，设置仅保存在此浏览器';
        motionLabel.textContent = reducedMotion.matches ? '已减少动效' : enabled ? '动效开启' : '动效关闭';
    }

    motionButton?.addEventListener('click', () => {
        userPaused = !userPaused;
        try { localStorage.setItem('cv-motion', userPaused ? 'off' : 'on'); } catch { /* The toggle still works without persistence. */ }
        syncMotion();
    });
    reducedMotion.addEventListener('change', syncMotion);
    syncMotion();

    // A read-progress line is updated only in response to scrolling or resizing.
    let progressFrame = 0;
    function updateProgress() {
        progressFrame = 0;
        const available = root.scrollHeight - innerHeight;
        const progress = available > 0 ? Math.min(1, Math.max(0, scrollY / available)) : 0;
        root.style.setProperty('--reading-progress', progress);
    }
    function queueProgress() {
        if (!progressFrame) progressFrame = requestAnimationFrame(updateProgress);
    }
    window.addEventListener('scroll', queueProgress, { passive: true });
    window.addEventListener('resize', queueProgress, { passive: true });
    window.addEventListener('load', queueProgress, { once: true });
    updateProgress();

    // Decorative pointer light; no pointer work is done on touch devices or in static mode.
    const strengths = document.querySelector('.hero-strengths');
    let lightFrame = 0;
    let pointerX = 0;
    let pointerY = 0;
    strengths?.addEventListener('pointermove', event => {
        if (!finePointer.matches || root.dataset.motion === 'off') return;
        pointerX = event.clientX;
        pointerY = event.clientY;
        if (lightFrame) return;
        lightFrame = requestAnimationFrame(() => {
            lightFrame = 0;
            if (root.dataset.motion === 'off') return;
            const bounds = strengths.getBoundingClientRect();
            strengths.style.setProperty('--spot-x', `${pointerX - bounds.left}px`);
            strengths.style.setProperty('--spot-y', `${pointerY - bounds.top}px`);
        });
    }, { passive: true });
    strengths?.addEventListener('pointerleave', () => {
        cancelAnimationFrame(lightFrame);
        lightFrame = 0;
    });

    // Without JavaScript every scenario remains readable; tabs progressively enhance it.
    document.querySelectorAll('.scene-showcase').forEach(showcase => {
        const tablist = showcase.querySelector('.scene-tabs');
        const tabs = [...showcase.querySelectorAll('.scene-tab')];
        const panels = tabs.map(tab => document.getElementById(tab.dataset.scene));
        if (!tablist || !tabs.length || panels.some(panel => !panel)) return;

        function selectScene(index, moveFocus = false) {
            tabs.forEach((tab, i) => {
                const active = i === index;
                tab.setAttribute('aria-selected', String(active));
                tab.tabIndex = active ? 0 : -1;
                panels[i].hidden = !active;
            });
            if (moveFocus) tabs[index].focus();
        }

        tablist.setAttribute('role', 'tablist');
        tabs.forEach((tab, index) => {
            tab.setAttribute('role', 'tab');
            tab.setAttribute('aria-controls', panels[index].id);
            panels[index].setAttribute('role', 'tabpanel');
            panels[index].setAttribute('aria-labelledby', tab.id);
            panels[index].tabIndex = 0;
            tab.addEventListener('click', () => selectScene(index));
            tab.addEventListener('keydown', event => {
                let next;
                if (event.key === 'ArrowRight') next = (index + 1) % tabs.length;
                if (event.key === 'ArrowLeft') next = (index + tabs.length - 1) % tabs.length;
                if (event.key === 'Home') next = 0;
                if (event.key === 'End') next = tabs.length - 1;
                if (next === undefined) return;
                event.preventDefault();
                selectScene(next, true);
            });
        });
        selectScene(0);
        showcase.dataset.enhanced = 'true';
    });
})();
