---
triggers:
  - figma
  - design to code
  - figma to react
  - figma to tsx
  - convert design
  - extract from figma
description: Patterns for converting Figma designs to React/TSX components
---

# Figma Code Patterns

Guidelines for converting Figma designs to production React/TSX code.

## Figma API Basics

### Authentication
```bash
# Set your Figma Personal Access Token
export FIGMA_TOKEN="figd_your_token_here"

# Get token: Figma → Account Settings → Personal Access Tokens
```

### Key Endpoints
```bash
# Get file structure
GET https://api.figma.com/v1/files/{file_key}

# Get specific nodes
GET https://api.figma.com/v1/files/{file_key}/nodes?ids={node_ids}

# Export as image
GET https://api.figma.com/v1/images/{file_key}?ids={node_ids}&format=svg
```

### URL Parsing
```
https://www.figma.com/design/ABC123xyz/MyDesign?node-id=1-234
                            ^^^^^^^^^ file_key      ^^^^^ node_id (replace - with :)
```

## Layer Name → Component Mapping

| Figma Naming | Component Output |
|--------------|------------------|
| `Button / Primary` | `ButtonPrimary` or `Button` with variant prop |
| `Card / Default` | `Card` |
| `Icon / Arrow-Right` | `ArrowRightIcon` |
| `Nav / Header` | `HeaderNav` |
| `Form / Input / Text` | `TextInput` |

### Naming Conventions
- Use `/` as hierarchy separator → nested or variant
- Use `-` for multi-word names → camelCase
- Use `_` for internal layers → skip in output
- Prefix with `_` to ignore: `_guides`, `_annotations`

## Property Mapping

### Layout (Auto-layout → Flexbox)

| Figma Auto-layout | Tailwind Classes |
|-------------------|------------------|
| Direction: Horizontal | `flex flex-row` |
| Direction: Vertical | `flex flex-col` |
| Gap: 8 | `gap-2` |
| Gap: 16 | `gap-4` |
| Padding: 16 | `p-4` |
| Padding: 16, 24 (v, h) | `py-4 px-6` |
| Align: Center | `items-center` |
| Justify: Space Between | `justify-between` |
| Wrap | `flex-wrap` |

### Sizing

| Figma Constraint | Tailwind Classes |
|------------------|------------------|
| Fixed width: 200 | `w-[200px]` or `w-52` |
| Fill container | `w-full` or `flex-1` |
| Hug contents | `w-fit` |
| Min width: 100 | `min-w-[100px]` |
| Max width: 400 | `max-w-[400px]` |

### Colors

| Figma Fill | Tailwind |
|------------|----------|
| Solid #171717 | `bg-[#171717]` |
| Solid with variable | `bg-[var(--color-name)]` |
| Opacity 50% | `bg-black/50` |
| Gradient | Use CSS gradient |

### Typography

| Figma Text | Tailwind Classes |
|------------|------------------|
| Size: 14px | `text-sm` |
| Size: 16px | `text-base` |
| Size: 24px | `text-2xl` |
| Weight: 500 | `font-medium` |
| Weight: 700 | `font-bold` |
| Line height: 1.5 | `leading-normal` |
| Letter spacing: 0.5px | `tracking-wide` |
| Align: Center | `text-center` |

### Effects

| Figma Effect | Tailwind Classes |
|--------------|------------------|
| Drop shadow (sm) | `shadow-sm` |
| Drop shadow (md) | `shadow-md` |
| Inner shadow | `shadow-inner` |
| Blur: 4px | `blur-sm` |
| Border radius: 8px | `rounded-lg` |
| Border: 1px solid | `border border-[color]` |

## Component Structure

### Atomic Design Hierarchy

```
Atoms       → Button, Input, Icon, Text
Molecules   → SearchBar (Input + Button), Card (Title + Content)
Organisms   → Header (Logo + Nav + UserMenu), Sidebar
Templates   → PageLayout (Header + Sidebar + Content)
Pages       → Dashboard, Settings
```

### File Organization

```
components/
├── atoms/
│   ├── Button.tsx
│   ├── Input.tsx
│   └── index.ts
├── molecules/
│   ├── SearchBar.tsx
│   ├── Card.tsx
│   └── index.ts
├── organisms/
│   ├── Header.tsx
│   └── index.ts
└── index.ts
```

## Variant Handling

### Figma Variants → Props

```tsx
// Figma: Button / Primary, Button / Secondary, Button / Outline

interface ButtonProps {
  variant?: 'primary' | 'secondary' | 'outline';
  size?: 'sm' | 'md' | 'lg';
  children: React.ReactNode;
}

const variantStyles = {
  primary: 'bg-yellow-400 text-black',
  secondary: 'bg-gray-600 text-white',
  outline: 'border border-gray-400 text-gray-400',
};

export function Button({ variant = 'primary', children }: ButtonProps) {
  return (
    <button className={`px-4 py-2 rounded ${variantStyles[variant]}`}>
      {children}
    </button>
  );
}
```

## Design Tokens Extraction

### From Figma Variables → CSS Variables

```css
/* tokens.css */
:root {
  /* Colors */
  --color-primary: #F3CE49;
  --color-background: #171717;
  --color-surface: #262626;
  --color-text-primary: #FFFFFF;
  --color-text-secondary: #A3A3A3;
  
  /* Typography */
  --font-sans: 'Inter', system-ui, sans-serif;
  --font-mono: 'JetBrains Mono', monospace;
  
  /* Spacing */
  --space-1: 4px;
  --space-2: 8px;
  --space-4: 16px;
  --space-6: 24px;
  
  /* Radii */
  --radius-sm: 4px;
  --radius-md: 8px;
  --radius-lg: 12px;
}
```

### Extend Tailwind Config

```js
// tailwind.config.js
export default {
  theme: {
    extend: {
      colors: {
        primary: 'var(--color-primary)',
        surface: 'var(--color-surface)',
      },
      fontFamily: {
        sans: ['var(--font-sans)'],
      },
    },
  },
};
```

## Responsive Handling

Figma doesn't encode responsive breakpoints, so apply these conventions:

| Figma Frame Width | Breakpoint |
|-------------------|------------|
| 320-375px | Mobile (default) |
| 768px | `md:` |
| 1024px | `lg:` |
| 1280px | `xl:` |
| 1440px+ | `2xl:` |

### Mobile-First Approach
```tsx
<div className="flex flex-col md:flex-row gap-4 md:gap-8">
  <aside className="w-full md:w-64">Sidebar</aside>
  <main className="flex-1">Content</main>
</div>
```

## Common Patterns

### Icon Integration
```tsx
// From Figma SVG export
import { ArrowRightIcon } from '@/icons';

<Button>
  Continue <ArrowRightIcon className="w-4 h-4 ml-2" />
</Button>
```

### Image Handling
```tsx
// Export images from Figma, reference in code
<img 
  src="/images/hero.png" 
  alt="Hero"
  className="w-full h-auto object-cover"
/>
```

## Checklist Before Code Generation

- [ ] Identify all unique components
- [ ] Extract color palette
- [ ] Note typography scale
- [ ] Map spacing values to Tailwind scale
- [ ] Identify component variants
- [ ] Check for icons/images to export
- [ ] Note any animations/transitions
