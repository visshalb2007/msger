import tseslint from '@typescript-eslint/eslint-plugin';
import parserEslint from 'eslint-plugin-react';
import * as tsparser from '@typescript-eslint/parser';

export default [
  {
    ignores: ['node_modules', 'dist', '.pnpm-store'],
  },
  {
    files: ['**/*.ts', '**/*.tsx', '**/*.js', '**/.jsx'],
    languageOptions: {
      parser: tsparser,
      parserOptions: {
        ecmaVersion: 2022,
        sourceType: 'module',
      },
    },
    rules: {
      'no-unused-vars': 'warn',
      'no-explicit-any': 'warn',
    },
  },
];