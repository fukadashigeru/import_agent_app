import tippy from 'tippy.js'
import 'tippy.js/animations/perspective.css';
import 'tippy.js/dist/tippy.css';

document.addEventListener('mouseover', (e) => {
  const mouseTarget = document.getElementById('questionAboutFirstPriority');
  if (mouseTarget) {
    tippy(mouseTarget, {
      content: "第1希望の買付先にチェックを入れてください。",
    });
  }
})
