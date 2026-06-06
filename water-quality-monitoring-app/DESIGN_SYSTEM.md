# Water Monitoring App - Design System Reference

## Color Palette

### Primary Colors
- **Primary Brand**: `#0066FF` (Modern Blue)
- **Primary Light**: `#5BA3FF` (Light Blue)
- **Primary Dark**: `#0052CC` (Dark Blue)

### Status Colors
| Status | Color | Light | Usage |
|--------|-------|-------|-------|
| **SAFE** | `#10B981` | `#A7F3D0` | Green - Good water quality |
| **CAUTION** | `#F59E0B` | `#FEF3C7` | Amber - Warning state |
| **LIMITED USE** | `#F97316` | `#FFEDD5` | Orange - Use restricted |
| **DANGEROUS** | `#EF4444` | `#FEE2E2` | Red - Do not use |

### Background Colors
- **Page Background**: `#F8FAFF` (Very Light Blue)
- **Card Background**: `#FFFFFF` (White)
- **Surface Overlay**: `#FAFBFF` (Subtle Blue Tint)

### Text Colors
- **Main Text**: `#1A1A2E` (Dark Navy)
- **Secondary Text**: `#6B7280` (Medium Gray)
- **Tertiary Text**: `#9CA3AF` (Light Gray)

### Accent Colors
- **Accent Purple**: `#8B5CF6`
- **Accent Light**: `#EDE9FE`

## Typography Scale

### Title
- **Size**: 28px
- **Weight**: 800 (Extra Bold)
- **Color**: Main Text (#1A1A2E)
- **Letter Spacing**: -0.5px

### Heading
- **Size**: 18px
- **Weight**: 700 (Bold)
- **Color**: Main Text (#1A1A2E)
- **Letter Spacing**: -0.3px

### Subtitle
- **Size**: 16px
- **Weight**: 600 (Semi-Bold)
- **Color**: Main Text (#1A1A2E)

### Value (Large Numbers)
- **Size**: 36px
- **Weight**: 900 (Black)
- **Color**: Primary (#0066FF)
- **Letter Spacing**: -0.5px

### Label
- **Size**: 13px
- **Weight**: 500 (Medium)
- **Color**: Secondary Text (#6B7280)
- **Letter Spacing**: 0.2px

### Caption
- **Size**: 12px
- **Weight**: 400 (Regular)
- **Color**: Tertiary Text (#9CA3AF)

## Component Specifications

### Cards
- **Border Radius**: 20px
- **Padding**: 20px
- **Shadow**: 
  - Primary: `0 8px 24px rgba(0, 102, 255, 0.08)`
  - Secondary: `0 4px 12px rgba(26, 26, 46, 0.04)`
- **Border**: 1px solid Primary with 0.08 opacity

### Buttons
- **Border Radius**: 12px
- **Padding**: 24px horizontal, 12px vertical
- **Elevation**: 0px (flat design)

### Icons
- **Primary Size**: 24px
- **Large Size**: 32px
- **Extra Large**: 48px
- **Container Radius**: 10-12px
- **Container Padding**: 8-10px

## Spacing Scale

| Size | Value |
|------|-------|
| XS | 4px |
| S | 8px |
| M | 12px |
| L | 16px |
| XL | 20px |
| 2XL | 24px |
| 3XL | 28px |

## Border Radius Scale

| Size | Value |
|------|-------|
| Small | 8px |
| Medium | 12px |
| Large | 16px |
| Extra Large | 20px |

## Animation Specifications

### Entrance Animations
- **Parameter Cards**:
  - Scale: 0.8 → 1.0
  - Opacity: 0.0 → 1.0
  - Duration: 600ms
  - Curve: Cubic Easing

- **Status Banner**:
  - Slide: -50px → 0px
  - Fade: 0.0 → 1.0
  - Pulse: 1.0 → 1.05
  - Duration: 800ms

### Page Transitions
- **Slide Transition**:
  - Direction: Left to Right
  - Duration: Variable based on system animation speed
  - Curve: Cubic Easing

### Micro-interactions
- **Icon Buttons**: Subtle color change on interaction
- **Cards**: Hover effect with slightly increased shadow
- **Loading States**: Continuous circular rotation

## Design Patterns

### Glass-Morphism
- Semi-transparent backgrounds with subtle gradients
- Layered shadows for depth perception
- Thin borders for definition (1-1.5px)

### Gradient System
- Linear gradients from top-left to bottom-right
- Subtle opacity variations (0.04 to 0.3)
- Color-matched to content underneath

### Visual Hierarchy
1. **Primary**: Large titles, primary CTAs
2. **Secondary**: Headings, important data
3. **Tertiary**: Labels, helper text
4. **Quaternary**: Timestamps, metadata

## Responsive Breakpoints

- **Mobile**: 0 - 599px
- **Tablet**: 600 - 1023px
- **Desktop**: 1024px+

### Grid System
- **Mobile**: 2 columns
- **Tablet**: 2-3 columns
- **Desktop**: 4 columns

## Accessibility

- **Color Contrast**: WCAG AA compliant
- **Text Scaling**: Supports system font size adjustments
- **Touch Targets**: Minimum 48x48px
- **Icons**: All paired with labels or descriptive text

## Dark Mode (Reserved for Future)

Color mappings for dark theme:
- Background: `#0A0E27`
- Card: `#16213E`
- Text: `#FFFFFF`
- Secondary Text: `#A0AEC0`

---

**Design System Version**: 1.0
**Last Updated**: March 2026
**Framework**: Flutter + Material 3
