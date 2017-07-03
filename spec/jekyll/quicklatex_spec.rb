require "spec_helper"

ROOT_DIR = File.expand_path("../..", File.dirname(__FILE__))

RSpec.describe Jekyll::Quicklatex do
  let(:doc) { doc_with_content() }
  let(:content)  { fixture('content') }
  let(:output) do
    doc.content = content
    doc.output  = Jekyll::Renderer.new(doc.site, doc).run
  end

  context "correct interface" do
    it "has a version number" do
      expect(Jekyll::Quicklatex::VERSION).not_to be nil
    end
    it "has a block tag class" do
      expect(Jekyll::Quicklatex::Block).not_to be nil
    end
  end

  context "valid tikz snippet" do
    before { stub_request(:post, /quicklatex.com/).to_return(body: fixture('response')) }
    before { stub_request(:get, /quicklatex.com/).to_return(body: fixture('result.png')) }

    let(:pic_path) { File.expand_path('./assets/latex/cache0/00/result.png', ROOT_DIR) }
    let(:cache_path) { File.expand_path('./latex.cache', ROOT_DIR) }

    after :context do
      assets_path = File.expand_path('./assets', ROOT_DIR)
      cache_path = File.expand_path('./latex.cache', ROOT_DIR)
      FileUtils.rm_rf(Dir.new(assets_path)) if Dir.exist? assets_path
      FileUtils.rm_rf(cache_path) if File.exist? cache_path
    end

    it "render right" do
      expect(output).to match(/#{Regexp.escape "<img src=\"/assets/latex/cache0/00/result.png\""}/)
      expect(output).to match(/#{Regexp.escape "http://quicklatex.com/cache0/00/result.png"}/)
    end
    it "save picture locally" do
      expect(File.exist? pic_path).to be true
    end
    it "correct picture content" do
      expect(File.open(pic_path).read).to match("no png content")
    end
    it "new latex cache file" do
      expect(File.exist? cache_path).to be true
    end
    it "picture entry in cache" do
      expect(File.open(cache_path).read).to match(/assets\/latex\/cache0\/00\/result\.png/)
    end
  end
end
