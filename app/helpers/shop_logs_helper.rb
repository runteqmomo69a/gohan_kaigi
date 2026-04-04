# frozen_string_literal: true

module ShopLogsHelper
  CATEGORY_COLORS = [
    "bg-blue-100 text-blue-700",
    "bg-green-100 text-green-700",
    "bg-purple-100 text-purple-700",
    "bg-pink-100 text-pink-700",
    "bg-yellow-100 text-yellow-700",
    "bg-indigo-100 text-indigo-700",
    "bg-red-100 text-red-700",
    "bg-teal-100 text-teal-700",
    "bg-orange-100 text-orange-700",
    "bg-cyan-100 text-cyan-700",

    "bg-blue-50 text-blue-600",
    "bg-green-50 text-green-600",
    "bg-purple-50 text-purple-600",
    "bg-pink-50 text-pink-600",
    "bg-yellow-50 text-yellow-600",
    "bg-indigo-50 text-indigo-600",
    "bg-red-50 text-red-600",
    "bg-teal-50 text-teal-600",
    "bg-orange-50 text-orange-600",
    "bg-cyan-50 text-cyan-600"
  ].freeze

  def category_color(category)
    return "bg-gray-100 text-gray-700" if category.blank?

    index = category.hash % CATEGORY_COLORS.size
    CATEGORY_COLORS[index]
  end
end
