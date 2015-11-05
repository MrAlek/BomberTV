'use strict'

const fs = require('fs')
const ws = require('ws')
const path = require('path')
const http = require('http')
const Raptor = require('raptor-rpc')
const padLeft = require('pad-left')
const logUpdate = require('log-update')

const randomFace = require('./lib/random-face')

const PORT = 4940
const ASSET_HTML = path.join(__dirname, '..', 'public', 'index.html')
const ASSET_JS = path.join(__dirname, '..', 'public', 'build.js')

const httpServer = http.createServer()
const wsServer = new ws.Server({ server: httpServer })
const raptor = new Raptor()
const screen = logUpdate.create(process.stderr)

let playerId = 0
let appleTv = null

let allThemPlayers = []

function refreshScreen () {
  function formatLine (face, dx, dy, bomb) {
    return (
      ` ${face}  ` +
      padLeft(dx.toFixed(4), 7, ' ') + '  ' +
      padLeft(dy.toFixed(4), 7, ' ') + '  ' +
      (bomb ? 'BOMB' : '')
    )
  }

  let lines = []

  lines.push('http://localhost:' + PORT)
  lines.push('--------------------------')

  if (appleTv) {
    lines.push(' 📺  Apple TV')
  }

  for (let player of allThemPlayers) {
    const state = player.lastState

    lines.push(formatLine(player.face, state.dx, state.dy, state.bomb))
  }

  screen(lines.join('\n'))
}

setInterval(refreshScreen, 1000 / 10) // 10 FPS

function sendToTv (obj) {
  if (appleTv === null) return

  appleTv.websocket.send(JSON.stringify(obj))
}

raptor.method('register', (req, cb) => {
  req.require('client', 'string')
  req.source.type = req.param('client')

  if (req.source.type === 'tv') appleTv = req.source

  cb(null)
})

raptor.method('join', (req, cb) => {
  const player = {
    id: String(playerId++),
    face: randomFace(),
    lastState: { dx: 0, dy: 0, bomb: false },
    websocket: req.source.websocket
  }
  const publicPlayer = {
    id: player.id,
    face: player.face
  }

  allThemPlayers.push(player)

  sendToTv({
    method: 'join',
    params: publicPlayer
  })

  req.source.player = player
  cb(null, publicPlayer)
})

raptor.method('move', (req, cb) => {
  sendToTv({
    method: 'move',
    params: {
      player: req.source.player.id,
      x: req.param('x'),
      y: req.param('y')
    }
  })

  req.source.player.lastState.dx = req.param('x')
  req.source.player.lastState.dy = req.param('y')

  cb(null)
})

raptor.method('bomb', (req, cb) => {
  if (req.source.player.lastState.bomb) return

  sendToTv({
    method: 'bomb',
    params: {
      player: req.source.player.id
    }
  })

  req.source.player.lastState.bomb = true
  setTimeout(() => { req.source.player.lastState.bomb = false }, 2000)

  cb(null)
})

raptor.method('die', (req, cb) => {
  req.require('player', 'string')

  const playerId = req.param('player')
  const player = allThemPlayers.find((p) => p.id === playerId)

  if (!player) return

  player.websocket.send(JSON.stringify({
    method: 'die',
    params: {}
  }))
})

raptor.method('respawn', (req, cb) => {
  sendToTv({
    method: 'respawn',
    params: {
      player: req.source.player.id
    }
  })
})

raptor.method('close', (req, cb) => {
  if (req.source === appleTv) appleTv = null

  if (req.source.player) {
    const idx = allThemPlayers.indexOf(req.source.player)
    allThemPlayers.splice(idx, 1)

    sendToTv({
      method: 'leave',
      params: {
        player: req.source.player.id
      }
    })
  }

  cb(null)
})

wsServer.on('connection', (client) => {
  const raptorClient = raptor.connection()

  raptorClient.setSource({ websocket: client })

  client.on('message', (raw) => {
    let data = JSON.parse(raw)

    data['jsonrpc'] = '2.0'

    raptorClient.handleObject(data, function (err, response) {
      if (err) throw err

      if (response) client.send(JSON.stringify(response))
    })
  })

  client.on('close', () => {
    let data = { jsonrpc: '2.0', method: 'close', params: {}}

    raptorClient.handleObject(data, function (err) {
      if (err) console.error(err.stack)
    })
  })
})

httpServer.on('request', (req, res) => {
  switch (req.url) {
    case '/':
      res.setHeader('Content-Type', 'text/html; charset=utf-8')
      fs.createReadStream(ASSET_HTML).pipe(res)
      break
    case '/build.js':
      res.setHeader('Content-Type', 'text/css; charset=utf-8')
      fs.createReadStream(ASSET_JS).pipe(res)
      break
    default:
      res.status = 404
      res.end('')
  }
})

httpServer.listen(PORT)
