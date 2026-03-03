const admin = require('firebase-admin');
const fs = require('fs');

let db;

function initFirebase(config) {
  if (admin.apps.length) {
    db = admin.firestore();
    return db;
  }

  const { serviceAccountPath, serviceAccountJson, projectId, storageBucket } = config.firebase;
  const bucket = storageBucket || (projectId ? `${projectId}.appspot.com` : undefined);

  if (serviceAccountJson) {
    const credential = admin.credential.cert(JSON.parse(serviceAccountJson));
    admin.initializeApp({ credential, projectId, ...(bucket ? { storageBucket: bucket } : {}) });
  } else if (serviceAccountPath) {
    try {
      const json = fs.readFileSync(serviceAccountPath, 'utf8');
      const credential = admin.credential.cert(JSON.parse(json));
      admin.initializeApp({ credential, projectId, ...(bucket ? { storageBucket: bucket } : {}) });
    } catch (e) {
      const err = new Error(
        `Failed to read Firebase service account file at ${serviceAccountPath}. ` +
          'On serverless (e.g. Vercel) use FIREBASE_SERVICE_ACCOUNT_JSON instead.'
      );
      err.cause = e;
      throw err;
    }
  } else {
    admin.initializeApp({ projectId, ...(bucket ? { storageBucket: bucket } : {}) });
  }

  db = admin.firestore();
  db.settings({ ignoreUndefinedProperties: true });

  return db;
}

function getDb() {
  if (!db) throw new Error('Firestore not initialized. Call initFirebase() first.');
  return db;
}

module.exports = { initFirebase, getDb, admin };
