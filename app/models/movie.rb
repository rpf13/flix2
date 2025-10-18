class Movie < ApplicationRecord
  RATINGS = %w(G PG PG-13 R NC-17)

  has_many :reviews, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :fans, through: :favorites, source: :user
  has_many :characterizations, dependent: :destroy
  has_many :genres, through: :characterizations
  has_one_attached :main_image

  validates :title, :released_on, :duration, presence: true
  validates :description, length: { minimum: 25 }
  validates :total_gross, numericality: { greater_than_or_equal_to: 0 }

  validates :rating, inclusion: { in: RATINGS }
  validate :acceptable_image

  scope :released, -> { where("released_on < ?", Time.now).order(released_on: :desc) }
  scope :upcoming, -> { where("released_on > ?", Time.now).order(released_on: :asc) }
  scope :recent, ->(max=5) { released.limit(max) }
  scope :hits, -> { released.where("total_gross >= 300000000").order(total_gross: :desc) }
  scope :flops, -> { released.where("total_gross < 225000000").order(total_gross: :asc) }

  # class method converted to a scope
  # def self.released
  #   where("released_on < ?", Time.now).order(released_on: :desc)
  # end

  # class method converted to a scope
  # def self.hits
  #   where("total_gross >= 300000000").order(total_gross: :desc)
  # end

  # class method converted to a scope
  # def self.flops
  #   where("total_gross < 225000000").order(total_gross: :asc)
  # end

  def self.recently_added
    order("created_at desc").limit(3)
  end

  def flop?
    return false if reviews.count > 50 && average_stars >= 4
    total_gross.blank? || total_gross < 225_000_000
  end

  def average_stars
    reviews.average(:stars) || 0.0
  end

  def average_stars_as_percent
    (average_stars / 5.0) * 100
  end

  private
  def acceptable_image
    return unless main_image.attached?

    unless main_image.blob.byte_size <= 5.megabyte
      errors.add(:main_image, "is too big")
    end

    acceptable_types = ["image/jpeg", "image/jpg", "image/png"]
    unless acceptable_types.include?(main_image.blob.content_type)
      errors.add(:main_image, "must be a JPEG or PNG")
    end
  end
end
