import { Controller } from "@hotwired/stimulus"

class Loader {
  constructor () {
    this.page = 1
    this.timeout
    // calculate date in hex
    this.offset = Math.round((new Date()).getTime() / 1000).toString(16)
    this.headers = {}
    this.headers['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').content
    this.entries = document.querySelector('.entries')
  }

  loadNextPage () {
    let object = this
    if (this.timeout) { clearTimeout(this.timeout) }
    this.timeout = setTimeout(function() {
      // look up next page from offset onwards
      object.page += 1
      const url = `${window.location.search.pathname || ''}?page=${object.page}&ts=${object.offset}`

      fetch(
        url,
        {
          method: 'GET',
          headers: object.headers
        }
      ).then((result) => {
        if (result.status === 200) {
          return result.text()
        }
      }).then((body) => {
        const parser = new DOMParser()
        const html = parser.parseFromString(body, 'text/html')
        
        html.querySelectorAll('.entry').forEach((node) => {
          object.entries.appendChild(node)
        })
      })
    }, 250)
  }
}

export default class extends Controller {
  connect () {
    this.loader = new Loader()
    this.enabled = document.querySelector('.entries') !== null
  }

  scrolled (event) {
    if (!this.enabled) { return; }

    // let ch = event.target.clientHeight
    // let ct = event.target.clientTop
    // let oh = event.target.offsetHeight
    // let ot = event.target.offsetTop
    // let sh = event.target.scrollHeight
    let st = event.target.scrollTop
    let stm = event.target.scrollTopMax
    // console.log(`ch: ${ch} - ct: ${ct} - oh: ${oh} - ot: ${ot} - sh: ${sh} - st: ${st} - stm: ${stm}`)

    if (st * 1.1 > stm) {
      this.loader.loadNextPage()
    }
  }  
}
