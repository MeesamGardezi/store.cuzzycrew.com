class FakeSnapshot {
  constructor({ id, data, exists }) {
    this.id = id;
    this._data = data;
    this.exists = exists;
  }

  data() {
    return this._data;
  }
}

class FakeDocRef {
  constructor(db, collectionName, id) {
    this.db = db;
    this.collectionName = collectionName;
    this.id = id;
  }

  async get() {
    const collection = this.db._getCollection(this.collectionName);
    if (!collection.has(this.id)) {
      return new FakeSnapshot({ id: this.id, data: undefined, exists: false });
    }

    return new FakeSnapshot({
      id: this.id,
      data: { ...collection.get(this.id) },
      exists: true,
    });
  }

  async set(data, options = {}) {
    const collection = this.db._getCollection(this.collectionName);
    const current = collection.get(this.id) || {};
    collection.set(this.id, options.merge ? { ...current, ...data } : { ...data });
  }

  async create(data) {
    const collection = this.db._getCollection(this.collectionName);
    if (collection.has(this.id)) {
      throw new Error(`Document ${this.collectionName}/${this.id} already exists`);
    }
    collection.set(this.id, { ...data });
  }
}

class FakeQuery {
  constructor(db, collectionName, filters = [], order = null, limitValue = null, startAfterId = null) {
    this.db = db;
    this.collectionName = collectionName;
    this.filters = filters;
    this.order = order;
    this.limitValue = limitValue;
    this.startAfterId = startAfterId;
  }

  where(field, op, value) {
    return new FakeQuery(this.db, this.collectionName, [...this.filters, { field, op, value }], this.order, this.limitValue, this.startAfterId);
  }

  orderBy(field, direction = 'asc') {
    return new FakeQuery(this.db, this.collectionName, this.filters, { field, direction }, this.limitValue, this.startAfterId);
  }

  limit(value) {
    return new FakeQuery(this.db, this.collectionName, this.filters, this.order, value, this.startAfterId);
  }

  startAfter(snapshot) {
    const id = snapshot && snapshot.id ? snapshot.id : snapshot;
    return new FakeQuery(this.db, this.collectionName, this.filters, this.order, this.limitValue, id);
  }

  async get() {
    let docs = this.db._allDocs(this.collectionName);

    for (const filter of this.filters) {
      docs = docs.filter((doc) => {
        if (filter.op !== '==') return true;
        return doc.data[filter.field] === filter.value;
      });
    }

    if (this.order) {
      const { field, direction } = this.order;
      docs.sort((left, right) => {
        const a = left.data[field];
        const b = right.data[field];
        if (a === b) return 0;
        if (a == null) return direction === 'desc' ? 1 : -1;
        if (b == null) return direction === 'desc' ? -1 : 1;
        return a > b ? (direction === 'desc' ? -1 : 1) : (direction === 'desc' ? 1 : -1);
      });
    }

    if (this.startAfterId) {
      const index = docs.findIndex((doc) => doc.id === this.startAfterId);
      if (index >= 0) {
        docs = docs.slice(index + 1);
      }
    }

    if (typeof this.limitValue === 'number') {
      docs = docs.slice(0, this.limitValue);
    }

    return {
      docs: docs.map((doc) => new FakeSnapshot({ id: doc.id, data: { ...doc.data }, exists: true })),
      size: docs.length,
      empty: docs.length === 0,
    };
  }
}

class FakeTransaction {
  constructor(db) {
    this.db = db;
  }

  async get(ref) {
    return ref.get();
  }

  set(ref, data, options) {
    return ref.set(data, options);
  }

  create(ref, data) {
    return ref.create(data);
  }
}

class FakeDb {
  constructor(seed = {}) {
    this.collections = new Map();

    for (const [collectionName, docs] of Object.entries(seed)) {
      const collection = new Map();
      for (const [id, data] of Object.entries(docs)) {
        collection.set(id, { ...data });
      }
      this.collections.set(collectionName, collection);
    }
  }

  collection(name) {
    return {
      doc: (id = `auto_${Math.random().toString(36).slice(2, 10)}`) => new FakeDocRef(this, name, id),
      where: (field, op, value) => new FakeQuery(this, name).where(field, op, value),
      orderBy: (field, direction) => new FakeQuery(this, name).orderBy(field, direction),
      count: () => ({ get: async () => ({ data: () => ({ count: this._allDocs(name).length }) }) }),
      get: async () => {
        const docs = this._allDocs(name);
        return {
          docs: docs.map((doc) => new FakeSnapshot({ id: doc.id, data: { ...doc.data }, exists: true })),
          size: docs.length,
        };
      },
    };
  }

  async runTransaction(callback) {
    const tx = new FakeTransaction(this);
    return callback(tx);
  }

  _getCollection(name) {
    if (!this.collections.has(name)) {
      this.collections.set(name, new Map());
    }
    return this.collections.get(name);
  }

  _allDocs(name) {
    return [...this._getCollection(name).entries()].map(([id, data]) => ({ id, data }));
  }

  seed(collectionName, docs) {
    const collection = this._getCollection(collectionName);
    for (const [id, data] of Object.entries(docs)) {
      collection.set(id, { ...data });
    }
  }

  getCollectionDocs(collectionName) {
    return this._allDocs(collectionName).map(({ id, data }) => ({ id, ...data }));
  }
}

module.exports = { FakeDb };