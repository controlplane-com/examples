import { ImageResponse } from 'next/og';
import { site } from '../site.config';

export const size = { width: 64, height: 64 };
export const contentType = 'image/png';

// The favicon is the product's initial on the brand blue, so renaming the product renames the icon too.
export default function Icon() {
  return new ImageResponse(
    (
      <div
        style={{
          width: '100%',
          height: '100%',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          background: '#1563ff',
          borderRadius: 14,
          color: '#ffffff',
          fontSize: 40,
          fontWeight: 700,
          fontFamily: 'sans-serif',
        }}
      >
        {site.name.trim().charAt(0).toUpperCase()}
      </div>
    ),
    size,
  );
}
