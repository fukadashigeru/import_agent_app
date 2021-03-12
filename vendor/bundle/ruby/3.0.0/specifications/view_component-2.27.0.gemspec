# -*- encoding: utf-8 -*-
# stub: view_component 2.27.0 ruby lib

Gem::Specification.new do |s|
  s.name = "view_component".freeze
  s.version = "2.27.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "allowed_push_host" => "https://rubygems.org" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["GitHub Open Source".freeze]
  s.date = "2021-03-08"
  s.email = ["opensource+view_component@github.com".freeze]
  s.homepage = "https://github.com/github/view_component".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.3.0".freeze)
  s.rubygems_version = "3.2.3".freeze
  s.summary = "View components for Rails".freeze

  s.installed_by_version = "3.2.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<activesupport>.freeze, [">= 5.0.0", "< 7.0"])
    s.add_development_dependency(%q<benchmark-ips>.freeze, ["~> 2.8.2"])
    s.add_development_dependency(%q<bundler>.freeze, ["~> 1.14"])
    s.add_development_dependency(%q<rake>.freeze, ["~> 13.0"])
    s.add_development_dependency(%q<minitest>.freeze, ["= 5.6.0"])
    s.add_development_dependency(%q<haml>.freeze, ["~> 5"])
    s.add_development_dependency(%q<slim>.freeze, ["~> 4.0"])
    s.add_development_dependency(%q<better_html>.freeze, ["~> 1"])
    s.add_development_dependency(%q<rubocop>.freeze, ["= 0.74"])
    s.add_development_dependency(%q<rubocop-github>.freeze, ["~> 0.13.0"])
    s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.18.0"])
    s.add_development_dependency(%q<simplecov-console>.freeze, ["~> 0.7.2"])
    s.add_development_dependency(%q<pry>.freeze, ["~> 0.13"])
  else
    s.add_dependency(%q<activesupport>.freeze, [">= 5.0.0", "< 7.0"])
    s.add_dependency(%q<benchmark-ips>.freeze, ["~> 2.8.2"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.14"])
    s.add_dependency(%q<rake>.freeze, ["~> 13.0"])
    s.add_dependency(%q<minitest>.freeze, ["= 5.6.0"])
    s.add_dependency(%q<haml>.freeze, ["~> 5"])
    s.add_dependency(%q<slim>.freeze, ["~> 4.0"])
    s.add_dependency(%q<better_html>.freeze, ["~> 1"])
    s.add_dependency(%q<rubocop>.freeze, ["= 0.74"])
    s.add_dependency(%q<rubocop-github>.freeze, ["~> 0.13.0"])
    s.add_dependency(%q<simplecov>.freeze, ["~> 0.18.0"])
    s.add_dependency(%q<simplecov-console>.freeze, ["~> 0.7.2"])
    s.add_dependency(%q<pry>.freeze, ["~> 0.13"])
  end
end
