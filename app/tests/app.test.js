/**
 * Comprehensive unit tests for the Express application.
 * Tests all HTTP endpoints for correct status codes and response structure.
 */
const request = require('supertest');
const app = require('../src/index');

describe('GET /health', () => {
  it('should return 200 status code', async () => {
    const res = await request(app).get('/health');
    expect(res.statusCode).toBe(200);
  });

  it('should return JSON with status ok', async () => {
    const res = await request(app).get('/health');
    expect(res.body).toEqual({ status: 'ok' });
  });

  it('should have content-type application/json', async () => {
    const res = await request(app).get('/health');
    expect(res.headers['content-type']).toMatch(/application\/json/);
  });
});

describe('GET /', () => {
  it('should return 200 status code', async () => {
    const res = await request(app).get('/');
    expect(res.statusCode).toBe(200);
  });

  it('should return service information with correct structure', async () => {
    const res = await request(app).get('/');

    expect(res.body).toHaveProperty('service', 'envpromote-ecs-app');
    expect(res.body).toHaveProperty('message');
    expect(res.body).toHaveProperty('environment');
    expect(res.body).toHaveProperty('version');

    expect(typeof res.body.message).toBe('string');
    expect(typeof res.body.environment).toBe('string');
    expect(typeof res.body.version).toBe('string');
  });

  it('should have content-type application/json', async () => {
    const res = await request(app).get('/');
    expect(res.headers['content-type']).toMatch(/application\/json/);
  });
});

describe('404 Not Found', () => {
  it('should return 404 for undefined routes', async () => {
    const res = await request(app).get('/nonexistent');
    expect(res.statusCode).toBe(404);
  });

  it('should return 404 for other undefined routes', async () => {
    const res = await request(app).get('/api/users');
    expect(res.statusCode).toBe(404);
  });
});
