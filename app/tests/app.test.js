/**
 * Comprehensive unit tests for the Express application.
 * Tests all HTTP endpoints for correct status codes and response structure.
 */
const request = require('supertest');
const app = require('../src/index');

// Test runner
(async () => {
    console.log('\n=== Running Unit Tests ===\n');
    let failedTests = 0;

    // Helper function to run a test
    async function runTest(description, testFn) {
        try {
            await testFn();
            console.log(`✅ ${description}`);
        } catch (error) {
            console.error(`❌ ${description}`);
            console.error(`   ${error.message}`);
            failedTests++;
        }
    }

    // Health endpoint tests
    console.log('Testing GET /health');

    await runTest('should return 200 status code', async () => {
        const res = await request(app).get('/health');
        if (res.statusCode !== 200) {
            throw new Error(`Expected status 200, got ${res.statusCode}`);
        }
    });

    await runTest('should return JSON with status ok', async () => {
        const res = await request(app).get('/health');
        if (!res.body || res.body.status !== 'ok') {
            throw new Error(`Expected { status: "ok" }, got ${JSON.stringify(res.body)}`);
        }
    });

    await runTest('should have content-type application/json', async () => {
        const res = await request(app).get('/health');
        if (!res.headers['content-type']?.includes('application/json')) {
            throw new Error(`Expected content-type application/json, got ${res.headers['content-type']}`);
        }
    });

    // Root endpoint tests
    console.log('\nTesting GET /');

    await runTest('should return 200 status code', async () => {
        const res = await request(app).get('/');
        if (res.statusCode !== 200) {
            throw new Error(`Expected status 200, got ${res.statusCode}`);
        }
    });

    await runTest('should return service information', async () => {
        const res = await request(app).get('/');
        if (res.body.service !== 'envpromote-ecs-app') {
            throw new Error(`Expected service name "envpromote-ecs-app", got ${res.body.service}`);
        }
        if (!res.body.message) {
            throw new Error('Expected message field in response');
        }
        if (!res.body.environment) {
            throw new Error('Expected environment field in response');
        }
        if (!res.body.version) {
            throw new Error('Expected version field in response');
        }
    });

    await runTest('should have content-type application/json', async () => {
        const res = await request(app).get('/');
        if (!res.headers['content-type']?.includes('application/json')) {
            throw new Error(`Expected content-type application/json, got ${res.headers['content-type']}`);
        }
    });

    // 404 tests
    console.log('\nTesting 404 Not Found');

    await runTest('should return 404 for undefined routes', async () => {
        const res = await request(app).get('/nonexistent');
        if (res.statusCode !== 404) {
            throw new Error(`Expected status 404 for undefined route, got ${res.statusCode}`);
        }
    });

    // Summary
    console.log('\n=========================');
    if (failedTests === 0) {
        console.log('✅ All tests passed!\n');
        process.exit(0);
    } else {
        console.log(`❌ ${failedTests} test(s) failed\n`);
        process.exit(1);
    }
})();
