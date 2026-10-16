/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: {
        base: {
          950: '#0b0f14',
          900: '#12181f',
          800: '#1a222b',
          700: '#242e39',
          600: '#334152',
        },
        signal: {
          DEFAULT: '#f2a900',
          dim: '#8a6200',
        },
        ok: '#3fb27f',
        warn: '#e2a336',
        danger: '#e05a4e',
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
        mono: ['"IBM Plex Mono"', 'monospace'],
      },
    },
  },
  plugins: [],
}
