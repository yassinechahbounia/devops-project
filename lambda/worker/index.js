'use strict';

exports.handler = async (event) => {
  const records = event?.Records ?? [];

  for (const r of records) {
    console.log('messageId:', r.messageId);
    console.log('body:', r.body);
  }

  return { ok: true, received: records.length };
};
