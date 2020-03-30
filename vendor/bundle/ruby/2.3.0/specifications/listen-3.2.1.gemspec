# -*- encoding: utf-8 -*-
# stub: listen 3.2.1 ruby lib

Gem::Specification.new do |s|
  s.name = "listen"
  s.version = "3.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Thibaud Guillaume-Gentil"]
  s.date = "2019-12-05"
  s.description = "The Listen gem listens to file modifications and notifies you about the changes. Works everywhere!"
  s.email = "thibaud@thibaud.gg"
  s.executables = ["listen"]
  s.files = ["bin/listen"]
  s.homepage = "https://github.com/guard/listen"
  s.licenses = ["MIT"]
  s.required_ruby_version = Gem::Requirement.new([">= 2.2.7", "~> 2.2"])
  s.rubygems_version = "2.5.2.1"
  s.summary = "Listen to file modifications"

  s.installed_by_version = "2.5.2.1" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rb-fsevent>, [">= 0.10.3", "~> 0.10"])
      s.add_runtime_dependency(%q<rb-inotify>, [">= 0.9.10", "~> 0.9"])
      s.add_development_dependency(%q<bundler>, [">= 0"])
    else
      s.add_dependency(%q<rb-fsevent>, [">= 0.10.3", "~> 0.10"])
      s.add_dependency(%q<rb-inotify>, [">= 0.9.10", "~> 0.9"])
      s.add_dependency(%q<bundler>, [">= 0"])
    end
  else
    s.add_dependency(%q<rb-fsevent>, [">= 0.10.3", "~> 0.10"])
    s.add_dependency(%q<rb-inotify>, [">= 0.9.10", "~> 0.9"])
    s.add_dependency(%q<bundler>, [">= 0"])
  end
end
