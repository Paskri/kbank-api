const { execFile } = require("child_process");

function execCobol(cmd, args = []) {
  return new Promise((resolve, reject) => {
    execFile(cmd, args, (err, stdout) => {
      if (err) return reject(err);
      resolve(stdout);
    });
  });
}

module.exports = execCobol