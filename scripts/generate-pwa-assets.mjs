/**
 * Regenerates PWA icons and iOS splash screens from public/favicon.png.
 * Run: node scripts/generate-pwa-assets.mjs
 */
import sharp from 'sharp'
import { mkdir } from 'node:fs/promises'
import path from 'node:path'

const root = path.resolve(import.meta.dirname, '..')
const src = path.join(root, 'public/favicon.png')
const iconsDir = path.join(root, 'public/icons')
const splashDir = path.join(root, 'public/splash')

await mkdir(iconsDir, { recursive: true })
await mkdir(splashDir, { recursive: true })

async function squareIcon(size, filename, { maskable = false } = {}) {
  const scale = maskable ? 0.68 : 0.86
  const max = Math.round(size * scale)
  const resized = await sharp(src)
    .resize({ width: max, height: max, fit: 'inside' })
    .png()
    .toBuffer()
  const rMeta = await sharp(resized).metadata()
  const left = Math.floor((size - (rMeta.width ?? 0)) / 2)
  const top = Math.floor((size - (rMeta.height ?? 0)) / 2)
  await sharp({
    create: {
      width: size,
      height: size,
      channels: 4,
      background: { r: 0, g: 0, b: 0, alpha: 1 },
    },
  })
    .composite([{ input: resized, left, top }])
    .png()
    .toFile(path.join(iconsDir, filename))
  console.log('icon', filename)
}

await squareIcon(192, 'icon-192.png')
await squareIcon(512, 'icon-512.png')
await squareIcon(192, 'icon-192-maskable.png', { maskable: true })
await squareIcon(512, 'icon-512-maskable.png', { maskable: true })
await squareIcon(180, 'apple-touch-icon.png')
await squareIcon(167, 'apple-touch-icon-167.png')
await squareIcon(152, 'apple-touch-icon-152.png')
await squareIcon(120, 'apple-touch-icon-120.png')

await sharp(path.join(iconsDir, 'apple-touch-icon.png')).toFile(
  path.join(root, 'public/apple-touch-icon.png'),
)

const splashes = [
  { w: 1290, h: 2796, name: 'apple-splash-1290x2796.png' },
  { w: 1179, h: 2556, name: 'apple-splash-1179x2556.png' },
  { w: 1170, h: 2532, name: 'apple-splash-1170x2532.png' },
  { w: 1284, h: 2778, name: 'apple-splash-1284x2778.png' },
  { w: 1125, h: 2436, name: 'apple-splash-1125x2436.png' },
  { w: 1242, h: 2688, name: 'apple-splash-1242x2688.png' },
  { w: 750, h: 1334, name: 'apple-splash-750x1334.png' },
  { w: 1242, h: 2208, name: 'apple-splash-1242x2208.png' },
  { w: 2048, h: 2732, name: 'apple-splash-2048x2732.png' },
]

for (const { w, h, name } of splashes) {
  const max = Math.round(Math.min(w, h) * 0.28)
  const resized = await sharp(src)
    .resize({ width: max, height: max, fit: 'inside' })
    .png()
    .toBuffer()
  const rMeta = await sharp(resized).metadata()
  const left = Math.floor((w - (rMeta.width ?? 0)) / 2)
  const top = Math.floor((h - (rMeta.height ?? 0)) / 2)
  await sharp({
    create: {
      width: w,
      height: h,
      channels: 4,
      background: { r: 0, g: 0, b: 0, alpha: 1 },
    },
  })
    .composite([{ input: resized, left, top }])
    .png({ compressionLevel: 9 })
    .toFile(path.join(splashDir, name))
  console.log('splash', name)
}

console.log('PWA assets generated.')
