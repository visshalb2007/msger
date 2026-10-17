import { z } from "zod";

const envSchema = z.object({
  NODE_ENV: z.enum(["development", "production", "test"]).default("development"),
  PORT: z.coerce.number().default(3000),
  PUBLIC_ORIGIN: z.string().default("http://localhost:5173"),
  DATABASE_URL: z.string(),
  REDIS_URL: z.string(),
  S3_ENDPOINT: z.string().default("http://localhost:9000"),
  S3_REGION: z.string().default("us-east-1"),
  S3_BUCKET: z.string().default("msg-uploads"),
  S3_ACCESS_KEY: z.string().default("minioadmin"),
  S3_SECRET_KEY: z.string().default("minioadmin"),
  SESSION_SECRET: z.string().min(32),
  VAPID_PUBLIC_KEY: z.string().default(""),
  VAPID_PRIVATE_KEY: z.string().default(""),
  VAPID_SUBJECT: z.string().default("mailto:admin@example.com"),
});

const parsed = envSchema.safeParse(Object.fromEntries(process.env));

if (parsed instanceof z.ZodError) {
  console.error("Invalid environment variables:", parsed.errors);
  process.exit(1);
}

export const env = parsed.data;