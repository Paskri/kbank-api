const { execFile } = require("child_process");

function execCobol(cmd, args = []) {
  return new Promise((resolve, reject) => {
    execFile(cmd, args, {
      maxBuffer: 5 * 1024 * 1024 // 5 MB (ou plus si besoin)
    }, (err, stdout, stderr) => {
      if (err) return reject(err);
      resolve(stdout);
    });
  });
}

module.exports = execCobol