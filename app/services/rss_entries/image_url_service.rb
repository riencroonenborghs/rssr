module RssEntries
  # Finds an image for a parsed feed entry: the feed's own image metadata (media:thumbnail,
  # media:content or an enclosure), else the first <img> in its content or summary. Relative URLs
  # are resolved against the entry's URL; only http(s) URLs are returned.
  class ImageUrlService < ApplicationService
    # Enclosures and media:content are often audio or video rather than images.
    NON_IMAGE_EXTENSIONS = %w[.mp3 .m4a .aac .ogg .oga .wav .flac .mp4 .m4v .mov .webm .avi .mkv .pdf].freeze

    def initialize(feed_entry)
      @feed_entry = feed_entry
    end

    def call
      candidates.each do |candidate|
        url = absolute_url(candidate)
        return url if url && !non_image?(url)
      end
      nil
    end

    private
      attr_reader :feed_entry

      def candidates
        [ read(:image), first_img_src(read(:content)), first_img_src(read(:summary)) ].compact_blank
      end

      def read(attribute)
        feed_entry.public_send(attribute) if feed_entry.respond_to?(attribute)
      end

      def first_img_src(html)
        return if html.blank?

        Nokogiri::HTML5.fragment(html).at_css("img[src]")&.[]("src")
      end

      def absolute_url(candidate)
        uri = URI.parse(candidate.strip)
        base = read(:url)
        uri = URI.join(base, uri) if uri.relative? && base.present?
        uri.to_s if uri.is_a?(URI::HTTP) && uri.host.present?
      rescue URI::Error
        nil
      end

      def non_image?(url)
        NON_IMAGE_EXTENSIONS.include?(File.extname(URI.parse(url).path.to_s).downcase)
      end
  end
end
