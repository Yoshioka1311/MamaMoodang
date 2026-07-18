import type { Config } from 'tailwindcss';

export default {
  darkMode: ['class'],
  content: ['./index.html', './src/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: {
        border: 'hsl(var(--border))',
        input: 'hsl(var(--input))',
        ring: 'hsl(var(--ring))',
        background: 'hsl(var(--background))',
        foreground: 'hsl(var(--foreground))',
        muted: {
          DEFAULT: 'hsl(var(--muted))',
          foreground: 'hsl(var(--muted-foreground))'
        },
        card: {
          DEFAULT: 'hsl(var(--card))',
          foreground: 'hsl(var(--card-foreground))'
        },
        primary: {
          DEFAULT: 'hsl(var(--primary))',
          foreground: 'hsl(var(--primary-foreground))'
        },
        destructive: 'hsl(var(--destructive))',
        medical: {
          blue: '#D9ECFB',
          mint: '#DDF2C0',
          rose: '#FF8FAB',
          ink: '#202225'
        }
      },
      boxShadow: {
        soft: '0 18px 50px rgba(44, 48, 58, 0.08)'
      }
    }
  },
  plugins: []
} satisfies Config;
