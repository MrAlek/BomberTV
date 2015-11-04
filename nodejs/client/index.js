const raptor = require('raptor-client')
const nipplejs = require('nipplejs')

const divLeft = document.getElementById('left')
const divRight = document.getElementById('right')
const divFace = document.getElementById('face')
const spanFace = divFace.querySelector('span')

const manager = nipplejs.create({ zone: divLeft })
const client = raptor(window.location.origin.replace(/^http(s?)/, 'ws$1'))

client.send('register', { client: 'browser' })

client.send('join', null, (err, player) => {
  spanFace.textContent = player.face

  manager.on('move', (evt, data) => {
    const x = Math.cos(data.angle.radian) * Math.min(data.force, 1.0)
    const y = Math.sin(data.angle.radian) * Math.min(data.force, 1.0)

    client.send('move', { x, y })
  })

  divRight.addEventListener('touchdown', (ev) => {
    ev.preventDefault()

    client.send('bomb', {})
  })
})
