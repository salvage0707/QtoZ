class Emoji
  def self.random_emoji_unicode
    emoji_keys = Twemoji.codes.keys
    random_emoji = emoji_keys.at(rand(emoji_keys.size()))

    code = Twemoji.find_by_text(random_emoji)

    # 0000-11111 のような文字列から絵文字(unicode)に変換する
    return code.split("-").map { |v| v.hex }.pack("U*")
  end
end