# frozen_string_literal: true

module ShopLogsHelper
  CATEGORY_COLORS = [
    "bg-[#fff1eb] text-[#c45f3d]",
    "bg-[#fff6dc] text-[#b07a10]",
    "bg-[#eef5ec] text-[#5f7d4e]",
    "bg-[#f3eee8] text-[#7a6757]",
    "bg-[#f8ece7] text-[#b1654e]",
    "bg-[#f2efe6] text-[#7b7467]",
    "bg-[#f7f0dc] text-[#8f6f16]",
    "bg-[#edf3f2] text-[#52736b]"
  ].freeze

  def category_color(category)
    return "bg-[#fff1eb] text-[#c45f3d]" if category.blank?

    index = category.hash % CATEGORY_COLORS.size
    CATEGORY_COLORS[index]
  end
end
