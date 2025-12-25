const express = require("express");

const app = express();
const port = process.env.PORT || 3000;

// Health endpoint for ECS / ALB
app.get("/health", (req, res) => {
    res.status(500).json({status: "failing"});
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

app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
