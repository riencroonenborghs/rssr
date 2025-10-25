function csrfParam() {
  return document.querySelector('meta[name="csrf-param"]').content;
}

function csrfToken() {
  return document.querySelector('meta[name="csrf-token"]').content;
}

export default { csrfParam: csrfParam, csrfToken: csrfToken };
