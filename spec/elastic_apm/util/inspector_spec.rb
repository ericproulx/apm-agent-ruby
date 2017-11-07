# frozen_string_literal: true

require 'spec_helper'

module ElasticAPM
  module Util
    RSpec.describe Inspector do
      describe '#transaction' do
        it 'inspects a regular transaction', :mock_time do
          transaction = Transaction.new(nil, 'GET /things', 'request')
          travel 100
          transaction.done 'success'

          expect(subject.transaction(transaction).lines.length).to be 3
        end

        it 'inspects a complex transaction and its traces', :mock_time do
          transaction = Transaction.new(nil, 'GET /things', 'request') do |t|
            travel 100
            t.trace 'app/views/users/index.html.erb', 'template' do
              travel 100
              t.trace('SELECT * FROM users', 'db.query') do
                travel 100
              end
              travel 100
            end
            travel 100
          end.done 'success'

          expect(subject.transaction(transaction).lines.length).to be 7
        end
      end
    end
  end
end
