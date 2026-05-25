---
triggers:
  - tailwind
  - tailwindcss
  - utility classes
  - css utilities
  - styling components
description: Tailwind CSS conventions and best practices for React components
---

# Tailwind Standards

Conventions for writing clean, maintainable Tailwind CSS in React/TSX components.

## Class Organization

Order classes logically for readability:

```tsx
<div className="
  {/* Layout */}
  flex flex-col items-center justify-between
  {/* Sizing */}
  w-full max-w-md h-auto
  {/* Spacing */}
  p-4 m-2 gap-4
  {/* Background & Border */}
  bg-white border border-gray-200 rounded-lg
  {/* Typography */}
  text-gray-900 text-sm font-medium
  {/* Effects */}
  shadow-md
  {/* States */}
  hover:bg-gray-50 focus:ring-2
  {/* Responsive */}
  md:flex-row md:p-6
">
```

## Spacing Scale

Use Tailwind's default scale consistently:

| Value | Pixels | Use For |
|-------|--------|---------|
| 1 | 4px | Tight spacing, icons |
| 2 | 8px | Default small gap |
| 3 | 12px | Compact elements |
| 4 | 16px | Default padding |
| 6 | 24px | Section spacing |
| 8 | 32px | Large gaps |
| 12 | 48px | Section separators |
| 16 | 64px | Page sections |

## Color Usage

### Semantic Colors

```tsx
// Text
text-gray-900    // Primary text
text-gray-600    // Secondary text
text-gray-400    // Muted/placeholder

// Backgrounds
bg-white         // Primary surface
bg-gray-50       // Secondary surface
bg-gray-100      // Tertiary/hover

// Borders
border-gray-200  // Default border
border-gray-300  // Emphasized border

// Status
text-green-600   // Success
text-red-600     // Error
text-yellow-600  // Warning
text-blue-600    // Info
```

### Dark Mode

```tsx
<div className="bg-white dark:bg-gray-900 text-gray-900 dark:text-white">
  Content
</div>
```

## Component Patterns

### Button Variants

```tsx
// Primary
className="bg-primary text-black px-4 py-2 rounded-lg font-medium hover:bg-primary/90"

// Secondary
className="bg-gray-600 text-white px-4 py-2 rounded-lg font-medium hover:bg-gray-700"

// Outline
className="border border-gray-300 text-gray-700 px-4 py-2 rounded-lg font-medium hover:bg-gray-50"

// Ghost
className="text-gray-600 px-4 py-2 rounded-lg font-medium hover:bg-gray-100"

// Sizes
// sm: px-3 py-1.5 text-sm
// md: px-4 py-2 text-base (default)
// lg: px-6 py-3 text-lg
```

### Input Fields

```tsx
<input
  className="
    w-full px-3 py-2
    bg-white border border-gray-300 rounded-lg
    text-gray-900 placeholder-gray-400
    focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent
    disabled:bg-gray-100 disabled:cursor-not-allowed
  "
/>
```

### Cards

```tsx
<div className="bg-white border border-gray-200 rounded-xl p-6 shadow-sm">
  <h3 className="text-lg font-semibold text-gray-900 mb-2">Title</h3>
  <p className="text-gray-600">Content</p>
</div>
```

## Responsive Design

### Mobile-First Breakpoints

```tsx
// Default = mobile
// md: = tablet (768px)
// lg: = desktop (1024px)
// xl: = large desktop (1280px)

<div className="
  flex flex-col        {/* Mobile: stack */}
  md:flex-row          {/* Tablet+: row */}
  gap-4 md:gap-8       {/* Responsive gap */}
">
```

### Common Responsive Patterns

```tsx
// Grid columns
className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6"

// Sidebar layout
className="flex flex-col lg:flex-row"
// Sidebar: "w-full lg:w-64 lg:shrink-0"
// Content: "flex-1 min-w-0"

// Hide/show
className="hidden md:block"  // Hide on mobile
className="md:hidden"        // Show only on mobile

// Text size
className="text-2xl md:text-4xl lg:text-5xl"
```

## Avoiding Pitfalls

### ❌ Don't

```tsx
// Too many arbitrary values
className="w-[347px] h-[89px] mt-[13px]"

// Conflicting classes
className="p-4 p-6"  // Which one?

// Over-nesting
className="hover:focus:active:disabled:bg-red-500"
```

### ✅ Do

```tsx
// Use scale values
className="w-80 h-24 mt-3"

// Single source of truth
className="p-4 md:p-6"

// Keep states simple
className="bg-gray-100 hover:bg-gray-200 disabled:opacity-50"
```

## Extracting Components

When a pattern repeats 3+ times, extract to a component:

```tsx
// Instead of repeating this everywhere:
<button className="bg-primary text-black px-4 py-2 rounded-lg font-medium hover:bg-primary/90">

// Create a component:
function Button({ children, variant = 'primary' }) {
  const base = "px-4 py-2 rounded-lg font-medium transition-colors";
  const variants = {
    primary: "bg-primary text-black hover:bg-primary/90",
    secondary: "bg-gray-600 text-white hover:bg-gray-700",
  };
  return (
    <button className={`${base} ${variants[variant]}`}>
      {children}
    </button>
  );
}
```

## With CSS Variables

```tsx
// In tailwind.config.js
theme: {
  extend: {
    colors: {
      primary: 'var(--color-primary)',
      surface: 'var(--color-surface)',
    },
  },
}

// Usage
className="bg-primary text-surface"
```

## Animation Classes

```tsx
// Transitions
className="transition-colors duration-200"
className="transition-all duration-300 ease-in-out"

// Hover effects
className="hover:scale-105 transition-transform"
className="hover:-translate-y-1 transition-transform"

// Loading states
className="animate-spin"
className="animate-pulse"
```

## Accessibility

```tsx
// Focus visible (keyboard only)
className="focus:outline-none focus-visible:ring-2 focus-visible:ring-primary"

// Screen reader only
className="sr-only"

// Skip to content
className="sr-only focus:not-sr-only focus:absolute focus:top-4 focus:left-4"
```

## Tailwind Config Template

```js
// tailwind.config.js
export default {
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        primary: '#F3CE49',
        surface: {
          DEFAULT: '#262626',
          dark: '#171717',
        },
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
      },
      borderRadius: {
        '4xl': '2rem',
      },
    },
  },
  plugins: [
    require('@tailwindcss/typography'),
    require('@tailwindcss/forms'),
  ],
};
```
