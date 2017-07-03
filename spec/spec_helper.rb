require 'bundler/setup'
require 'fileutils'
require 'webmock/rspec'
require 'jekyll'
require_relative '../lib/jekyll/quicklatex'

TMP_DIR  = File.expand_path("../tmp", File.dirname(__FILE__))

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  def tmp_dir(*files)
    File.join(TMP_DIR, *files)
  end

  def source_dir(*files)
    tmp_dir('source', *files)
  end

  def dest_dir(*files)
    tmp_dir('dest', *files)
  end

  def doc_with_content(opts = {})
    my_site = site(opts)
    Jekyll::Document.new(source_dir('_test/doc.md'), {site: my_site, collection: collection(my_site)})
  end

  def collection(site, label = 'test')
    Jekyll::Collection.new(site, label)
  end

  def site(opts = {})
    conf = Jekyll::Utils.deep_merge_hashes(Jekyll::Configuration::DEFAULTS, opts.merge({
      "source"      => source_dir,
      "destination" => dest_dir
    }))
    Jekyll::Site.new(conf)
  end

  def fixture(name)
    path = File.expand_path "./fixtures/#{name}", File.dirname(__FILE__)
    File.open(path).read
  end
end
