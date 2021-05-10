class User < ApplicationRecord
  has_secure_password
  attr_accessor :remember_token, :reset_token

  before_save :downcase_email

  # has_many :user_email_changers, dependent: :delete_all
  # has_many :members, dependent: :delete_all
  # has_many :owner_members, -> { owner }, class_name: 'Member', inverse_of: :user
  # has_many :owned_orgs, through: :owner_members, source: :org
  # has_many :orgs, through: :members
  # has_many :job_logs, foreign_key: :executer_id, dependent: :nullify, inverse_of: :executer

  validates :name, presence: true
  validates :email, presence: true, email: true, uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  def remember
    self.remember_token = User.new_token
    update(remember_digest: User.digest(remember_token))
  end

  def forget
    update(remember_digest: nil)
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
  end

  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  def send_password_reset_email
    UserMailer.password_reset(self, reset_token).deliver_later
  end

  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    User.authenticated?(digest, token)
  end

  def destroyable?
    owned_orgs.empty?
  end

  def update_email(user_email_changer)
    old_email = email
    if update(email: user_email_changer.email)
      UserEmailChangerMailer.notification(user_email_changer, old_email).deliver_later
      true
    else
      false
    end
  end

  # 組織に所属できるかどうか
  #
  # @return [Boolean]
  def memberable?(org)
    return true if org.contracts.any?

    orgs.no_contract.count < 3
  end

  private

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
