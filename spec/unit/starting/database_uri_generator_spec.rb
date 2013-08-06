require "spec_helper"
require "dea/starting/database_uri_generator"

describe Dea::DatabaseUriGenerator do
  let(:services_env) { [{"credentials" => {"uri" => "postgres://username:password@host/db"}}] }
  let(:services) { Dea::DatabaseUriGenerator.new(services_env) }

  describe "#database_uri" do
    subject(:database_uri) { services.database_uri }

    context "when there are relational database services" do
      context "and there uri is for mysql" do
        let(:services_env) { [{"credentials" => {"uri" => "mysql://username:password@host/db"}}] }

        it { should eq "mysql2://username:password@host/db" }
      end

      context "and there uri is for mysql2" do
        let(:services_env) { [{"credentials" => {"uri" => "mysql2://username:password@host/db"}}] }
        it { should eq "mysql2://username:password@host/db" }
      end

      context "and there uri is for postgres" do
        let(:services_env) { [{"credentials" => {"uri" => "postgres://username:password@host/db"}}] }
        it { should eq "postgresql://username:password@host/db" }
      end

      context "and there uri is for postgresql" do
        let(:services_env) { [{"credentials" => {"uri" => "postgresql://username:password@host/db"}}] }
        it { should eq "postgresql://username:password@host/db" }
      end

      context "and there are more than one production relational database" do
        let(:services_env) do
          [
            {"name" => "production", "credentials" => {"uri" => "postgres://username:password@host/db1"}},
            {"name" => "prod", "credentials" => {"uri" => "postgres://username:password@host/db2"}}
          ]
        end

        it { should eq "postgresql://username:password@host/db1" }
      end

      context "and the uri is invalid" do
        let(:services_env) { [{"credentials" => {"uri" => "postgresql:///inva\\:password@host/db"}}] }

        it "raises an exception" do
          expect { database_uri }.to raise_exception(URI::InvalidURIError, "Invalid database uri: postgresql://USER_NAME_PASS@host/db")
        end
      end
    end

    context "when there are non relational databse services" do
      let(:services_env) { [{"credentials" => {"uri" => "sendgrid://foo:bar@host/db"}}] }
      it { should be_nil }
    end

    context "when there are no services" do
      let(:services_env) { nil }
      it { should be_nil }
    end
  end
end
