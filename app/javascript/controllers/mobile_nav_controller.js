import { Controller, del } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const navigation = document.querySelector('#navigation')
    let previousScrollTop = 0
    let sumDirection = 0
    let direction = 'down'

    document.querySelector('.entries').addEventListener('scroll', function (event) {
      let scrollTop = event.target.scrollTop

      if (scrollTop > previousScrollTop) {
        // if direction changed, reset the sumDirection
        // otherwise keep track of how much we've scrolled in that direction
        if (direction !== 'down') {
          direction = 'down'
          sumDirection = 0
        } else {
          sumDirection += (scrollTop - previousScrollTop)
        }
        
        if (sumDirection > 200) {
          navigation.classList.add('hidden')
        } else {
          navigation.classList.remove('hidden')
        }
      } else {
        if (direction !== 'up') {
          direction = 'up'
          sumDirection = 0
        } else {
          sumDirection += Math.abs(scrollTop - previousScrollTop)
        }

        if (sumDirection > 200) {
          navigation.classList.remove('hidden')
        } else {
          navigation.classList.add('hidden')
        }
      }

      previousScrollTop = scrollTop
      // console.log(`${direction} ${sumDirection}px`)
    })
  }
}
