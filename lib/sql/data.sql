CREATE TABLE household (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  mode TEXT NOT NULL,            -- 'solo' | 'shared'
  createdAt INTEGER NOT NULL
);

-- ★ 멤버십
CREATE TABLE member (
  id TEXT PRIMARY KEY,           -- solo: local uuid, shared: firebase uid
  householdId TEXT NOT NULL,
  displayName TEXT,
  role TEXT NOT NULL,            -- 'owner' | 'member'
  status TEXT NOT NULL,          -- 'active' | 'invited' | 'left'
  createdAt INTEGER NOT NULL,
  FOREIGN KEY(householdId) REFERENCES household(id)
);
CREATE INDEX idx_member_household ON member(householdId);

CREATE TABLE store (
  id TEXT PRIMARY KEY,
  householdId TEXT NOT NULL,
  name TEXT NOT NULL,
  createdAt INTEGER NOT NULL,
  FOREIGN KEY(householdId) REFERENCES household(id)
);

CREATE TABLE category (
  id TEXT PRIMARY KEY,
  householdId TEXT NOT NULL,
  name TEXT NOT NULL,
  createdAt INTEGER NOT NULL,
  FOREIGN KEY(householdId) REFERENCES household(id)
);

CREATE TABLE purchase (
  id TEXT PRIMARY KEY,
  householdId TEXT NOT NULL,
  purchasedAt INTEGER NOT NULL,
  storeId TEXT NOT NULL,
  categoryId TEXT NOT NULL,
  itemName TEXT,                 -- 선택(통계엔 미사용)
  price INTEGER NOT NULL,
  createdByMemberId TEXT NOT NULL,   -- ★ 누가 만들었는지
  createdAt INTEGER NOT NULL,
  updatedAt INTEGER NOT NULL,
  deletedAt INTEGER,
  FOREIGN KEY(householdId) REFERENCES household(id)
);

CREATE INDEX idx_purchase_store_category_date
  ON purchase(storeId, categoryId, purchasedAt);