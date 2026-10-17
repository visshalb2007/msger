import Fastify from "fastify";
import helmet from "helmet";
import pino from "pino";
import { env } from "../src/config";

export async function createServer() {
  const fastify = Fastify({
    logger: pino({
      level: env.NODE_ENV === "development" ? "info" : "warn",
    }),
  });

  // Security headers
  fastify.use(helmet());

  // Health check endpoint
  fastify.get("/healthz", async () => {
    return { status: "ok" };
  });

  // Centralized error handler
  fastify.setErrorHandler((error, request, reply) => {
    fastify.log.error(error, "unhandled fastify error");
    const status = error.statusCode || 500;
    reply.status(status).send({
      error: error.message || "Internal Server Error",
      statusCode: status,
    });
  });

  return fastify;
}