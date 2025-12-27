module.exports = {
  // Use Node.js environment for testing
  testEnvironment: 'node',

  // Set NODE_ENV to test
  setupFiles: ['<rootDir>/jest.setup.js'],

  // Directory for coverage reports
  coverageDirectory: 'coverage',

  // Collect coverage from source files
  collectCoverageFrom: [
    'src/**/*.js',
    '!src/**/*.test.js',
    '!src/**/*.spec.js'
  ],

  // Test match patterns
  testMatch: [
    '**/tests/**/*.test.js',
    '**/__tests__/**/*.js'
  ],

  // Coverage thresholds (optional - can be enabled later)
  // coverageThreshold: {
  //   global: {
  //     branches: 80,
  //     functions: 80,
  //     lines: 80,
  //     statements: 80
  //   }
  // },

  // Verbose output
  verbose: true,

  // Clear mocks between tests
  clearMocks: true,

  // Timeout for tests (in milliseconds)
  testTimeout: 10000
};
