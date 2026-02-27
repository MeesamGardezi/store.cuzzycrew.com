function sendSuccess(res, { data = {}, message = '' } = {}) {
  return res.json({ success: true, data, message });
}

module.exports = { sendSuccess };
