const express = require("express");

const app = express();
const port = process.env.PORT || 3000;

// Health endpoint for ECS / ALB
app.get("/health", (req, res) => {
    res.status(200).json({ status: "ok" });
});

// Root endpoint
app.get("/", (req, res) => {
    res.status(200).json({
        service: "envpromote-ecs-app",
        message: "Hello from ECS 🚀",
        environment: process.env.APP_ENV || "local",
        version: process.env.APP_VERSION || "dev"
    });
});

// Start server
const server = app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});

// Graceful shutdown handler
const gracefulShutdown = (signal) => {
    console.log(`\n${signal} received, shutting down gracefully...`);

    server.close(() => {
        console.log("Server closed successfully. Exiting process.");
        process.exit(0);
    });

    // Force shutdown after 10 seconds if graceful shutdown hangs
    setTimeout(() => {
        console.error("Forcefully shutting down after 10 second timeout");
        process.exit(1);
    }, 10000);
};

// Handle termination signals
process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));

// Export app for testing
module.exports = app;
