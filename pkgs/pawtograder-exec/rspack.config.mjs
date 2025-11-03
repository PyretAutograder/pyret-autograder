// @ts-check

import { defineConfig } from "@rspack/cli";

export default defineConfig({
  entry: {
    main: "./bin/grade.ts",
  },
  module: {
    rules: [
      {
        test: /\.ts$/,
        exclude: [/node_modules/],
        loader: "builtin:swc-loader",
        options: {
          jsc: {
            parser: {
              syntax: "typescript",
            },
          },
        },
        type: "javascript/auto",
      },
    ],
  },
  externalsPresets: {
    node: true,
  },
});
