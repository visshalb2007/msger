import { pgTable, uuid, text, bigint, boolean, timestamp } from "drizzle-orm/pg-core";

export const users = pgTable("users", {
  id: uuid("id").primaryKey().defaultRandom(),
  email: text("email").notNull().unique(),
  display_name: text("display_name"),
  password_hash: text("password_hash").notNull(),
  avatar_url: text("avatar_url"),
  created_at: timestamp("created_at").defaultNow(),
});

export const sessions = pgTable("sessions", {
  id: uuid("id").primaryKey().defaultRandom(),
  user_id: uuid("user_id").notNull().references(() => users.id),
  expires_at: timestamp("expires_at").notNull(),
  user_agent: text("user_agent"),
  created_at: timestamp("created_at").defaultNow(),
});

export const roomKindEnum = pgEnum("kind", ["group", "dm"]);

export const rooms = pgTable("rooms", {
  id: uuid("id").primaryKey().defaultRandom(),
  kind: roomKindEnum("kind").notNull(),
  name: text("name"),
  created_by: uuid("created_by").notNull().references(() => users.id),
  last_seq: bigint("last_seq").default(0),
  created_at: timestamp("created_at").defaultNow(),
});

export const roomMembers = pgTable("room_members", {
  room_id: uuid("room_id").notNull().references(() => rooms.id),
  user_id: uuid("user_id").notNull().references(() => users.id),
  role: text("role").default("member"),
  joined_at: timestamp("joined_at").defaultNow(),
  last_read_seq: bigint("last_read_seq").default(0),
  muted: boolean("muted").default(false),
});

export const messages = pgTable("messages", {
  id: uuid("id").primaryKey().defaultRandom(),
  room_id: uuid("room_id").notNull().references(() => rooms.id, { onDelete: "cascade" }),
  seq: bigint("seq").notNull(),
  sender_id: uuid("sender_id").notNull().references(() => users.id),
  client_id: text("client_id"),
  body: text("body"),
  created_at: timestamp("created_at").defaultNow(),
  edited_at: timestamp("edited_at"),
  deleted_at: timestamp("deleted_at"),
});

export const attachments = pgTable("attachments", {
  id: uuid("id").primaryKey().defaultRandom(),
  message_id: uuid("message_id").references(() => messages.id, { onDelete: "cascade" }),
  uploader_id: uuid("uploader_id").notNull().references(() => users.id),
  object_key: text("object_key").notNull(),
  mime_type: text("mime_type").notNull(),
  size_bytes: bigint("size_bytes").notNull(),
  width: bigint("width"),
  height: bigint("height"),
  created_at: timestamp("created_at").defaultNow(),
});

export const pushSubscriptions = pgTable("push_subscriptions", {
  id: uuid("id").primaryKey().defaultRandom(),
  user_id: uuid("user_id").notNull().references(() => users.id),
  endpoint: text("endpoint").notNull().unique(),
  p256dh: text("p256dh").notNull(),
  auth: text("auth").notNull(),
  user_agent: text("user_agent"),
  created_at: timestamp("created_at").defaultNow(),
  last_success_at: timestamp("last_success_at"),
  failure_count: bigint("failure_count").default(0),
});

export const dmPairs = pgTable("dm_pairs", {
  user_a: uuid("user_a").notNull().references(() => users.id),
  user_b: uuid("user_b").notNull().references(() => users.id),
  room_id: uuid("room_id").notNull().references(() => rooms.id).unique(),
});