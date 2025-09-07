import { defineConfig } from 'orval'

export default defineConfig({
  types: {
    // swagger.yamlは swaggo で生成をさせている。
    // make swagger
    input: '../../apps/api/docs/swagger.yaml',
    output: {
      target: './src/api.ts',
      schemas: './src/types',
      client: 'react-query',
      mode: 'split',
      override: {
        mutator: {
          path: './src/mutator.ts',
          name: 'customInstance',
        },
      },
    },
  },
})
