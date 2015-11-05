module Fuel
  class Post < ActiveRecord::Base
    include ActionView::Helpers::OutputSafetyHelper

    extend FriendlyId
    friendly_id :title, use: :slugged

    belongs_to :author
    has_many :taggings
    has_many :tags, through: :taggings

    if Rails.version[0].to_i < 4
      attr_accessible :all_tags, :author_id, :content, :title, :teaser, :featured_image, :seo_title, :seo_description, :published, :published_at, :format
    end

    if Fuel.configuration.aws_bucket
      has_attached_file :featured_image, :styles => { :medium => Fuel.configuration.featured_image_settings[:styles][:medium], :thumb => Fuel.configuration.featured_image_settings[:styles][:thumb] }, :default_url => "fuel/default-img.jpg", :storage => :s3, :s3_credentials => Proc.new{|a| a.instance.s3_credentials }
    else
      has_attached_file :featured_image, :styles => { :medium => Fuel.configuration.featured_image_settings[:styles][:medium], :thumb => Fuel.configuration.featured_image_settings[:styles][:thumb] }, :default_url => "fuel/default-img.jpg"
    end
    validates_attachment_content_type :featured_image, :content_type => /\Aimage\/.*\Z/

    validates_presence_of :title, :content, :author_id, :published_at, if: :is_published
    paginates_per Fuel.configuration.paginates_per.to_i

    scope :recent_published_posts, -> { published.recent }
    scope :published, -> { where(published: true) }
    scope :recent, -> { order("published_at DESC").order("created_at DESC") }
    scope :tagged_with, ->(tag_id) { joins(:taggings).merge(Tagging.where(tag_id: tag_id)) }

    module Formats
      MARKDOWN = "markdown"
      HTML = "html"
      DISPLAY = { HTML => "HTML", MARKDOWN => "Markdown" }
      DEFAULT = HTML
    end

    def s3_credentials
      {:bucket => Fuel.configuration.aws_bucket, :access_key_id => Fuel.configuration.aws_access_key, :secret_access_key => Fuel.configuration.aws_secret_access_key}
    end

    def next
      self.class.recent.where("published_at <= ? AND id != ?", published_at, id).first
    end

    def previous
      self.class.recent.where("published_at >= ? AND id != ?", published_at, id).last
    end

    def should_generate_new_friendly_id?
      new_record? #Don't generate new id on edit
    end

    def save_as_draft
      self.published = false
    end

    def is_published
      self.published
    end

    def prioritized_featured_image_url(type = :original)
      featured_image_file_name.present? ? featured_image.url(type) : featured_image_url
    end

    def teaser_content
      teaser.present? ? teaser : content
    end

    def to_html(content = raw_content)
      markdown = Redcarpet::Markdown.new(Fuel::Html,
          :autolink => true, :space_after_headers => true, fenced_code_blocks: true, disable_indented_code_blocks: true)
      raw markdown.render(content)
    end

    def content
      markdown? ? to_html(raw_content) : raw_content
    end

    def raw_content
      attributes["content"]
    end

    def html?
      format == Formats::HTML
    end

    def markdown?
      format == Formats::MARKDOWN
    end

    def all_tags=(names)
      names.split(",").map do |name|
        tag = Tag.where(name: name.strip.downcase).first_or_create!
        tags << tag unless tags.include?(tag)
      end
    end

    def all_tags
      tags.map(&:name).join(", ")
    end

  end
end
