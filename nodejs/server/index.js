'use strict'

const fs = require('fs')
const ws = require('ws')
const path = require('path')
const http = require('http')
const Raptor = require('raptor-rpc')

const randomFace = require('./lib/random-face')

const PORT = 4940
const ASSET_HTML = path.join(__dirname, '..', 'public', 'index.html')
const ASSET_JS = path.join(__dirname, '..', 'public', 'build.js')

const httpServer = http.createServer()
const wsServer = new ws.Server({ server: httpServer })
const raptor = new Raptor()

let playerId = 0
let appleTv = null

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
    id: playerId++,
    face: randomFace()
  }

  sendToTv({
    method: 'join',
    params: player
  })

  req.source.player = player
  cb(null, player)
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

  process.stderr.write(`\r  ${req.param('x').toFixed(4)} ${req.param('y').toFixed(4)}        `)

  cb(null)
})

raptor.method('bomb', (req, cb) => {
  sendToTv({
    method: 'bomb',
    params: {
      player: req.source.player.id
    }
  })

  process.stderr.write(`\r  BOMB!!        `)

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

httpServer.listen(PORT, () => console.log('http://localhost:' + PORT))
