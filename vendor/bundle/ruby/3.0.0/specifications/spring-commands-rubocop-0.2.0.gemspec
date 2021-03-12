# -*- encoding: utf-8 -*-
# stub: spring-commands-rubocop 0.2.0 ruby lib

Gem::Specification.new do |s|
  s.name = "spring-commands-rubocop".freeze
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Alex Rodionov".freeze]
  s.date = "2016-10-06"
  s.description = "RuboCop command for Spring".freeze
  s.email = "p0deje@gmail.com".freeze
  s.homepage = "https://github.com/p0deje/spring-commands-rubocop".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.2.3".freeze
  s.summary = "RuboCop command for Spring".freeze

  s.installed_by_version = "3.2.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<spring>.freeze, [">= 1.0", "< 3.0"])
    s.add_development_dependency(%q<rake>.freeze, [">= 0"])
  else
    s.add_dependency(%q<spring>.freeze, [">= 1.0", "< 3.0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
  end
end
