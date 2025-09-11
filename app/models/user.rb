class User < ApplicationRecord
  has_many :reviews, dependent: :destroy

  has_secure_password

  validates :name, presence: true
  validates :email, presence: true,
                    format: { with: /\S+@\S+/ },
                    uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 8, allow_blank: true }
  # blank is important because a password isn't required when a user updates his name and/or email.

  def gravatar_id
    Digest::MD5::hexdigest(email.downcase)
  end

end
