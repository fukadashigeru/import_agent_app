import { enter, leave } from './transitions'

document.addEventListener('click', (e) => {
    const clicked = e.target.closest('[data-modal-open]')
    if (clicked) {
        const targetSelector = clicked.getAttribute('data-modal-open')
        const target = document.querySelector(targetSelector)
        open(target)
    }
})

document.addEventListener('click', (e) => {
    const clicked = e.target.closest('[data-modal-close]')
    if (clicked) {
        const targetSelector = clicked.getAttribute('data-modal-close')
        if (targetSelector) {
            const target = document.querySelector(targetSelector)
            close(target)
        } else {
            const target = clicked.closest('[data-modal]')
            close(target)
        }
    }
})

function open (target) {
    // const overlay = document.getElementById('slideover-overlay')

    if (target) {
        enter(target, {
            // active: ['transform', 'transition', 'ease-in-out', 'duration-200'],
            // from: ['translate-x-full'],
            // to: ['translate-x-0']
        })
        // enter(overlay, {
        //     active: ['transition-opacity', 'ease-in-out', 'duration-200'],
        //     from: ['opacity-0'],
        //     to: ['opacity-100']
        // })
        // document.body.classList.add('overflow-hidden')
    }
}

function close (target) {
    // const overlay = document.getElementById('slideover-overlay')

    if (target) {
        leave(target, {
            // start: ['transform', 'transition', 'ease-in-out', 'duration-200'],
            // from: ['translate-x-0'],
            // to: ['translate-x-full']
        })
        // leave(overlay, {
        //     start: ['transition-opacity', 'ease-in-out', 'duration-200'],
        //     from: ['opacity-100'],
        //     to: ['opacity-0']
        // })
        // document.body.classList.remove('overflow-hidden')
    }
}
