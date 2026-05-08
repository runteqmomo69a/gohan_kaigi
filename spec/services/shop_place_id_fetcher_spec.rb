require "rails_helper"

RSpec.describe ShopPlaceIdFetcher do
  describe ".call" do
    it "Places APIの先頭idを返すこと" do
      response = instance_double(Faraday::Response, body: { places: [ { id: "place-123" } ] }.to_json)

      allow(Faraday).to receive(:post).and_return(response)
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with("GOOGLE_MAPS_API_KEY", nil).and_return("test-key")

      expect(described_class.call("coffee shinjuku")).to eq("place-123")
    end

    it "候補がない場合はnilを返すこと" do
      response = instance_double(Faraday::Response, body: {}.to_json)

      allow(Faraday).to receive(:post).and_return(response)
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with("GOOGLE_MAPS_API_KEY", nil).and_return("test-key")

      expect(described_class.call("coffee shinjuku")).to be_nil
    end

    it "空文字の場合はnilを返すこと" do
      expect(described_class.call("")).to be_nil
    end
  end
end
