// Axiosのラッパー
// RailsのCSRF対策等に対応するため

import axios from 'axios'
import qs from 'qs'

const tokenElement = document.querySelector('meta[name=csrf-token]')
const instance = axios.create({
  headers: {
    'X-Requested-With': 'XMLHttpRequest',
    'X-CSRF-TOKEN': (tokenElement) ? tokenElement.content : null
  }
})

export default instance
