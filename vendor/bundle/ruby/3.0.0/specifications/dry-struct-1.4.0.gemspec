# -*- encoding: utf-8 -*-
# stub: dry-struct 1.4.0 ruby lib

Gem::Specification.new do |s|
  s.name = "dry-struct".freeze
  s.version = "1.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "allowed_push_host" => "https://rubygems.org", "bug_tracker_uri" => "https://github.com/dry-rb/dry-struct/issues", "changelog_uri" => "https://github.com/dry-rb/dry-struct/blob/master/CHANGELOG.md", "source_code_uri" => "https://github.com/dry-rb/dry-struct" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Piotr Solnica".freeze]
  s.date = "2021-01-21"
  s.description = "Typed structs and value objects".freeze
  s.email = ["piotr.solnica@gmail.com".freeze]
  s.homepage = "https://dry-rb.org/gems/dry-struct".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.5.0".freeze)
  s.rubygems_version = "3.2.3".freeze
  s.summary = "Typed structs and value objects".freeze

  s.installed_by_version = "3.2.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<dry-core>.freeze, ["~> 0.5", ">= 0.5"])
    s.add_runtime_dependency(%q<dry-types>.freeze, ["~> 1.5"])
    s.add_runtime_dependency(%q<ice_nine>.freeze, ["~> 0.11"])
    s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    s.add_development_dependency(%q<rspec>.freeze, [">= 0"])
    s.add_development_dependency(%q<yard>.freeze, [">= 0"])
  else
    s.add_dependency(%q<dry-core>.freeze, ["~> 0.5", ">= 0.5"])
    s.add_dependency(%q<dry-types>.freeze, ["~> 1.5"])
    s.add_dependency(%q<ice_nine>.freeze, ["~> 0.11"])
    s.add_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<rspec>.freeze, [">= 0"])
    s.add_dependency(%q<yard>.freeze, [">= 0"])
  end
end
