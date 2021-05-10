class UserRegisterer < ApplicationRecord
  attr_accessor :token

  before_save :downcase_email
  before_create :set_digest

  validates :email, presence: true, email: true

  def authenticated?(token)
    UserRegisterer.authenticated?(digest, token)
  end

  def expired?
    expired_at < Time.zone.now
  end

  def expired_at
    created_at + 24.hours
  end

  def send_invitation_email
    UserRegistererMailer.invitation(self, token).deliver_later
  end

  private

  def set_digest
    self.token  = UserRegisterer.new_token
    self.digest = UserRegisterer.digest(token)
  end

  def downcase_email
    self.email = email.downcase
  end

  class << self
    def digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end

    def new_token(size = nil)
      SecureRandom.urlsafe_base64 size
    end

    def authenticated?(digest, token)
      return false if digest.nil?

      BCrypt::Password.new(digest).is_password?(token)
    end
  end
end
