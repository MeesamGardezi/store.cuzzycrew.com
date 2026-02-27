const { getDb } = require('../config/firebase');

function usersCol() {
  return getDb().collection('users');
}

function uniqueEmailDoc(emailLower) {
  return getDb().collection('uniqueEmails').doc(emailLower);
}

async function getByEmail(emailLower) {
  const snap = await usersCol().where('emailLower', '==', emailLower).limit(1).get();
  if (snap.empty) return null;
  const doc = snap.docs[0];
  return { id: doc.id, ...doc.data() };
}

async function getById(userId) {
  const doc = await usersCol().doc(userId).get();
  if (!doc.exists) return null;
  return { id: doc.id, ...doc.data() };
}

async function createUserWithUniqueEmail({
  userId,
  email,
  emailLower,
  passwordHash,
  role,
  firstName,
  lastName,
  nowIso,
}) {
  const db = getDb();

  await db.runTransaction(async (tx) => {
    const uniqueRef = uniqueEmailDoc(emailLower);
    const uniqueSnap = await tx.get(uniqueRef);
    if (uniqueSnap.exists) {
      const err = new Error('Email already in use');
      err.code = 'EMAIL_TAKEN';
      throw err;
    }

    tx.create(uniqueRef, { userId, emailLower, createdAt: nowIso });

    tx.create(usersCol().doc(userId), {
      email,
      emailLower,
      passwordHash,
      role,
      firstName: firstName || null,
      lastName: lastName || null,
      createdAt: nowIso,
      updatedAt: nowIso,
      deletedAt: null,
    });
  });

  return getById(userId);
}

module.exports = {
  getByEmail,
  getById,
  createUserWithUniqueEmail,
};
