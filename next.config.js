// ✅ next.config.js - SIMPLE PROJECT KE LIYE
const path = require('path');

/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  
  // 🔥 Docker ke liye mandatory
  output: 'standalone',
  
  compress: true,
  poweredByHeader: false,
  
  // ✅ FIX: Agar monorepo nahi hai, to YE LINE HATA DEIN YA COMMENT KAR DEIN
  // experimental: {
  //   outputFileTracingRoot: path.join(__dirname, '../../'),  // ❌ Remove this for simple projects
  // },
  
  images: {
    unoptimized: process.env.NODE_ENV === 'production',
  },
};

module.exports = nextConfig;