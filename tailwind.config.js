/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./app/views/**/*.html.erb",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
    "./app/assets/stylesheets/**/*.css",
  ],
  theme: { extend: {} },
  plugins: [require("daisyui")],
  daisyui: {
    themes: [
      {
        gohan: {
          "primary": "#EA580C",          // 落ち着いたオレンジ（orange-600）
          "primary-content": "#ffffff",

          "secondary": "#FDBA74",        // やわらかいサブカラー
          "accent": "#FB923C",

          "neutral": "#3F3F46",

          "base-100": "#FFFBF5",         // ほぼ白＋ほんのりベージュ
          "base-200": "#FAF3E7",
          "base-300": "#F3E8D9",

          "base-content": "#2E2E2E",

          "info": "#38BDF8",
          "success": "#22C55E",
          "warning": "#F59E0B",
          "error": "#EF4444",
        },
      },
    ],
  },
}