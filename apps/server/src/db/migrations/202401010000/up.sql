-- CreateTable
CREATE TABLE "users" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "email" TEXT NOT NULL UNIQUE,
  "display_name" TEXT,
  "password_hash" TEXT NOT NULL,
  "avatar_url" TEXT,
  "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- CreateTable
CREATE TABLE "sessions" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "user_id" UUID NOT NULL,
  "expires_at" TIMESTAMP(6) NOT NULL,
  "user_agent" TEXT,
  "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE
);

-- CreateTable
CREATE TABLE "rooms" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "kind" TEXT NOT NULL,
  "name" TEXT,
  "created_by" UUID NOT NULL,
  "last_seq" BIGINT NOT NULL DEFAULT 0,
  "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY ("created_by") REFERENCES "users"("id") ON DELETE CASCADE
);

-- CreateTable
CREATE TABLE "room_members" (
  "room_id" UUID NOT NULL,
  "user_id" UUID NOT NULL,
  "role" TEXT NOT NULL DEFAULT 'member',
  "joined_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "last_read_seq" BIGINT NOT NULL DEFAULT 0,
  "muted" BOOLEAN NOT NULL DEFAULT false,
  PRIMARY KEY ("room_id", "user_id"),
  FOREIGN KEY ("room_id") REFERENCES "rooms"("id") ON DELETE CASCADE,
  FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE
);

-- CreateTable
CREATE TABLE "messages" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "room_id" UUID NOT NULL,
  "seq" BIGINT NOT NULL,
  "sender_id" UUID NOT NULL,
  "client_id" TEXT,
  "body" TEXT,
  "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "edited_at" TIMESTAMP(6),
  "deleted_at" TIMESTAMP(6),
  FOREIGN KEY ("room_id") REFERENCES "rooms"("id") ON DELETE CASCADE,
  FOREIGN KEY ("sender_id") REFERENCES "users"("id") ON DELETE CASCADE
);

-- CreateIndex
CREATE INDEX "messages_room_id_seq_idx" ON "messages" ("room_id", "seq" DESC);

-- CreateTable
CREATE TABLE "attachments" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "message_id" UUID,
  "uploader_id" UUID NOT NULL,
  "object_key" TEXT NOT NULL,
  "mime_type" TEXT NOT NULL,
  "size_bytes" BIGINT NOT NULL,
  "width" BIGINT,
  "height" BIGINT,
  "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY ("message_id") REFERENCES "messages"("id") ON DELETE SET NULL,
  FOREIGN KEY ("uploader_id") REFERENCES "users"("id") ON DELETE CASCADE
);

-- CreateTable
CREATE TABLE "push_subscriptions" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "user_id" UUID NOT NULL,
  "endpoint" TEXT NOT NULL UNIQUE,
  "p256dh" TEXT NOT NULL,
  "auth" TEXT NOT NULL,
  "user_agent" TEXT,
  "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "last_success_at" TIMESTAMP(6),
  "failure_count" BIGINT NOT NULL DEFAULT 0,
  FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE
);

-- CreateTable
CREATE TABLE "dm_pairs" (
  "user_a" UUID NOT NULL,
  "user_b" UUID NOT NULL,
  "room_id" UUID NOT NULL UNIQUE,
  PRIMARY KEY ("user_a", "user_b"),
  FOREIGN KEY ("user_a") REFERENCES "users"("id") ON DELETE CASCADE,
  FOREIGN KEY ("user_b") REFERENCES "users"("id") ON DELETE CASCADE,
  FOREIGN KEY ("room_id") REFERENCES "rooms"("id") ON DELETE CASCADE
);

-- Enable extension for UUID generation
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Insert demo users
INSERT INTO "users" ("id", "email", "display_name", "password_hash") VALUES ('00000000-0000-0000-0000-000000000001', 'alice@example.com', 'Alice', '$2b$12$LQv3eHaOJqB1qBWV8Ae8COYzK.f.s.ssssssssssssssssssssss');
INSERT INTO "users" ("id", "email", "display_name", "password_hash") VALUES ('00000000-0000-0000-0000-000000000002', 'bob@example.com', 'Bob', '$2b$12$LQv3eHaOJqB1qBWV8Ae8COYzK.f.s.ssssssssssssssssssssss');

-- Insert a demo group room
INSERT INTO "rooms" ("id", "kind", "name", "created_by", "last_seq") VALUES ('00000000-0000-0000-0000-000000000003', 'group', 'General', '00000000-0000-0000-0000-000000000001', 0);

-- Add users to room
INSERT INTO "room_members" ("room_id", "user_id", "role") VALUES ('00000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001', 'owner');
INSERT INTO "room_members" ("room_id", "user_id", "role") VALUES ('00000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000002', 'member');