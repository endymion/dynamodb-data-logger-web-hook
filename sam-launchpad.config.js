const join = require('path').join;

module.exports = {
  "project_name": "wireless-social-web-hook",
  "single_project": true,
  "base_path": join( __dirname ),
  "template_parameters": {
  },
  "commands": {
    "build": "exit 0",
    "test": "npm i && npm test"
  },
  "hooks": {
  }
}