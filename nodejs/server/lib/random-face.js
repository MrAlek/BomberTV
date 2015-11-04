'use strict'

const low = '😀'.codePointAt(0)
const high = '😾'.codePointAt(0)

module.exports = function () {
  return String.fromCodePoint(Math.floor(low + (Math.random() * (high - low))))
}
