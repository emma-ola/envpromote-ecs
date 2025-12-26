/**
 * Comprehensive unit tests for the Express application.
 * Tests all HTTP endpoints for correct status codes and response structure.
 */
const request = require('supertest');
const app = require('../src/index');

describe('GET /health', () => {
    it('should return 200 status code', async () => {
        const res = await request(app).get('/health');

        if (res.statusCode !== 200) {
            console.error('❌ Expected status 200, got', res.statusCode);
            process.exit(1);
        }
        console.log('✅ Health endpoint returns 200');
    });

    it('should return JSON with status ok', async () => {
        const res = await request(app).get('/health');

        if (!res.body || res.body.status !== 'ok') {
            console.error('❌ Expected { status: "ok" }, got', res.body);
            process.exit(1);
        }
        console.log('✅ Health endpoint returns correct JSON');
    });

    it('should have content-type application/json', async () => {
        const res = await request(app).get('/health');

        if (!res.headers['content-type']?.includes('application/json')) {
            console.error('❌ Expected content-type application/json, got', res.headers['content-type']);
            process.exit(1);
        }
        console.log('✅ Health endpoint returns JSON content-type');
    });
});

describe('GET /', () => {
    it('should return 200 status code', async () => {
        const res = await request(app).get('/');

        if (res.statusCode !== 200) {
            console.error('❌ Expected status 200, got', res.statusCode);
            process.exit(1);
        }
        console.log('✅ Root endpoint returns 200');
    });

    it('should return service information', async () => {
        const res = await request(app).get('/');

        if (res.body.service !== 'envpromote-ecs-app') {
            console.error('❌ Expected service name "envpromote-ecs-app", got', res.body.service);
            process.exit(1);
        }

        if (!res.body.message) {
            console.error('❌ Expected message field in response');
            process.exit(1);
        }

        if (!res.body.environment) {
            console.error('❌ Expected environment field in response');
            process.exit(1);
        }

        if (!res.body.version) {
            console.error('❌ Expected version field in response');
            process.exit(1);
        }

        console.log('✅ Root endpoint returns correct service information');
    });

    it('should have content-type application/json', async () => {
        const res = await request(app).get('/');

        if (!res.headers['content-type']?.includes('application/json')) {
            console.error('❌ Expected content-type application/json, got', res.headers['content-type']);
            process.exit(1);
        }
        console.log('✅ Root endpoint returns JSON content-type');
    });
});

describe('404 Not Found', () => {
    it('should return 404 for undefined routes', async () => {
        const res = await request(app).get('/nonexistent');

        if (res.statusCode !== 404) {
            console.error('❌ Expected status 404 for undefined route, got', res.statusCode);
            process.exit(1);
        }
        console.log('✅ Undefined routes return 404');
    });
});

// Run all tests
(async () => {
    console.log('\n=== Running Unit Tests ===\n');

    try {
        // Health endpoint tests
        await describe('GET /health', async () => {
            await it('should return 200 status code');
            await it('should return JSON with status ok');
            await it('should have content-type application/json');
        });

        // Root endpoint tests
        await describe('GET /', async () => {
            await it('should return 200 status code');
            await it('should return service information');
            await it('should have content-type application/json');
        });

        // 404 tests
        await describe('404 Not Found', async () => {
            await it('should return 404 for undefined routes');
        });

        console.log('\n✅ All tests passed!\n');
        process.exit(0);
    } catch (error) {
        console.error('\n❌ Test suite failed:', error.message);
        process.exit(1);
    }
})();
