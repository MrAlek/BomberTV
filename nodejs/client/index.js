const raptor = require('raptor-client')
const nipplejs = require('nipplejs')

const divLeft = document.getElementById('left')
const divRight = document.getElementById('right')
const divFace = document.getElementById('face')
const spanFace = divFace.querySelector('span')

let manager = nipplejs.create({ zone: divLeft })
const client = raptor(window.location.origin.replace(/^http(s?)/, 'ws$1'))

client.send('register', { client: 'browser' })

client.send('join', null, (err, player) => {
  spanFace.textContent = player.face

  function NNmove (evt, data) {
    const x = Math.cos(data.angle.radian) * Math.min(data.force, 1.0)
    const y = Math.sin(data.angle.radian) * Math.min(data.force, 1.0)

    client.send('move', { x, y })
  }

  function NNend (evt) {
    client.send('move', { x: 0, y: 0 })
  }

  manager.on('move', NNmove)
  manager.on('end', NNend)

  divRight.addEventListener('touchstart', (ev) => {
    ev.preventDefault()

    client.send('bomb', {})
  })

  client.on('notification', function (ev) {
    if (ev.method === 'die') {
      manager.destroy()

      setTimeout(() => {
        alert('You have died, press "ok" to respawn')

        setTimeout(() => {
          manager = nipplejs.create({ zone: divLeft })
          manager.on('move', NNmove)
          manager.on('end', NNend)
          client.send('respawn', {})
        }, 1)
      }, 1)
    }
  })
})
